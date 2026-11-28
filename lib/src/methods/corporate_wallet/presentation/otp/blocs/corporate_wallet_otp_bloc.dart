import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../api/xpay_log_event.dart';
import '../../../../../base/domain/domain.dart';
import '../../../../../base/extensions/extensions.dart';
import '../../../../../core/domain/entities/payment_authorize_entity.dart';
import '../../../../../di/di.dart';
import '../../../../../shared/business_logger/xp_business_logger.dart';
import '../../../domain/entities/corporate_wallet_challenge_entity.dart';
import '../../../domain/entities/corporate_wallet_failure_reason_enum.dart';
import '../../../domain/entities/corporate_wallet_otp_channel_entity.dart';
import '../../../domain/entities/corporate_wallet_otp_error_details_entity.dart';
import '../../../domain/entities/corporate_wallet_payment_entity.dart';
import '../../../domain/repositories/corporate_wallet_repo.dart';
import '../../../domain/usecases/request_corporate_wallet_otp_uc.dart';
import '../../../domain/usecases/verify_corporate_wallet_otp_uc.dart';

part 'corporate_wallet_otp_event.dart';

part 'corporate_wallet_otp_state.dart';

final class CorporateWalletOtpBloc extends Bloc<CorporateWalletOtpEvent, CorporateWalletOtpState> {
  CorporateWalletOtpBloc({required List<CorporateWalletOtpChannelEntity> channels, required CorporateWalletChallengeEntity challenge})
    : super(
        CorporateWalletOtpInitState(
          channels: channels,
          challenge: challenge,
          resendCooldownUntil: DateTime.now().add(PaymentAuthorizeVerificationEntity.resendCooldownFallback),
          attemptsRemaining: challenge.attemptsRemaining,
        ),
      ) {
    on<CorporateWalletOtpChangeCodeEvent>(_codeChangedHandler);
    on<CorporateWalletOtpSubmitEvent>(_submittedHandler);
    on<CorporateWalletOtpCodeExpiredEvent>(_codeExpiredHandler);
    on<CorporateWalletOtpResendEvent>(_resendHandler);
    on<CorporateWalletOtpChangeChannelEvent>(_changeChannelHandler);
    on<CorporateWalletOtpResendCooldownEndedEvent>(_resendCooldownEndedHandler);
  }

  final _logger = getIt.get<XPBusinessLogger>();
  final _requestOtp = RequestCorporateWalletOtpUseCase(getIt.get<CorporateWalletRepository>());
  final _verifyOtp = VerifyCorporateWalletOtpUseCase(getIt.get<CorporateWalletRepository>());

  static const int _kUnavailableRetryLimit = 2;

  static const Duration _kUnavailableRetryDelay = Duration(seconds: 1);

  bool _isSending = false;
  bool _isVerifying = false;

  void _codeChangedHandler(CorporateWalletOtpChangeCodeEvent event, Emitter<CorporateWalletOtpState> emit) {
    final rejection = state.rejection;
    emit(
      CorporateWalletOtpCodeChangedState(
        channels: state.channels,
        challenge: state.challenge,
        rejection: event.code.isEmpty || (rejection?.isCodeUnusable ?? false) ? rejection : null,
        resendCooldownUntil: state.resendCooldownUntil,
        code: event.code,
        attemptsRemaining: state.attemptsRemaining,
      ),
    );
  }

  Future<void> _submittedHandler(CorporateWalletOtpSubmitEvent event, Emitter<CorporateWalletOtpState> emit) async {
    if (!state.canSubmit || _isVerifying) return;

    _isVerifying = true;
    emit(
      CorporateWalletOtpSubmitLoadingState(
        channels: state.channels,
        challenge: state.challenge,
        resendCooldownUntil: state.resendCooldownUntil,
        code: state.code,
        attemptsRemaining: state.attemptsRemaining,
      ),
    );

    final input = VerifyCorporateWalletOtpInput(walletPaymentId: state.challenge.walletPaymentId, code: state.code);
    var result = await _verifyOtp.execute(input);
    var unavailableRetries = 0;
    while (_isWalletUnavailable(result) && unavailableRetries < _kUnavailableRetryLimit && isClosed == false) {
      unavailableRetries++;
      await Future<void>.delayed(_kUnavailableRetryDelay);
      result = await _verifyOtp.execute(input);
    }
    _isVerifying = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        final reason = CorporateWalletFailureReason.fromException(failure);
        _logger.logBusiness(input: input.toLog(), exception: failure, action: 'verify_otp', feature: 'corporate_wallet', reason: reason.name);

        if (reason.isCodeRejection) {
          final details = failure.details;
          final attemptsRemaining = details is CorporateWalletOtpErrorDetailsEntity ? details.attemptsRemaining : state.attemptsRemaining;
          final isLocked = reason == CorporateWalletFailureReason.otpInvalid && attemptsRemaining != null && attemptsRemaining <= 0;
          emit(
            CorporateWalletOtpRejectedState(
              channels: state.channels,
              challenge: state.challenge,
              rejection: isLocked ? CorporateWalletFailureReason.otpLocked : reason,
              resendCooldownUntil: state.resendCooldownUntil,
              attemptsRemaining: attemptsRemaining,
            ),
          );
          return;
        }

        emit(
          CorporateWalletOtpVerifyErrorState(
            channels: state.channels,
            challenge: state.challenge,
            resendCooldownUntil: state.resendCooldownUntil,
            code: state.code,
            attemptsRemaining: state.attemptsRemaining,
            reason: reason,
            errorCode: failure.errorCode,
            errorMessage: failure.displayMessage,
            isConflict: failure.isConflict,
          ),
        );
      },
      (payment) {
        _logger.logBusiness(input: input.toLog(), level: XPayLogLevel.info, action: 'verify_otp_captured', feature: 'corporate_wallet');
        emit(CorporateWalletOtpVerifiedState(channels: state.channels, challenge: state.challenge, code: state.code, payment: payment));
      },
    );
  }

  bool _isWalletUnavailable(Either<XPException, CorporateWalletPaymentEntity> result) {
    final failure = result.getLeftOrNull();
    return failure != null && CorporateWalletFailureReason.fromException(failure) == CorporateWalletFailureReason.walletUnavailable;
  }

  void _codeExpiredHandler(CorporateWalletOtpCodeExpiredEvent event, Emitter<CorporateWalletOtpState> emit) {
    if (state.rejection?.isCodeUnusable ?? false) return;

    emit(
      CorporateWalletOtpCodeExpiredState(
        channels: state.channels,
        challenge: state.challenge,
        resendCooldownUntil: state.resendCooldownUntil,
        attemptsRemaining: state.attemptsRemaining,
      ),
    );
  }

  Future<void> _resendHandler(CorporateWalletOtpResendEvent event, Emitter<CorporateWalletOtpState> emit) async {
    if (_isSending || _isVerifying || state.isResendOnCooldown) return;

    final challenge = state.challenge;
    await _sendCode(emit, RequestCorporateWalletOtpInput(challenge.method, challenge.recipientId), isSwitchingChannel: false);
  }

  Future<void> _changeChannelHandler(CorporateWalletOtpChangeChannelEvent event, Emitter<CorporateWalletOtpState> emit) async {
    if (_isSending || _isVerifying || state.isResendOnCooldown || !state.otherChannels.contains(event.channel)) return;

    await _sendCode(emit, RequestCorporateWalletOtpInput(event.channel.method, event.channel.recipientId), isSwitchingChannel: true);
  }

  Future<void> _sendCode(Emitter<CorporateWalletOtpState> emit, RequestCorporateWalletOtpInput input, {required bool isSwitchingChannel}) async {
    _isSending = true;
    emit(
      CorporateWalletOtpResendLoadingState(
        channels: state.channels,
        challenge: state.challenge,
        rejection: state.rejection,
        resendCooldownUntil: state.resendCooldownUntil,
        code: state.code,
        attemptsRemaining: state.attemptsRemaining,
        isSwitchingChannel: isSwitchingChannel,
      ),
    );

    final result = await _requestOtp.execute(input);
    _isSending = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        final reason = CorporateWalletFailureReason.fromException(failure);
        _logger.logBusiness(input: input.toLog(), exception: failure, action: 'resend_otp', feature: 'corporate_wallet', reason: reason.name);
        emit(
          CorporateWalletOtpResendErrorState(
            channels: state.channels,
            challenge: state.challenge,
            rejection: state.rejection,
            resendCooldownUntil: reason == CorporateWalletFailureReason.otpVelocityExceeded
                ? DateTime.now().add(PaymentAuthorizeVerificationEntity.resendCooldownFallback)
                : state.resendCooldownUntil,
            code: state.code,
            attemptsRemaining: state.attemptsRemaining,
            reason: reason,
            errorCode: failure.errorCode,
            errorMessage: failure.displayMessage,
          ),
        );
      },
      (challenge) => emit(
        CorporateWalletOtpResendSentState(
          channels: state.channels,
          challenge: challenge,
          resendCooldownUntil: DateTime.now().add(PaymentAuthorizeVerificationEntity.resendCooldownFallback),
          attemptsRemaining: challenge.attemptsRemaining,
        ),
      ),
    );
  }

  void _resendCooldownEndedHandler(CorporateWalletOtpResendCooldownEndedEvent event, Emitter<CorporateWalletOtpState> emit) {
    if (state.resendCooldownUntil == null) return;

    emit(
      CorporateWalletOtpResendCooldownEndedState(
        channels: state.channels,
        challenge: state.challenge,
        rejection: state.rejection,
        code: state.code,
        attemptsRemaining: state.attemptsRemaining,
      ),
    );
  }
}

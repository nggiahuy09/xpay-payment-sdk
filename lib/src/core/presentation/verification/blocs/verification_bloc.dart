import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../api/xpay_log_event.dart';
import '../../../../base/domain/domain.dart';
import '../../../../base/extensions/extensions.dart';
import '../../../../di/di.dart';
import '../../../../shared/helpers/helpers.dart';
import '../../../../shared/business_logger/xp_business_logger.dart';
import '../../../domain/entities/payment_authorize_entity.dart';
import '../../../domain/entities/payment_verify_entity.dart';
import '../../../domain/repositories/payment_authorize_repo.dart';
import '../../../domain/usecases/get_payment_uc.dart';
import '../../../domain/usecases/resend_payment_verification_uc.dart';
import '../../../domain/usecases/verify_payment_uc.dart';
import '../../../domain/entities/payment_resend_verification_failure_reason.dart';
import '../../../domain/entities/verification_rejection_entity.dart';

part 'verification_event.dart';

part 'verification_state.dart';

final class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc({required PaymentAuthorizeVerificationEntity verification, required double amount, required String authId, String? initialRecipientId})
    : _authId = authId,
      super(VerificationInitState(verification: verification, amount: amount, resendCooldownUntil: _resolveResendCooldown(verification))) {
    on<VerificationChangeCodeEvent>(_codeChangedHandler);
    on<VerificationSubmitEvent>(_submittedHandler);
    on<VerificationCodeExpiredEvent>(_codeExpiredHandler);
    on<VerificationDeadlinePassedEvent>(_deadlinePassedHandler);
    on<VerificationResendCodeEvent>(_resendCodeHandler);
    on<VerificationSelectRecipientEvent>(_selectRecipientHandler);
    on<_VerificationPromptRecipientEvent>(_promptRecipientHandler);
    on<VerificationResendCooldownEndedEvent>(_resendCooldownEndedHandler);
    on<VerificationAbandonEvent>(_abandonHandler);

    // Entering on an already-dead code is not the same as entering on a dead sale: the former lands on the input screen with a resend offered, the latter exits.
    if (verification.isDeadlinePassed) {
      maybeAdd(const VerificationDeadlinePassedEvent());
    } else if (verification.isCodeExpiredWithinSession) {
      maybeAdd(const VerificationCodeExpiredEvent());
    } else if (verification.isAwaitingRecipient) {
      maybeAdd(
        initialRecipientId != null && verification.isRecipientAvailable(initialRecipientId)
            ? VerificationSelectRecipientEvent(initialRecipientId)
            : const _VerificationPromptRecipientEvent(),
      );
    }
  }

  /// The moment the resend action becomes available again.
  ///
  /// Prefers the server's `can_resend_at` so the button and the server's cooldown agree; falls back to a fixed client window when the server omits it, since an
  /// immediately-enabled button would just earn a `resend_too_soon`. A server value already in the past means no cooldown is running.
  ///
  /// Also seeds the opening state, where the fallback carries an assumption worth stating: a code sent moments ago as part of authorizing should not be resendable
  /// instantly, or the merchant spends a slot from the per-sale cap before the customer could plausibly have received it. That reasoning does not hold for a code
  /// that has *already* expired — a resumed, parked payment — so no cooldown is imposed there and the merchant can act at once.
  static DateTime? _resolveResendCooldown(PaymentAuthorizeVerificationEntity verification) {
    if (verification.isAwaitingRecipient) return null;

    final canResendAt = verification.canResendAt;
    if (canResendAt != null) return canResendAt.isAfter(DateTime.now()) ? canResendAt : null;
    return verification.isCodeExpiredWithinSession ? null : DateTime.now().add(PaymentAuthorizeVerificationEntity.resendCooldownFallback);
  }

  final _getPayment = GetPaymentUseCase(getIt.get<PaymentAuthorizeRepository>());
  final _logger = getIt.get<XPBusinessLogger>();
  final _resendVerification = ResendPaymentVerificationUseCase(getIt.get<PaymentAuthorizeRepository>());
  final _verifyPayment = VerifyPaymentUseCase(getIt.get<PaymentAuthorizeRepository>());

  final String _authId;

  static const String _kOtpExpiredCode = 'otp_expired';
  static const String _kOtpRecipientRequiredCode = 'otp_recipient_required';
  static const String _kVerificationNotPendingCode = 'verification_not_pending';

  /// Idempotency key for the verification currently being attempted, keyed by the code that is being submitted.
  ///
  /// Resubmitting the *same* code reuses the key, so a request that timed out after the server already evaluated it is deduplicated into a replay instead
  /// of consuming a second attempt from the server-side counter. Typing a different code is a genuinely new attempt, so it starts a new key — otherwise a
  /// corrected code would be swallowed as a replay of the wrong one.
  String _verifyIdempotencyKey = '';
  String? _verifyIdempotencyOperation;

  int _resendAttempt = 0;
  int _verifyAttempt = 0;

  /// Whether a resend request is already in flight, so a double tap sends one code rather than two.
  ///
  /// Kept separate from [_isVerifying]: the two calls are independent, and a resend must not be blocked by an unrelated verify that is still settling.
  bool _isResending = false;

  /// Whether a verification request is already in flight.
  ///
  /// Guards the handler rather than [VerificationState.canSubmit]: the OTP field's `onCompleted` can fire alongside the submit button, and two concurrent
  /// requests sharing one idempotency key would otherwise rely on the gateway collapsing them instead of simply not being sent.
  bool _isVerifying = false;

  /// Keeps a displayed rejection alive while the field is empty, and drops it as soon as real digits arrive.
  ///
  /// Emptying the field is how the view reacts to a rejection, so that change must not erase the message it is reacting to. Typing is different: the message
  /// describes the code that was submitted, so it is stale the moment a different one is being entered.
  void _codeChangedHandler(VerificationChangeCodeEvent event, Emitter<VerificationState> emit) {
    emit(
      VerificationCodeChangedState(
        verification: state.verification,
        amount: state.amount,
        rejection: event.code.isEmpty ? state.rejection : null,
        resendFailureReason: state.resendFailureReason,
        resendCooldownUntil: state.resendCooldownUntil,
        code: event.code,
        isSessionOver: state.isSessionOver,
      ),
    );
  }

  bool _emitSettledPayment(Emitter<VerificationState> emit, PaymentVerifyEntity payment) {
    _logger.logBusiness(
      input: {'auth_id': _authId, 'payment_status': payment.status.name, 'decline_reason': payment.declineReason?.reason.name},
      level: XPayLogLevel.warn,
      action: 'verify_not_pending',
      feature: 'verification',
    );
    switch (payment.status) {
      case PaymentAuthorizeStatus.approved:
      case PaymentAuthorizeStatus.captured:
      case PaymentAuthorizeStatus.partiallyCaptured:
        emit(VerificationApprovedState(result: payment, verification: state.verification, amount: state.amount, code: state.code));
        return true;
      case PaymentAuthorizeStatus.declined:
        if (payment.declineReason?.isExpired ?? false) {
          emit(VerificationSessionExpiredState(verification: state.verification, amount: state.amount, code: state.code));
        } else {
          emit(VerificationDeclinedState(result: payment, verification: state.verification, amount: state.amount, code: state.code));
        }
        return true;
      case PaymentAuthorizeStatus.voided:
      case PaymentAuthorizeStatus.expired:
        emit(VerificationSessionExpiredState(verification: state.verification, amount: state.amount, code: state.code));
        return true;
      case PaymentAuthorizeStatus.pendingVerification:
      case PaymentAuthorizeStatus.unknown:
        return false;
    }
  }

  Future<void> _submittedHandler(VerificationSubmitEvent event, Emitter<VerificationState> emit) async {
    if (!state.canSubmit || _isVerifying) return;

    final operation = '$_authId:${state.code}';
    if (_verifyIdempotencyOperation != operation) {
      _verifyIdempotencyOperation = operation;
      _verifyIdempotencyKey = XPHelperCryptography.generateUuidV4();
    }

    _verifyAttempt++;
    _isVerifying = true;

    emit(
      VerificationSubmitLoadingState(
        verification: state.verification,
        amount: state.amount,
        resendFailureReason: state.resendFailureReason,
        resendCooldownUntil: state.resendCooldownUntil,
        code: state.code,
        attempt: _verifyAttempt,
      ),
    );

    final input = VerifyPaymentInput(authId: _authId, code: state.code, idempotencyKey: _verifyIdempotencyKey);
    final result = await _verifyPayment.execute(input);
    final isNotPending = result.getLeftOrNull()?.errorCode == _kVerificationNotPendingCode;
    final payment = isNotPending && isClosed == false ? (await _getPayment.execute(_authId)).getOrNull() : null;
    _isVerifying = false;
    if (isClosed) return;
    if (payment != null && _emitSettledPayment(emit, payment)) return;

    result.fold(
      (failure) {
        _logger.logBusiness(input: input.toLog(), exception: failure, action: 'verify', feature: 'verification');
        if (failure.errorCode == _kOtpExpiredCode && state.canOfferResend) {
          emit(VerificationCodeExpiredState(verification: state.verification, amount: state.amount, resendFailureReason: state.resendFailureReason));
          maybeAdd(const VerificationResendCodeEvent());
          return;
        }

        if (failure.errorCode == _kOtpRecipientRequiredCode || payment != null) {
          emit(
            VerificationErrorState(
              verification: state.verification,
              amount: state.amount,
              resendFailureReason: state.resendFailureReason,
              resendCooldownUntil: state.resendCooldownUntil,
              code: state.code,
              failure: failure,
              attempt: _verifyAttempt,
            ),
          );
          return;
        }

        emit(
          VerificationFailedState(verification: state.verification, amount: state.amount, code: state.code, errorCode: failure.errorCode, isConflict: failure.isConflict),
        );
      },
      (verify) {
        if (verify.isCaptured || verify.isApproved) {
          _logger.logBusiness(input: {'auth_id': _authId}, level: XPayLogLevel.info, action: 'verify_approved', feature: 'verification');
          emit(VerificationApprovedState(result: verify, verification: state.verification, amount: state.amount, code: state.code));
        } else if (verify.declineReason?.isExpired ?? false) {
          // Checked ahead of the decline branch: the wire frames a timed-out session as a decline, but the merchant needs the expired screen's "new transaction"
          // exit rather than a decline sheet blaming the card.
          _logger.logBusiness(input: {'auth_id': _authId}, category: XPayLogCategory.error, action: 'verification_expired', feature: 'verification');
          emit(VerificationSessionExpiredState(verification: verify.verification ?? state.verification, amount: state.amount, code: state.code));
        } else if (verify.requiresVerification) {
          // Wrong code: the server returns a refreshed verification (decremented attempts) that decides whether retrying is still possible.
          final refreshed = verify.verification ?? state.verification;

          if (refreshed.isDeadlinePassed) {
            _logger.logBusiness(input: {'auth_id': _authId}, category: XPayLogCategory.error, action: 'verification_expired', feature: 'verification');
            emit(VerificationSessionExpiredState(verification: refreshed, amount: state.amount, code: state.code));
          } else if ((refreshed.attemptsRemaining ?? 1) <= 0) {
            // No attempts left is terminal even though the server still frames the transaction as pending: no further code can be submitted, so it is handed back
            // as a decline for the caller's blocking sheet rather than leaving the merchant on a screen with a permanently disabled button.
            //
            // Ordered ahead of the code-expiry branch deliberately: with no attempts left a fresh code would be unusable, so offering a resend would be a dead end.
            _logger.logBusiness(
              input: {'auth_id': _authId, 'decline_reason': verify.declineReason?.reason.name},
              level: XPayLogLevel.warn,
              action: 'verify_declined',
              feature: 'verification',
            );
            emit(VerificationDeclinedState(result: verify, verification: refreshed, amount: state.amount, code: state.code));
          } else if (refreshed.isCodeExpiredWithinSession) {
            // The submitted code was wrong *and* its window has since closed. The sale is still open, so the merchant is kept on screen to request a new code.
            emit(
              VerificationCodeExpiredState(
                verification: refreshed,
                amount: state.amount,
                resendFailureReason: state.resendFailureReason,
                resendCooldownUntil: state.resendCooldownUntil,
              ),
            );
          } else {
            _logger.logBusiness(input: {'auth_id': _authId, 'attempt': _verifyAttempt}, level: XPayLogLevel.warn, action: 'verify_rejected', feature: 'verification');
            final rejection = VerificationRejectionEntity(method: refreshed.method, declineReason: verify.declineReason, remainingAttempts: _verifyAttempt);
            emit(
              VerificationRejectedState(
                verification: refreshed,
                amount: state.amount,
                rejection: rejection,
                resendFailureReason: state.resendFailureReason,
                resendCooldownUntil: state.resendCooldownUntil,
                code: state.code,
              ),
            );
          }
        } else if (verify.isDeclined) {
          _logger.logBusiness(
            input: {'auth_id': _authId, 'decline_reason': verify.declineReason?.reason.name},
            level: XPayLogLevel.warn,
            action: 'verify_declined',
            feature: 'verification',
          );
          emit(VerificationDeclinedState(result: verify, verification: state.verification, amount: state.amount, code: state.code));
        } else {
          // Neither captured, approved, pending, nor declined (voided/expired/partiallyCaptured/unknown):
          // the transaction is not in a terminal state we can report on, so treat it as a generic failure rather than asserting a decline that did not happen.
          _logger.logBusiness(
            input: {...input.toLog(), 'response_status': verify.status.name},
            category: XPayLogCategory.error,
            action: 'verify',
            feature: 'verification',
            reason: 'unexpected_status',
          );
          emit(
            VerificationErrorState(
              verification: state.verification,
              amount: state.amount,
              resendFailureReason: state.resendFailureReason,
              resendCooldownUntil: state.resendCooldownUntil,
              code: state.code,
              attempt: _verifyAttempt,
            ),
          );
        }
      },
    );
  }

  /// Retires the expired code, ending the flow only if the session's deadline has also passed.
  ///
  /// The two are distinct on the wire: a code expires long before the sale does, and the API keeps the sale verifiable up to `verification_deadline`. Treating the
  /// code's expiry as terminal would strand a still-collectable payment on the "start a new transaction" screen — and would hide the resend action precisely when the
  /// merchant needs it.
  void _codeExpiredHandler(VerificationCodeExpiredEvent event, Emitter<VerificationState> emit) {
    if (state.verification.isDeadlinePassed) {
      emit(VerificationSessionExpiredState(verification: state.verification, amount: state.amount, code: state.code));
      return;
    }
    if (state.verification.isAwaitingRecipient) return;

    emit(
      VerificationCodeExpiredState(
        verification: state.verification,
        amount: state.amount,
        resendFailureReason: state.resendFailureReason,
        resendCooldownUntil: state.resendCooldownUntil,
      ),
    );
  }

  void _deadlinePassedHandler(VerificationDeadlinePassedEvent event, Emitter<VerificationState> emit) {
    emit(VerificationSessionExpiredState(verification: state.verification, amount: state.amount, code: state.code));
  }

  /// Asks the server for a fresh code, which kills the one the customer already has.
  ///
  /// Guarded on [VerificationState.canOfferResend] as well as the in-flight flag, so an action the UI has already retired cannot be re-entered through a stale
  /// tap. The successful response replaces the whole verification block rather than patching fields, because the server owns the new expiry, the decremented
  /// resend budget, and the next cooldown together.
  Future<void> _resendCodeHandler(VerificationResendCodeEvent event, Emitter<VerificationState> emit) async {
    if (!state.canOfferResend || state.isResendOnCooldown || _isResending) return;

    await _sendCode(emit, null);
  }

  Future<void> _selectRecipientHandler(VerificationSelectRecipientEvent event, Emitter<VerificationState> emit) async {
    if (!state.canSelectRecipient || !state.verification.isRecipientAvailable(event.recipientId) || _isResending) return;
    await _sendCode(emit, event.recipientId);
  }

  void _promptRecipientHandler(_VerificationPromptRecipientEvent event, Emitter<VerificationState> emit) {
    if (!state.isAwaitingRecipient || _isResending) return;
    emit(VerificationRecipientPromptState(verification: state.verification, amount: state.amount));
  }

  Future<void> _sendCode(Emitter<VerificationState> emit, String? recipientId) async {
    final isInitialSend = state.verification.isAwaitingRecipient;
    _resendAttempt++;
    _isResending = true;

    final verification = state.verification;
    final amount = state.amount;
    emit(
      isInitialSend
          ? VerificationSendLoadingState(verification: verification, amount: amount, attempt: _resendAttempt)
          : VerificationResendLoadingState(
              verification: verification,
              amount: amount,
              rejection: state.rejection,
              resendCooldownUntil: state.resendCooldownUntil,
              code: state.code,
              recipientId: recipientId,
              attempt: _resendAttempt,
            ),
    );

    final input = ResendPaymentVerificationInput(authId: _authId, recipientId: recipientId);
    final result = await _resendVerification.execute(input);
    _isResending = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        final reason = PaymentResendVerificationFailureReason.fromRemote(failure.errorCode);
        final action = isInitialSend ? 'send_verification' : 'resend_verification';
        _logger.logBusiness(input: input.toLog(), exception: failure, action: action, feature: 'verification', reason: reason.name);
        emit(
          VerificationResendErrorState(
            verification: state.verification,
            amount: state.amount,
            rejection: state.rejection,
            resendFailureReason: reason,
            resendCooldownUntil: !isInitialSend && reason == PaymentResendVerificationFailureReason.tooSoon
                ? DateTime.now().add(PaymentAuthorizeVerificationEntity.resendCooldownFallback)
                : state.resendCooldownUntil,
            code: state.code,
            failure: failure,
            attempt: _resendAttempt,
          ),
        );
        if (isInitialSend) maybeAdd(const _VerificationPromptRecipientEvent());
      },
      (resend) {
        final refreshed = resend.verification ?? state.verification;

        // Checked before treating the send as usable. Past the session deadline the server declines the auth as `verification_expired`, and a sale no longer pending
        // verification has nothing to send a code for — in both cases a returned code would be one the merchant can never spend, so the expired screen's exit is the
        // honest outcome rather than a fresh countdown.
        //
        // Only the *session* deadline is disqualifying here. The freshly-issued code's own expiry is by definition in the future, and judging this against it would
        // let a device clock running fast discard a code the server just sent.
        if ((resend.declineReason?.isExpired ?? false) || !resend.requiresVerification || refreshed.isDeadlinePassed) {
          emit(VerificationSessionExpiredState(verification: refreshed, amount: state.amount, code: state.code));
          return;
        }

        emit(
          isInitialSend
              ? VerificationCodeSentState(verification: refreshed, amount: state.amount, resendCooldownUntil: _resolveResendCooldown(refreshed), attempt: _resendAttempt)
              : VerificationResendSentState(verification: refreshed, amount: state.amount, resendCooldownUntil: _resolveResendCooldown(refreshed), attempt: _resendAttempt),
        );
      },
    );
  }

  /// Re-enables the resend action once its cooldown elapses, clearing the deadline the view was counting down to.
  ///
  /// A settled refusal is left in place: [VerificationState.canOfferResend] still hides the action for it, and clearing the reason here would revive a button that
  /// can only fail again.
  void _resendCooldownEndedHandler(VerificationResendCooldownEndedEvent event, Emitter<VerificationState> emit) {
    if (state.resendCooldownUntil == null) return;

    emit(
      VerificationResendCooldownEndedState(
        verification: state.verification,
        amount: state.amount,
        rejection: state.rejection,
        resendFailureReason: state.resendFailureReason,
        code: state.code,
        isSessionOver: state.isSessionOver,
      ),
    );
  }

  void _abandonHandler(VerificationAbandonEvent event, Emitter<VerificationState> emit) => _logger.logBusiness(
    input: {'auth_id': _authId},
    category: XPayLogCategory.behavior,
    level: XPayLogLevel.info,
    action: 'verification_abandon',
    feature: 'verification',
  );
}

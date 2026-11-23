import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/di.dart';
import '../../../../shared/business_logger/xp_business_logger.dart';
import '../../domain/entities/corporate_wallet_challenge_entity.dart';
import '../../domain/entities/corporate_wallet_failure_reason_enum.dart';
import '../../domain/entities/corporate_wallet_otp_channel_entity.dart';
import '../../domain/repositories/corporate_wallet_repo.dart';
import '../../domain/usecases/get_corporate_wallet_otp_channels_uc.dart';
import '../../domain/usecases/request_corporate_wallet_otp_uc.dart';

part 'corporate_wallet_event.dart';

part 'corporate_wallet_state.dart';

final class CorporateWalletBloc extends Bloc<CorporateWalletEvent, CorporateWalletState> {
  CorporateWalletBloc() : super(const CorporateWalletInitState()) {
    on<CorporateWalletLoadChannelsEvent>(_loadChannelsHandler);
    on<CorporateWalletRequestOtpEvent>(_requestOtpHandler);
    add(const CorporateWalletLoadChannelsEvent());
  }

  final _getOtpChannels = GetCorporateWalletOtpChannelsUseCase(getIt.get<CorporateWalletRepository>());
  final _logger = getIt.get<XPBusinessLogger>();
  final _requestOtp = RequestCorporateWalletOtpUseCase(getIt.get<CorporateWalletRepository>());

  bool _isLoadingChannels = false;
  bool _isRequestingOtp = false;

  Future<void> _loadChannelsHandler(CorporateWalletLoadChannelsEvent event, Emitter<CorporateWalletState> emit) async {
    if (_isLoadingChannels) return;

    _isLoadingChannels = true;
    emit(CorporateWalletChannelsLoadingState(channels: state.channels));

    final result = await _getOtpChannels.execute(null);
    _isLoadingChannels = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        final reason = CorporateWalletFailureReason.fromException(failure);
        _logger.logBusiness(input: const {}, exception: failure, action: 'get_otp_channels', feature: 'corporate_wallet', reason: reason.name);
        emit(CorporateWalletChannelsLoadErrorState(reason: reason, errorCode: failure.errorCode, errorMessage: failure.displayMessage));
      },
      (channels) => emit(CorporateWalletChannelsLoadedState(channels: channels)),
    );
  }

  Future<void> _requestOtpHandler(CorporateWalletRequestOtpEvent event, Emitter<CorporateWalletState> emit) async {
    if (_isRequestingOtp) return;

    _isRequestingOtp = true;
    emit(CorporateWalletOtpRequestLoadingState(channels: state.channels));

    final input = RequestCorporateWalletOtpInput(event.channel.method, event.channel.recipientId);
    final result = await _requestOtp.execute(input);
    _isRequestingOtp = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        final reason = CorporateWalletFailureReason.fromException(failure);
        _logger.logBusiness(input: input.toLog(), exception: failure, action: 'request_otp', feature: 'corporate_wallet', reason: reason.name);
        emit(CorporateWalletOtpRequestErrorState(channels: state.channels, reason: reason, errorCode: failure.errorCode, errorMessage: failure.displayMessage));
      },
      (challenge) => emit(CorporateWalletOtpRequestedState(channels: state.channels, challenge: challenge)),
    );
  }
}

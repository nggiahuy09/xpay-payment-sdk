part of 'corporate_wallet_otp_bloc.dart';

@immutable
sealed class CorporateWalletOtpState with Equatable {
  const CorporateWalletOtpState({
    required List<CorporateWalletOtpChannelEntity> channels,
    required this.challenge,
    this.rejection,
    this.resendCooldownUntil,
    this.code = '',
    this.attemptsRemaining,
  }) : _channels = channels;

  static const int otpLength = 6;

  final List<CorporateWalletOtpChannelEntity> _channels;
  final CorporateWalletChallengeEntity challenge;
  final CorporateWalletFailureReason? rejection;
  final DateTime? resendCooldownUntil;
  final String code;
  final int? attemptsRemaining;

  List<CorporateWalletOtpChannelEntity> get channels => List.unmodifiable(_channels);

  CorporateWalletOtpChannelEntity? get currentChannel => _channels.firstWhereOrNull(_isCurrentChannel);

  List<CorporateWalletOtpChannelEntity> get otherChannels => _channels.where((channel) => !_isCurrentChannel(channel)).toList();

  bool get canChangeChannel => otherChannels.isNotEmpty;

  bool get canSubmit => code.length == otpLength && !(rejection?.isCodeUnusable ?? false) && !challenge.isCodeExpired;

  bool get isResendOnCooldown => resendCooldownUntil?.isAfter(DateTime.now()) ?? false;

  bool _isCurrentChannel(CorporateWalletOtpChannelEntity channel) => channel.isSameAs(method: challenge.method, recipientId: challenge.recipientId);

  @override
  List<Object?> get props => [_channels, challenge, rejection, resendCooldownUntil, code, attemptsRemaining];
}

final class CorporateWalletOtpInitState extends CorporateWalletOtpState {
  const CorporateWalletOtpInitState({required super.channels, required super.challenge, super.resendCooldownUntil, super.attemptsRemaining});
}

final class CorporateWalletOtpCodeChangedState extends CorporateWalletOtpState {
  const CorporateWalletOtpCodeChangedState({
    required super.channels,
    required super.challenge,
    super.rejection,
    super.resendCooldownUntil,
    required super.code,
    super.attemptsRemaining,
  });
}

final class CorporateWalletOtpSubmitLoadingState extends CorporateWalletOtpState {
  const CorporateWalletOtpSubmitLoadingState({
    required super.channels,
    required super.challenge,
    super.resendCooldownUntil,
    required super.code,
    super.attemptsRemaining,
  });
}

final class CorporateWalletOtpRejectedState extends CorporateWalletOtpState {
  const CorporateWalletOtpRejectedState({
    required super.channels,
    required super.challenge,
    required super.rejection,
    super.resendCooldownUntil,
    super.attemptsRemaining,
  }) : super(code: '');
}

final class CorporateWalletOtpVerifiedState extends CorporateWalletOtpState {
  const CorporateWalletOtpVerifiedState({required super.channels, required super.challenge, required super.code, required this.payment});

  final CorporateWalletPaymentEntity payment;

  @override
  List<Object?> get props => [...super.props, payment];
}

final class CorporateWalletOtpVerifyErrorState extends CorporateWalletOtpState {
  const CorporateWalletOtpVerifyErrorState({
    required super.channels,
    required super.challenge,
    super.resendCooldownUntil,
    required super.code,
    super.attemptsRemaining,
    required this.reason,
    this.errorCode,
    this.errorMessage,
    required this.isConflict,
  });

  final CorporateWalletFailureReason reason;
  final String? errorCode;
  final String? errorMessage;
  final bool isConflict;

  @override
  List<Object?> get props => [...super.props, reason, errorCode, errorMessage, isConflict];
}

final class CorporateWalletOtpCodeExpiredState extends CorporateWalletOtpState {
  const CorporateWalletOtpCodeExpiredState({required super.channels, required super.challenge, super.resendCooldownUntil, super.attemptsRemaining})
    : super(rejection: CorporateWalletFailureReason.otpExpired, code: '');
}

final class CorporateWalletOtpResendLoadingState extends CorporateWalletOtpState {
  const CorporateWalletOtpResendLoadingState({
    required super.channels,
    required super.challenge,
    super.rejection,
    super.resendCooldownUntil,
    required super.code,
    super.attemptsRemaining,
    required this.isSwitchingChannel,
  });

  final bool isSwitchingChannel;

  @override
  List<Object?> get props => [...super.props, isSwitchingChannel];
}

final class CorporateWalletOtpResendSentState extends CorporateWalletOtpState {
  const CorporateWalletOtpResendSentState({required super.channels, required super.challenge, super.resendCooldownUntil, super.attemptsRemaining}) : super(code: '');
}

final class CorporateWalletOtpResendErrorState extends CorporateWalletOtpState {
  const CorporateWalletOtpResendErrorState({
    required super.channels,
    required super.challenge,
    super.rejection,
    super.resendCooldownUntil,
    required super.code,
    super.attemptsRemaining,
    required this.reason,
    this.errorCode,
    this.errorMessage,
  });

  final CorporateWalletFailureReason reason;
  final String? errorCode;
  final String? errorMessage;

  @override
  List<Object?> get props => [...super.props, reason, errorCode, errorMessage];
}

final class CorporateWalletOtpResendCooldownEndedState extends CorporateWalletOtpState {
  const CorporateWalletOtpResendCooldownEndedState({
    required super.channels,
    required super.challenge,
    super.rejection,
    required super.code,
    super.attemptsRemaining,
  });
}

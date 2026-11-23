part of 'corporate_wallet_otp_bloc.dart';

@immutable
sealed class CorporateWalletOtpEvent {
  const CorporateWalletOtpEvent();
}

final class CorporateWalletOtpChangeCodeEvent extends CorporateWalletOtpEvent {
  const CorporateWalletOtpChangeCodeEvent(this.code);

  final String code;
}

final class CorporateWalletOtpSubmitEvent extends CorporateWalletOtpEvent {
  const CorporateWalletOtpSubmitEvent();
}

final class CorporateWalletOtpCodeExpiredEvent extends CorporateWalletOtpEvent {
  const CorporateWalletOtpCodeExpiredEvent();
}

final class CorporateWalletOtpResendEvent extends CorporateWalletOtpEvent {
  const CorporateWalletOtpResendEvent();
}

final class CorporateWalletOtpChangeChannelEvent extends CorporateWalletOtpEvent {
  const CorporateWalletOtpChangeChannelEvent(this.channel);

  final CorporateWalletOtpChannelEntity channel;
}

final class CorporateWalletOtpResendCooldownEndedEvent extends CorporateWalletOtpEvent {
  const CorporateWalletOtpResendCooldownEndedEvent();
}

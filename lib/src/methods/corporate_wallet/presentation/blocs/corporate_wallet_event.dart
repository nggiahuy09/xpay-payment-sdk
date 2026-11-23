part of 'corporate_wallet_bloc.dart';

@immutable
sealed class CorporateWalletEvent {
  const CorporateWalletEvent();
}

final class CorporateWalletLoadChannelsEvent extends CorporateWalletEvent {
  const CorporateWalletLoadChannelsEvent();
}

final class CorporateWalletRequestOtpEvent extends CorporateWalletEvent {
  const CorporateWalletRequestOtpEvent(this.channel);

  final CorporateWalletOtpChannelEntity channel;
}

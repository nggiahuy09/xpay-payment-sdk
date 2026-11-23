part of 'corporate_wallet_bloc.dart';

@immutable
sealed class CorporateWalletState with Equatable {
  const CorporateWalletState({required List<CorporateWalletOtpChannelEntity> channels}) : _channels = channels;

  final List<CorporateWalletOtpChannelEntity> _channels;

  List<CorporateWalletOtpChannelEntity> get channels => List.unmodifiable(_channels);

  @override
  List<Object?> get props => [_channels];
}

final class CorporateWalletInitState extends CorporateWalletState {
  const CorporateWalletInitState() : super(channels: const []);
}

final class CorporateWalletChannelsLoadingState extends CorporateWalletState {
  const CorporateWalletChannelsLoadingState({required super.channels});
}

final class CorporateWalletChannelsLoadedState extends CorporateWalletState {
  const CorporateWalletChannelsLoadedState({required super.channels});
}

final class CorporateWalletChannelsLoadErrorState extends CorporateWalletState {
  const CorporateWalletChannelsLoadErrorState({required this.reason, this.errorCode, this.errorMessage}) : super(channels: const []);

  final CorporateWalletFailureReason reason;
  final String? errorCode;
  final String? errorMessage;

  @override
  List<Object?> get props => [...super.props, reason, errorCode, errorMessage];
}

final class CorporateWalletOtpRequestLoadingState extends CorporateWalletState {
  const CorporateWalletOtpRequestLoadingState({required super.channels});
}

final class CorporateWalletOtpRequestedState extends CorporateWalletState {
  const CorporateWalletOtpRequestedState({required super.channels, required this.challenge});

  final CorporateWalletChallengeEntity challenge;

  @override
  List<Object?> get props => [...super.props, challenge];
}

final class CorporateWalletOtpRequestErrorState extends CorporateWalletState {
  const CorporateWalletOtpRequestErrorState({required super.channels, required this.reason, this.errorCode, this.errorMessage});

  final CorporateWalletFailureReason reason;
  final String? errorCode;
  final String? errorMessage;

  @override
  List<Object?> get props => [...super.props, reason, errorCode, errorMessage];
}

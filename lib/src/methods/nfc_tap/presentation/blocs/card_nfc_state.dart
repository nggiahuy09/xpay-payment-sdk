part of 'card_nfc_bloc.dart';

@immutable
sealed class CardNfcState with Equatable {
  const CardNfcState(this.isEnabled);

  final bool isEnabled;

  @override
  List<Object?> get props => [isEnabled];
}

sealed class CardNfcFailureState extends CardNfcState {
  const CardNfcFailureState(super.isEnabled);
}

final class CardNfcInitState extends CardNfcState {
  const CardNfcInitState() : super(false);
}

final class CardNfcEnableChangedState extends CardNfcState {
  const CardNfcEnableChangedState(super.isEnabled);
}

final class CardNfcRetryingState extends CardNfcState {
  const CardNfcRetryingState(super.isEnabled);
}

final class CardNfcRetryEligibleState extends CardNfcState {
  const CardNfcRetryEligibleState(super.isEnabled);
}

/// The tag's UID has been read and the tap is being prepared against the broker.
final class CardNfcPrepareLoadingState extends CardNfcState {
  const CardNfcPrepareLoadingState(super.isEnabled, this.chipUid);

  final String chipUid;

  @override
  List<Object?> get props => [...super.props, chipUid];
}

/// The chip's token sector matched the issuer's record, so the card is genuine and the tap may proceed to advance the counter.
final class CardNfcCardVerifiedState extends CardNfcState {
  const CardNfcCardVerifiedState(super.isEnabled, this.prepare);

  final ChipTapPrepareEntity prepare;

  @override
  List<Object?> get props => [...super.props, prepare];
}

/// The chip was reachable but did not match the issuer's record, or could not be read.
///
/// Nothing has been written at this point, so the card is untouched — the tap is simply abandoned.
final class CardNfcCardRejectedState extends CardNfcFailureState {
  const CardNfcCardRejectedState(super.isEnabled, this.verification);

  final ChipTapVerification verification;

  @override
  List<Object?> get props => [...super.props, verification];
}

/// The counter has been advanced on the chip and read back, and the broker is signing it.
final class CardNfcSigningState extends CardNfcState {
  const CardNfcSigningState(super.isEnabled, this.counter);

  final int counter;

  @override
  List<Object?> get props => [...super.props, counter];
}

/// The tap is signed and ready to authorize.
///
/// Past this point the card is no longer needed — the remaining calls are pure API work.
final class CardNfcTapSignedState extends CardNfcState {
  const CardNfcTapSignedState(super.isEnabled, this.cryptogram);

  final ChipTapCryptogramEntity cryptogram;

  @override
  List<Object?> get props => [...super.props, cryptogram];
}

/// The counter could not be advanced, or the advance could not be confirmed by a read-back.
///
/// Deliberately distinct from a signing failure: here nothing was presented to the server, and whether the write landed is unknown — which is safe, because an
/// unconfirmed increment only ever leaves the card ahead of the server.
final class CardNfcCounterFailedState extends CardNfcFailureState {
  const CardNfcCounterFailedState(super.isEnabled);
}

/// The broker refused to sign the counter presented.
///
/// [reason] resolves the broker's error code once, here, so the view renders copy without re-reading [XPException.errorCode] itself.
final class CardNfcSignErrorState extends CardNfcFailureState {
  CardNfcSignErrorState(super.isEnabled, this.failure) : reason = ChipTapCryptogramFailureReason.fromErrorCode(failure.errorCode);

  final XPException failure;
  final ChipTapCryptogramFailureReason reason;

  @override
  List<Object?> get props => [...super.props, failure, reason];
}

/// A failed prepare. Nothing has touched the chip at this point, so the tap can simply be abandoned.
///
/// [reason] resolves the broker's error code once, here, so the view renders copy without re-reading [XPException.errorCode] itself.
final class CardNfcPrepareLoadErrorState extends CardNfcFailureState {
  CardNfcPrepareLoadErrorState(super.isEnabled, this.failure) : reason = ChipTapPrepareFailureReason.fromErrorCode(failure.errorCode);

  final XPException failure;
  final ChipTapPrepareFailureReason reason;

  @override
  List<Object?> get props => [...super.props, failure, reason];
}

/// The handset read the tag but cannot drive it with Crypto1, so the tap can never complete on this device.
final class CardNfcUnsupportedTagState extends CardNfcFailureState {
  const CardNfcUnsupportedTagState(super.isEnabled, this.chipUid);

  final String chipUid;

  @override
  List<Object?> get props => [...super.props, chipUid];
}

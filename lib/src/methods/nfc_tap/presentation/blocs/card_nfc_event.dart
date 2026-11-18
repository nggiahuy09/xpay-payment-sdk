part of 'card_nfc_bloc.dart';

@immutable
sealed class CardNfcEvent {
  const CardNfcEvent();
}

final class CardNfcCheckEnablingEvent extends CardNfcEvent {
  const CardNfcCheckEnablingEvent();
}

final class CardNfcAttemptRetryEvent extends CardNfcEvent {
  const CardNfcAttemptRetryEvent();
}

/// Dispatched once the tag's UID has been read off the chip, to exchange it for this tap's key bundle and verify the card against the issuer's record.
///
/// [tag] is carried through so the handler can read the token sector with the keys the broker returns. It is only valid while the NFC session that discovered it
/// is still open, so the view must not stop the session before this event has been handled.
final class CardNfcTagDetectedEvent extends CardNfcEvent {
  const CardNfcTagDetectedEvent({required this.tag, required this.chipUid, required this.isMifareClassic});

  final NfcTag tag;
  final String chipUid;
  final bool isMifareClassic;
}

/// Dispatched by the bloc once the broker has handed back this tap's key bundle, to read the chip's token sector and compare it against the issuer's record.
///
/// [prepare] is carried on the event rather than read back off the state, so the handler never has to type-check which state the flow is currently in.
final class _CardNfcCardVerifyEvent extends CardNfcEvent {
  const _CardNfcCardVerifyEvent({required this.tag, required this.prepare});

  final NfcTag tag;
  final ChipTapPrepareEntity prepare;
}

/// Dispatched by the bloc once the card has been proven genuine, to advance the on-card counter and have the broker sign the value read back.
final class _CardNfcCounterAdvanceEvent extends CardNfcEvent {
  const _CardNfcCounterAdvanceEvent({required this.tag, required this.prepare});

  final NfcTag tag;
  final ChipTapPrepareEntity prepare;
}

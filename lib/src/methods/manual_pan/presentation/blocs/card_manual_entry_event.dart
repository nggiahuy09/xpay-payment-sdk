part of 'card_manual_entry_bloc.dart';

@immutable
sealed class CardManualEntryEvent {
  const CardManualEntryEvent();
}

final class CardManualEntryPanChangedEvent extends CardManualEntryEvent {
  const CardManualEntryPanChangedEvent(this.pan);

  final String pan;
}

// final class CardManualEntryExpiryChangedEvent extends CardManualEntryEvent {
//   const CardManualEntryExpiryChangedEvent(this.expiry, this.now);

//   final DateTime now;
//   final String expiry;
// }

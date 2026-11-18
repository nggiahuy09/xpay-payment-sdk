part of 'card_manual_entry_bloc.dart';

@immutable
final class CardManualEntryState with Equatable {
  const CardManualEntryState({required this.panStatus, required this.expiryValid});

  const CardManualEntryState.initial() : this(panStatus: CardManualPanStatus.empty, expiryValid: false);

  final CardManualPanStatus panStatus;
  final bool expiryValid;

  // bool get canSubmit => panStatus == CardManualPanStatus.valid && expiryValid;
  bool get canSubmit => panStatus == CardManualPanStatus.valid;

  CardManualEntryState _copyWith({CardManualPanStatus? panStatus, bool? expiryValid}) {
    return CardManualEntryState(panStatus: panStatus ?? this.panStatus, expiryValid: expiryValid ?? this.expiryValid);
  }

  @override
  List<Object?> get props => [panStatus, expiryValid];
}

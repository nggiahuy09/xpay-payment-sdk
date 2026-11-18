import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/helpers/helpers.dart';
import '../../domain/entities/card_manual_pan_status_enum.dart';

part 'card_manual_entry_event.dart';
part 'card_manual_entry_state.dart';

final class CardManualEntryBloc extends Bloc<CardManualEntryEvent, CardManualEntryState> {
  CardManualEntryBloc() : super(const CardManualEntryState.initial()) {
    on<CardManualEntryPanChangedEvent>(_panChangedHandler);
    // on<CardManualEntryExpiryChangedEvent>(_expiryChangedHandler);
  }

  void _panChangedHandler(CardManualEntryPanChangedEvent event, Emitter<CardManualEntryState> emit) {
    emit(state._copyWith(panStatus: _resolvePanStatus(event.pan)));
  }

  // void _expiryChangedHandler(CardManualEntryExpiryChangedEvent event, Emitter<CardManualEntryState> emit) {
  //   emit(state._copyWith(expiryValid: XPHelperCardManualPanValidator.isExpiryValid(event.expiry, now: event.now)));
  // }

  /// Maps the raw PAN to its real-time validation status via a Luhn check.
  /// Anything non-empty that is not a complete, Luhn-valid number is flagged as
  /// invalid immediately — including partially typed numbers.
  CardManualPanStatus _resolvePanStatus(String pan) {
    if (XPHelperCardManualPanValidator.onlyDigits(pan).isEmpty) return CardManualPanStatus.empty;

    return XPHelperCardManualPanValidator.isValid(pan) ? CardManualPanStatus.valid : CardManualPanStatus.invalid;
  }
}

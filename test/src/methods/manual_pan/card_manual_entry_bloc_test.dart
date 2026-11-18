import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/src/methods/manual_pan/domain/entities/card_manual_pan_status_enum.dart';
import 'package:xpay_payment_sdk/src/methods/manual_pan/presentation/blocs/card_manual_entry_bloc.dart';

Future<CardManualEntryState> _enter(String pan) async {
  final bloc = CardManualEntryBloc();
  final next = bloc.stream.first;
  bloc.add(CardManualEntryPanChangedEvent(pan));
  final state = await next;
  await bloc.close();
  return state;
}

void main() {
  test('a Luhn-valid number of an accepted length can be submitted, spaces included', () async {
    final state = await _enter('4111 1111 1111 1111');

    expect(state.panStatus, CardManualPanStatus.valid);
    expect(state.canSubmit, isTrue);
  });

  test('a number failing Luhn, or outside 12 to 16 digits, is flagged as invalid', () async {
    for (final pan in ['4111111111111112', '41111111111', '41111111111111111']) {
      final state = await _enter(pan);

      expect(state.panStatus, CardManualPanStatus.invalid, reason: pan);
      expect(state.canSubmit, isFalse, reason: pan);
    }
  });

  test('an input with no digits shows no feedback', () async {
    final state = await _enter('  ');

    expect(state.panStatus, CardManualPanStatus.empty);
    expect(state.canSubmit, isFalse);
  });
}

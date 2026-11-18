import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_authorize_entity.dart';
import 'package:xpay_payment_sdk/src/core/presentation/verification/blocs/verification_bloc.dart';

final _codeExpiresAt = DateTime(2026, 9, 28, 10, 5);
final _sessionDeadline = DateTime(2026, 9, 28, 10, 10);

VerificationState _stateOf(PaymentAuthorizeVerificationMethod method, {DateTime? expiresAt, DateTime? verificationDeadline}) => VerificationInitState(
  verification: PaymentAuthorizeVerificationEntity(method: method, expiresAt: expiresAt, verificationDeadline: verificationDeadline),
  amount: 10000.0,
);

void main() {
  group('countdownDeadline', () {
    test('an SMS code counts down to the session deadline rather than its own expiry, so reaching zero is the end of the sale', () {
      final state = _stateOf(PaymentAuthorizeVerificationMethod.smsOtp, expiresAt: _codeExpiresAt, verificationDeadline: _sessionDeadline);

      expect(state.countdownDeadline, _sessionDeadline);
    });

    test('an SMS code resent close to the cutoff still counts down to the session deadline, never past it', () {
      final state = _stateOf(PaymentAuthorizeVerificationMethod.smsOtp, expiresAt: _sessionDeadline.add(const Duration(minutes: 3)), verificationDeadline: _sessionDeadline);

      expect(state.countdownDeadline, _sessionDeadline);
    });

    for (final method in const [PaymentAuthorizeVerificationMethod.staticCode, PaymentAuthorizeVerificationMethod.tokenPin]) {
      test('a ${method.name} counts down to whichever of its code window and the session deadline closes first', () {
        final codeFirst = _stateOf(method, expiresAt: _codeExpiresAt, verificationDeadline: _sessionDeadline);
        final deadlineFirst = _stateOf(method, expiresAt: _sessionDeadline.add(const Duration(minutes: 3)), verificationDeadline: _sessionDeadline);

        expect(codeFirst.countdownDeadline, _codeExpiresAt);
        expect(deadlineFirst.countdownDeadline, _sessionDeadline);
      });
    }

    test('a payload without the session deadline, such as a resumed payment, falls back to the code expiry', () {
      final state = _stateOf(PaymentAuthorizeVerificationMethod.smsOtp, expiresAt: _codeExpiresAt);

      expect(state.countdownDeadline, _codeExpiresAt);
    });

    test('a payload without the code expiry falls back to the session deadline', () {
      final state = _stateOf(PaymentAuthorizeVerificationMethod.staticCode, verificationDeadline: _sessionDeadline);

      expect(state.countdownDeadline, _sessionDeadline);
    });

    test('a payload dating neither moment has nothing to count down to', () {
      expect(_stateOf(PaymentAuthorizeVerificationMethod.smsOtp).countdownDeadline, isNull);
    });
  });
}

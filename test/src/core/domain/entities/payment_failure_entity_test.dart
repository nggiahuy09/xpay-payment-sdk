import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/src/base/define/constant/constant.dart';
import 'package:xpay_payment_sdk/src/base/localization/locale/locale_en/locale_en.dart';
import 'package:xpay_payment_sdk/src/base/localization/locale/locale_vi/locale_vi.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_decline_reason.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_failure_entity.dart';

void main() {
  group('declines', () {
    test('a card problem the driver can fix with another card is retried in the SDK', () {
      for (final reason in [
        PaymentDeclineReason.insufficientFunds,
        PaymentDeclineReason.cardInactive,
        PaymentDeclineReason.cardBlocked,
        PaymentDeclineReason.cardExpired,
        PaymentDeclineReason.dailyLimitExceeded,
        PaymentDeclineReason.velocityLimitExceeded,
        PaymentDeclineReason.verificationExpired,
        PaymentDeclineReason.cardLockedTooManyAttempts,
        PaymentDeclineReason.chipCounterReplay,
      ]) {
        expect(PaymentFailureKind.fromDecline(reason).route, PaymentFailureRoute.retryInSdk, reason: reason.name);
        expect(PaymentFailureKind.fromDecline(reason).reason, PaymentFailureReason.paymentDeclined, reason: reason.name);
      }
    });

    test('a company decision or a broken wallet service needs the hotline', () {
      for (final reason in [
        PaymentDeclineReason.corporateMonthlyLimitExceeded,
        PaymentDeclineReason.policyViolation,
        PaymentDeclineReason.employeePolicyViolation,
        PaymentDeclineReason.employeePolicyUnavailable,
        PaymentDeclineReason.servicePaymentUnavailable,
        PaymentDeclineReason.servicePaymentInFlight,
        PaymentDeclineReason.servicePaymentDuplicateOrder,
      ]) {
        expect(PaymentFailureKind.fromDecline(reason).route, PaymentFailureRoute.callHotline, reason: reason.name);
      }
    });

    test('a custom decline reason the SDK does not know goes to the hotline, as does a missing one', () {
      expect(PaymentFailureKind.fromDecline(PaymentDeclineReason.unknown), PaymentFailureKind.corporatePolicyRejected);
      expect(PaymentFailureKind.fromDecline(null), PaymentFailureKind.corporatePolicyRejected);
    });
  });

  group('error codes', () {
    test('a ride already settled is checked against the ride instead of shown', () {
      for (final code in ['ride_already_paid', 'ride_not_found', 'verification_not_pending']) {
        expect(PaymentFailureKind.fromErrorCode(code).route, PaymentFailureRoute.checkRide, reason: code);
      }
    });

    test('a changed fare or a broken session is retried from the partner checkout', () {
      expect(PaymentFailureKind.fromErrorCode('ride_payment_session_revoked'), PaymentFailureKind.fareChanged);
      expect(PaymentFailureKind.fromConflictCode('amount_locked'), PaymentFailureKind.fareChanged);
      expect(PaymentFailureKind.fromErrorCode('amount_locked'), PaymentFailureKind.integrationError);
      expect(PaymentFailureKind.fromConflictCode(null), PaymentFailureKind.integrationError);
      expect(PaymentFailureKind.fromConflictCode('ride_already_paid'), PaymentFailureKind.rideAlreadyPaid);
      expect(PaymentFailureKind.fromErrorCode(XPErrorCodes.sessionAmountChanged), PaymentFailureKind.fareChanged);
      expect(PaymentFailureKind.fromErrorCode('ride_payment_session_invalid'), PaymentFailureKind.sessionInvalid);
      expect(PaymentFailureKind.fromErrorCode('ride_payment_session_expired'), PaymentFailureKind.sessionUnavailable);
      expect(PaymentFailureKind.fromErrorCode('idempotency_conflict'), PaymentFailureKind.integrationError);
      for (final kind in [PaymentFailureKind.fareChanged, PaymentFailureKind.sessionInvalid, PaymentFailureKind.sessionUnavailable, PaymentFailureKind.integrationError]) {
        expect(kind.route, PaymentFailureRoute.retryInPartner, reason: kind.name);
      }
    });

    test('a code that expired with no new one to send is paid again in the SDK', () {
      expect(PaymentFailureKind.fromErrorCode('otp_expired'), PaymentFailureKind.verificationExpired);
      expect(PaymentFailureKind.verificationExpired.route, PaymentFailureRoute.retryInSdk);
    });

    test('the wrong method screen switches to the right one', () {
      expect(PaymentFailureKind.fromErrorCode('ride_on_corporate_wallet').route, PaymentFailureRoute.switchMethod);
      expect(PaymentFailureKind.fromErrorCode('ride_not_on_corporate_wallet').route, PaymentFailureRoute.switchMethod);
    });

    test('system errors, retries that ran out and unknown codes need the hotline', () {
      for (final code in [
        'internal_error',
        'no_connection',
        'timeout',
        'rate_limited',
        'request_in_flight',
        'corporate_wallet_refused',
        'corporate_wallet_unavailable',
        'unauthorized',
        'brand_new_code',
        null,
      ]) {
        expect(PaymentFailureKind.fromErrorCode(code).route, PaymentFailureRoute.callHotline, reason: '$code');
      }
    });
  });

  group('copy', () {
    test('every failure shown to the driver has a body in both languages', () {
      for (final kind in PaymentFailureKind.values) {
        final isShown = switch (kind.route) {
          PaymentFailureRoute.retryInSdk || PaymentFailureRoute.retryInPartner || PaymentFailureRoute.callHotline => true,
          PaymentFailureRoute.switchMethod || PaymentFailureRoute.checkRide => false,
        };
        expect(kind.getBody(const XPLocaleEN()) != null, isShown, reason: kind.name);
        expect(kind.getBody(const XPLocaleVI()) != null, isShown, reason: kind.name);
      }
    });
  });

  test('three failed retries keep the trail but call the hotline', () {
    const failure = PaymentFailureEntity(kind: PaymentFailureKind.insufficientFunds, authId: 'auth-1', errorCode: 'insufficient_funds');

    final exhausted = failure.toRetriesExhausted();

    expect(exhausted.kind, PaymentFailureKind.retriesExhausted);
    expect(exhausted.route, PaymentFailureRoute.callHotline);
    expect(exhausted.authId, 'auth-1');
    expect(exhausted.errorCode, 'insufficient_funds');
  });
}

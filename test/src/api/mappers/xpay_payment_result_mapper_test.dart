import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/src/api/mappers/xpay_payment_result_mapper.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_checkout_result_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_failure_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/ride_payment_status_entity.dart';
import 'package:xpay_payment_sdk/xpay_payment_sdk.dart';

final _createdAt = DateTime(2026, 11, 2, 9, 30);

void main() {
  group('paid', () {
    test('a payment taken at the car carries the authorization and the partner as payer', () {
      final result = PaymentCheckoutPaidResultEntity(
        PaymentCheckoutPaymentEntity(
          paidBy: RidePaymentPayer.partner,
          createdAt: _createdAt,
          authId: 'auth-1',
          captureId: 'cap-1',
          currency: 'VND',
          externalRef: 'XP-1048',
          amount: '138000.00',
        ),
      ).toResult();

      expect(result.status, XPayPaymentStatus.paid);
      expect(result.paidBy, XPayPaidBy.partner);
      expect(result.authId, 'auth-1');
      expect(result.captureId, 'cap-1');
      expect(result.currency, 'VND');
      expect(result.externalRef, 'XP-1048');
      expect(result.amount, 138000);
      expect(result.createdAt, _createdAt);
      expect(result.failure, isNull);
      expect(result.isSuccessful, isTrue);
      expect(result.isRetryable, isFalse);
    });

    test('a payment the hotline made keeps the amount it charged, and a wallet payment has no auth id', () {
      final result = const PaymentCheckoutPaidResultEntity(PaymentCheckoutPaymentEntity(paidBy: RidePaymentPayer.cs, amount: '120000.00')).toResult();

      expect(result.status, XPayPaymentStatus.paid);
      expect(result.paidBy, XPayPaidBy.cs);
      expect(result.authId, isNull);
      expect(result.amount, 120000);
    });
  });

  group('failures', () {
    test('back to checkout is retryable and reports the SDK reason', () {
      final result = const PaymentCheckoutRetryInPartnerResultEntity(
        PaymentFailureEntity(kind: PaymentFailureKind.sessionInvalid, errorCode: 'ride_payment_session_invalid'),
      ).toResult();

      expect(result.status, XPayPaymentStatus.retryInPartner);
      expect(result.isRetryable, isTrue);
      expect(result.failure?.reason, XPayFailureReason.sdkError);
      expect(result.failure?.reason.toRemote(), 'sdk_error');
      expect(result.failure?.errorCode, 'ride_payment_session_invalid');
      expect(result.failure?.note, 'ride_payment_session_invalid');
    });

    test('a fare change is reported as other with the fare note', () {
      final result = const PaymentCheckoutRetryInPartnerResultEntity(PaymentFailureEntity(kind: PaymentFailureKind.fareChanged, errorCode: 'amount_locked')).toResult();

      expect(result.failure?.reason, XPayFailureReason.other);
      expect(result.failure?.reason.toRemote(), 'other');
      expect(result.failure?.note, 'cước đổi');
    });

    test('another method keeps the declined transaction and the one still waiting for its code', () {
      final result = const PaymentCheckoutOtherMethodResultEntity(
        PaymentFailureEntity(kind: PaymentFailureKind.retriesExhausted, authId: 'auth-declined', errorCode: 'insufficient_funds', pendingAuthId: 'auth-pending'),
      ).toResult();

      expect(result.status, XPayPaymentStatus.otherMethod);
      expect(result.isRetryable, isFalse);
      expect(result.failure?.reason, XPayFailureReason.paymentDeclined);
      expect(result.failure?.authId, 'auth-declined');
      expect(result.failure?.note, isNull);
      expect(result.pendingAuthId, 'auth-pending');
    });

    test('the hotline timing out is always reported as declined with the waiting note', () {
      final result = const PaymentCheckoutHotlinePendingResultEntity(
        PaymentFailureEntity(kind: PaymentFailureKind.systemError, authId: 'auth-declined', errorCode: 'internal_error'),
      ).toResult();

      expect(result.status, XPayPaymentStatus.csPending);
      expect(result.isRetryable, isFalse);
      expect(result.failure?.reason, XPayFailureReason.paymentDeclined);
      expect(result.failure?.authId, 'auth-declined');
      expect(result.failure?.note, 'chờ tổng đài quá 5 phút');
    });
  });

  group('neutral endings', () {
    test('a closed ride reports how it ended and nothing to collect', () {
      expect(const PaymentCheckoutRideClosedResultEntity(RideSettlement.closedWithoutPayment).toResult().rideStatus, XPayRideStatus.completed);
      expect(const PaymentCheckoutRideClosedResultEntity(RideSettlement.cancelled).toResult().rideStatus, XPayRideStatus.cancelled);
      expect(const PaymentCheckoutRideClosedResultEntity(RideSettlement.cancelled).toResult().status, XPayPaymentStatus.rideClosed);
      expect(const PaymentCheckoutRideClosedResultEntity(RideSettlement.cancelled).toResult().isRetryable, isFalse);
    });

    test('a cancelled payment is retryable and hands back the transaction waiting for its code', () {
      final result = const PaymentCheckoutCancelledResultEntity('auth-pending').toResult();

      expect(result.status, XPayPaymentStatus.cancelled);
      expect(result.isRetryable, isTrue);
      expect(result.pendingAuthId, 'auth-pending');
      expect(result.failure, isNull);
    });

    test('an SDK that cannot open reports its own code as an SDK error', () {
      final result = const PaymentCheckoutUnavailableResultEntity(XPayErrorCode.busy).toResult();

      expect(result.status, XPayPaymentStatus.unavailable);
      expect(result.isRetryable, isFalse);
      expect(result.errorCode, XPayErrorCode.busy);
      expect(result.failure?.reason, XPayFailureReason.sdkError);
      expect(result.failure?.note, XPayErrorCode.busy);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/src/api/mappers/xpay_payment_result_mapper.dart';
import 'package:xpay_payment_sdk/src/base/localization/locale/locale_en/locale_en.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/create_payment_authorize_failure_reason_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_authorize_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_decline_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_entry_mode_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_flow_outcome_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_verify_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_verify_result_entity.dart';
import 'package:xpay_payment_sdk/xpay_payment_sdk.dart';

const _locale = XPLocaleEN();

final _createdAt = DateTime(2026, 11, 2, 9, 30);

XPayPaymentResult _map(PaymentFlowOutcomeEntity outcome) => outcome.toResult(_locale, canTapCard: true);

PaymentFlowAuthorizedOutcomeEntity _authorized(PaymentAuthorizeEntity authorize) => PaymentFlowAuthorizedOutcomeEntity(authorize: authorize, entryMode: PaymentEntryMode.cardQr);

PaymentFlowVerifiedOutcomeEntity _verified(PaymentVerifyEntity verify, PaymentVerifyOutcome outcome) => PaymentFlowVerifiedOutcomeEntity(
  result: PaymentVerifyResultEntity(verify: verify, outcome: outcome),
  entryMode: PaymentEntryMode.manualPan,
  authId: 'auth-1',
);

void main() {
  group('authorize outcomes', () {
    test('approved carries the authorization, without a capture', () {
      final result = _map(
        _authorized(
          PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.approved, createdAt: _createdAt, authId: 'auth-1', externalRef: 'ACME_1234', amount: '100000', currency: 'VND'),
        ),
      );

      expect(result.status, XPayPaymentStatus.approved);
      expect(result.authId, 'auth-1');
      expect(result.captureId, isNull);
      expect(result.externalRef, 'ACME_1234');
      expect(result.amount, 100000);
      expect(result.currency, 'VND');
      expect(result.createdAt, _createdAt);
      expect(result.isSuccessful, isTrue);
    });

    test('captured adds the capture id', () {
      final result = _map(_authorized(const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.captured, authId: 'auth-1', captureId: 'cap-1', amount: '100000.00')));

      expect(result.status, XPayPaymentStatus.captured);
      expect(result.captureId, 'cap-1');
      expect(result.amount, 100000);
    });

    test('declined carries the raw code and the localized reason', () {
      final result = _map(
        _authorized(PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.declined, authId: 'auth-1', declineReason: PaymentDeclineEntity.fromRemote('insufficient_funds'))),
      );

      expect(result.status, XPayPaymentStatus.declined);
      expect(result.declineCode, 'insufficient_funds');
      expect(result.message, _locale.payment.xpay.decline.insufficientFunds);
      expect(result.isSuccessful, isFalse);
    });

    test('a decline reason wins over an approved status', () {
      final result = _map(_authorized(PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.approved, declineReason: PaymentDeclineEntity.fromRemote('card_blocked'))));

      expect(result.status, XPayPaymentStatus.declined);
    });

    test('a status the flow cannot act on fails with the SDK code, keeping the authorization', () {
      final result = _map(_authorized(const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.voided, authId: 'auth-1')));

      expect(result.status, XPayPaymentStatus.failed);
      expect(result.errorCode, XPayErrorCode.unexpectedResponse);
      expect(result.authId, 'auth-1');
      expect(result.message, _locale.payment.xpay.resultGenericError(XPayErrorCode.unexpectedResponse));
    });
  });

  group('verification outcomes', () {
    test('approved after verification carries the booking reference', () {
      final result = _map(
        _verified(const PaymentVerifyEntity(status: PaymentAuthorizeStatus.approved, bookingRef: 'BK-1', amount: '100000'), PaymentVerifyOutcome.approved),
      );

      expect(result.status, XPayPaymentStatus.approved);
      expect(result.authId, 'auth-1');
      expect(result.bookingRef, 'BK-1');
    });

    test('captured after verification reports captured', () {
      final result = _map(
        _verified(const PaymentVerifyEntity(status: PaymentAuthorizeStatus.captured, authId: 'auth-2', captureId: 'cap-2'), PaymentVerifyOutcome.approved),
      );

      expect(result.status, XPayPaymentStatus.captured);
      expect(result.authId, 'auth-2');
      expect(result.captureId, 'cap-2');
    });

    test('declined after verification carries the reason', () {
      final result = _map(
        _verified(
          PaymentVerifyEntity(status: PaymentAuthorizeStatus.declined, declineReason: PaymentDeclineEntity.fromRemote('card_locked_too_many_attempts')),
          PaymentVerifyOutcome.declined,
        ),
      );

      expect(result.status, XPayPaymentStatus.declined);
      expect(result.declineCode, 'card_locked_too_many_attempts');
      expect(result.message, _locale.payment.xpay.decline.cardLockedTooManyAttempts);
    });

    test('declined without a reason falls back to the generic decline copy', () {
      final result = _map(_verified(const PaymentVerifyEntity(status: PaymentAuthorizeStatus.pendingVerification), PaymentVerifyOutcome.declined));

      expect(result.status, XPayPaymentStatus.declined);
      expect(result.message, _locale.payment.xpay.decline.generic(null));
    });
  });

  group('flow outcomes', () {
    test('cancelled keeps the authorization only when there is one', () {
      expect(_map(const PaymentFlowCancelledOutcomeEntity()).authId, isNull);
      expect(_map(const PaymentFlowCancelledOutcomeEntity('auth-1')), isA<XPayPaymentResult>().having((r) => r.status, 'status', XPayPaymentStatus.cancelled));
      expect(_map(const PaymentFlowCancelledOutcomeEntity('auth-1')).authId, 'auth-1');
    });

    test('duplicate tells the cashier to check before charging again', () {
      final result = _map(const PaymentFlowConflictOutcomeEntity());

      expect(result.status, XPayPaymentStatus.duplicate);
      expect(result.message, _locale.payment.xpay.paymentDuplicateRequestBody);
    });

    test('failed prefers the copy the failure carries, then the generic copy with its code', () {
      final carried = _map(const PaymentFlowFailedOutcomeEntity(displayMessage: 'No internet', errorCode: 'no_connection'));
      final generic = _map(const PaymentFlowFailedOutcomeEntity(errorCode: 'internal_error'));

      expect(carried.status, XPayPaymentStatus.failed);
      expect(carried.message, 'No internet');
      expect(carried.errorCode, 'no_connection');
      expect(generic.message, _locale.payment.xpay.resultGenericError('internal_error'));
    });

    test('authorize failed names the known reason for the entry mode, then falls back to the failure copy', () {
      final notFound = _map(
        const PaymentFlowAuthorizeFailedOutcomeEntity(entryMode: PaymentEntryMode.cardQr, reason: CreatePaymentAuthorizeFailureReason.notFound, errorCode: 'not_found'),
      );
      final carried = _map(
        const PaymentFlowAuthorizeFailedOutcomeEntity(
          entryMode: PaymentEntryMode.manualPan,
          reason: CreatePaymentAuthorizeFailureReason.unknown,
          displayMessage: 'No internet',
          errorCode: 'no_connection',
        ),
      );
      final generic = _map(
        const PaymentFlowAuthorizeFailedOutcomeEntity(entryMode: PaymentEntryMode.manualPan, reason: CreatePaymentAuthorizeFailureReason.unknown, errorCode: 'internal_error'),
      );

      expect(notFound.status, XPayPaymentStatus.failed);
      expect(notFound.errorCode, 'not_found');
      expect(notFound.message, _locale.payment.xpay.paymentCardQrNotFoundBody);
      expect(carried.message, 'No internet');
      expect(generic.message, _locale.payment.xpay.resultGenericError('internal_error'));
    });

    test('expired carries the authorization to start over from', () {
      final result = _map(const PaymentFlowExpiredOutcomeEntity('auth-1'));

      expect(result.status, XPayPaymentStatus.expired);
      expect(result.authId, 'auth-1');
    });

    test('unsupported carries nothing else', () {
      final result = _map(const PaymentFlowUnsupportedOutcomeEntity());

      expect(result.status, XPayPaymentStatus.unsupported);
      expect(result.message, isNull);
    });
  });
}

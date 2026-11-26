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

  group('failure category', () {
    test('successful and neutral outcomes carry no category', () {
      expect(_map(_authorized(const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.captured))).failureCategory, isNull);
      expect(_map(const PaymentFlowWalletCapturedOutcomeEntity()).failureCategory, isNull);
      expect(_map(const PaymentFlowCancelledOutcomeEntity()).failureCategory, isNull);
      expect(_map(const PaymentFlowExpiredOutcomeEntity()).failureCategory, isNull);
      expect(_map(const PaymentFlowUnsupportedOutcomeEntity()).failureCategory, isNull);
    });

    test('a decline is grouped by its reason', () {
      for (final MapEntry(key: code, value: category) in _declineCategories.entries) {
        expect(_map(_declined(code)).failureCategory, category, reason: code);
      }
    });

    test('a verification decline is grouped by its reason', () {
      final result = _map(
        _verified(
          PaymentVerifyEntity(status: PaymentAuthorizeStatus.declined, declineReason: PaymentDeclineEntity.fromRemote('verification_code_invalid')),
          PaymentVerifyOutcome.declined,
        ),
      );

      expect(result.failureCategory, XPayFailureCategory.cardholderChange);
    });

    test('a decline without a known reason is unknown', () {
      expect(_map(_declined('brand_new_reason')).failureCategory, XPayFailureCategory.unknown);
      expect(_map(_verified(const PaymentVerifyEntity(status: PaymentAuthorizeStatus.declined), PaymentVerifyOutcome.declined)).failureCategory, XPayFailureCategory.unknown);
    });

    test('a failure is grouped by its error code', () {
      for (final MapEntry(key: code, value: category) in _errorCategories.entries) {
        expect(_map(PaymentFlowFailedOutcomeEntity(errorCode: code)).failureCategory, category, reason: code);
      }
    });

    test('an authorize failure is grouped by its error code', () {
      for (final MapEntry(key: code, value: category) in _errorCategories.entries) {
        final outcome = PaymentFlowAuthorizeFailedOutcomeEntity(
          entryMode: PaymentEntryMode.cardQr,
          reason: CreatePaymentAuthorizeFailureReason.fromErrorCode(code),
          errorCode: code,
        );
        expect(_map(outcome).failureCategory, category, reason: code);
      }
    });

    test('a status the flow cannot act on is a system failure', () {
      expect(_map(_authorized(const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.voided))).failureCategory, XPayFailureCategory.system);
    });

    test('a wallet decline is a corporate policy failure', () {
      expect(_map(const PaymentFlowWalletDeclinedOutcomeEntity()).failureCategory, XPayFailureCategory.corporatePolicy);
    });

    test('a duplicate is a session failure', () {
      expect(_map(const PaymentFlowConflictOutcomeEntity()).failureCategory, XPayFailureCategory.session);
    });
  });
}

PaymentFlowAuthorizedOutcomeEntity _declined(String code) =>
    _authorized(PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.declined, declineReason: PaymentDeclineEntity.fromRemote(code)));

const _declineCategories = {
  'insufficient_funds': XPayFailureCategory.cardholderChange,
  'card_inactive': XPayFailureCategory.cardholderChange,
  'card_blocked': XPayFailureCategory.cardholderChange,
  'card_expired': XPayFailureCategory.cardholderChange,
  'card_outside_validity_window': XPayFailureCategory.cardholderChange,
  'card_link_inactive': XPayFailureCategory.cardholderChange,
  'per_transaction_limit_exceeded': XPayFailureCategory.corporatePolicy,
  'daily_limit_exceeded': XPayFailureCategory.corporatePolicy,
  'monthly_limit_exceeded': XPayFailureCategory.corporatePolicy,
  'corporate_monthly_limit_exceeded': XPayFailureCategory.corporatePolicy,
  'trip_budget_exceeded': XPayFailureCategory.corporatePolicy,
  'policy_violation': XPayFailureCategory.corporatePolicy,
  'employee_policy_violation': XPayFailureCategory.corporatePolicy,
  'employee_policy_unavailable': XPayFailureCategory.system,
  'merchant_not_allowed': XPayFailureCategory.system,
  'mcc_not_allowed': XPayFailureCategory.system,
  'channel_not_allowed': XPayFailureCategory.cardholderChange,
  'velocity_limit_exceeded': XPayFailureCategory.cardholderChange,
  'token_invalid_or_expired': XPayFailureCategory.cardholderRetry,
  'verification_code_required': XPayFailureCategory.cardholderRetry,
  'verification_code_invalid': XPayFailureCategory.cardholderChange,
  'verification_expired': XPayFailureCategory.cardholderRetry,
  'card_locked_too_many_attempts': XPayFailureCategory.cardholderChange,
  'chip_cryptogram_invalid': XPayFailureCategory.cardholderChange,
  'chip_nonce_replayed': XPayFailureCategory.cardholderRetry,
  'chip_counter_replay': XPayFailureCategory.cardholderChange,
  'chip_credential_revoked': XPayFailureCategory.cardholderChange,
  'chip_credential_not_active': XPayFailureCategory.cardholderChange,
  'service_payment_auth_failed': XPayFailureCategory.system,
  'service_payment_invalid_request': XPayFailureCategory.system,
  'service_payment_duplicate_order': XPayFailureCategory.session,
  'service_payment_user_invalid': XPayFailureCategory.corporatePolicy,
  'service_payment_in_flight': XPayFailureCategory.session,
  'service_payment_failed': XPayFailureCategory.system,
  'service_payment_insufficient_funds': XPayFailureCategory.corporatePolicy,
  'service_payment_declined': XPayFailureCategory.corporatePolicy,
  'service_payment_unavailable': XPayFailureCategory.system,
};

const _errorCategories = {
  XPayErrorCode.unexpectedResponse: XPayFailureCategory.system,
  'otp_delivery_failed': XPayFailureCategory.system,
  'no_connection': XPayFailureCategory.network,
  'no_host': XPayFailureCategory.network,
  'timeout': XPayFailureCategory.network,
  'not_found': XPayFailureCategory.cardholderRetry,
  'no_registered_phone': XPayFailureCategory.cardholderChange,
  'static_code_unavailable': XPayFailureCategory.cardholderChange,
  XPayErrorCode.busy: XPayFailureCategory.session,
  XPayErrorCode.invalidRequest: XPayFailureCategory.session,
  XPayErrorCode.notInitialized: XPayFailureCategory.session,
  'amount_locked': XPayFailureCategory.session,
  'ride_already_paid': XPayFailureCategory.session,
  'ride_card_not_found': XPayFailureCategory.session,
  'ride_not_found': XPayFailureCategory.session,
  'ride_not_on_corporate_wallet': XPayFailureCategory.session,
  'ride_payment_session_revoked': XPayFailureCategory.session,
  'token_expired': XPayFailureCategory.session,
  'token_not_found': XPayFailureCategory.session,
  'internal_error': XPayFailureCategory.unknown,
};

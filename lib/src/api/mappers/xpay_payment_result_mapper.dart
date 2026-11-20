import '../../base/localization/localization.dart';
import '../../core/domain/entities/payment_decline_entity.dart';
import '../../core/domain/entities/payment_entry_mode_enum.dart';
import '../../core/domain/entities/payment_flow_outcome_entity.dart';
import '../xpay_payment_result.dart';

extension PaymentFlowOutcomeEntityMapper on PaymentFlowOutcomeEntity {
  XPayPaymentResult toResult(XPLocaleBase locale, {required bool canTapCard}) => switch (this) {
    final PaymentFlowAuthorizedOutcomeEntity outcome => outcome._toResult(locale, canTapCard),
    final PaymentFlowVerifiedOutcomeEntity outcome => outcome._toResult(locale, canTapCard),
    final PaymentFlowExpiredOutcomeEntity outcome => XPayPaymentResult(status: XPayPaymentStatus.expired, authId: outcome.authId),
    final PaymentFlowCancelledOutcomeEntity outcome => XPayPaymentResult(status: XPayPaymentStatus.cancelled, authId: outcome.authId),
    PaymentFlowConflictOutcomeEntity _ => XPayPaymentResult(status: XPayPaymentStatus.duplicate, message: locale.payment.xpay.paymentDuplicateRequestBody),
    final PaymentFlowFailedOutcomeEntity outcome => outcome._toResult(locale),
    final PaymentFlowAuthorizeFailedOutcomeEntity outcome => outcome._toResult(locale),
    PaymentFlowUnsupportedOutcomeEntity _ => const XPayPaymentResult(status: XPayPaymentStatus.unsupported),
  };
}

extension on PaymentFlowAuthorizedOutcomeEntity {
  XPayPaymentResult _toResult(XPLocaleBase locale, bool canTapCard) {
    if (authorize.isCaptured || authorize.isApproved) {
      return XPayPaymentResult(
        status: authorize.isCaptured ? XPayPaymentStatus.captured : XPayPaymentStatus.approved,
        createdAt: authorize.createdAt,
        authId: authorize.authId,
        captureId: authorize.captureId,
        currency: authorize.currency,
        externalRef: authorize.externalRef,
        amount: authorize.amount._toAmount(),
      );
    }

    if (authorize.isDeclined) {
      return authorize.declineReason._toDeclinedResult(
        locale,
        entryMode: entryMode,
        authId: authorize.authId,
        currency: authorize.currency,
        externalRef: authorize.externalRef,
        amount: authorize.amount,
        canTapCard: canTapCard,
      );
    }

    return PaymentFlowFailedOutcomeEntity(authId: authorize.authId, errorCode: XPayErrorCode.unexpectedResponse)._toResult(locale);
  }
}

extension on PaymentFlowVerifiedOutcomeEntity {
  XPayPaymentResult _toResult(XPLocaleBase locale, bool canTapCard) {
    if (result.outcome.isDeclined) {
      return verify.declineReason._toDeclinedResult(
        locale,
        entryMode: entryMode,
        authId: verify.authId ?? authId,
        currency: verify.currency,
        externalRef: verify.externalRef,
        amount: verify.amount,
        canTapCard: canTapCard,
      );
    }

    return XPayPaymentResult(
      status: verify.isCaptured ? XPayPaymentStatus.captured : XPayPaymentStatus.approved,
      createdAt: verify.createdAt,
      authId: verify.authId ?? authId,
      bookingRef: verify.bookingRef,
      captureId: verify.captureId,
      currency: verify.currency,
      externalRef: verify.externalRef,
      amount: verify.amount._toAmount(),
    );
  }
}

extension on PaymentFlowFailedOutcomeEntity {
  XPayPaymentResult _toResult(XPLocaleBase locale) => XPayPaymentResult(
    status: XPayPaymentStatus.failed,
    authId: authId,
    errorCode: errorCode,
    message: displayMessage ?? locale.payment.xpay.resultGenericError(errorCode),
  );
}

extension on PaymentFlowAuthorizeFailedOutcomeEntity {
  XPayPaymentResult _toResult(XPLocaleBase locale) => XPayPaymentResult(
    status: XPayPaymentStatus.failed,
    errorCode: errorCode,
    message: reason.getBody(locale, entryMode, () => displayMessage ?? locale.payment.xpay.resultGenericError(errorCode)),
  );
}

extension on PaymentDeclineEntity? {
  XPayPaymentResult _toDeclinedResult(
    XPLocaleBase locale, {
    required PaymentEntryMode entryMode,
    required String? authId,
    required String? currency,
    required String? externalRef,
    required String? amount,
    required bool canTapCard,
  }) => XPayPaymentResult(
    status: XPayPaymentStatus.declined,
    authId: authId,
    currency: currency,
    declineCode: this?.rawErrorCode,
    externalRef: externalRef,
    message: this?.getMessage(locale, entryMode: entryMode, canTapCard: canTapCard) ?? locale.payment.xpay.decline.generic(null),
    amount: amount._toAmount(),
  );
}

extension on String? {
  int? _toAmount() => num.tryParse(this ?? '')?.toInt();
}

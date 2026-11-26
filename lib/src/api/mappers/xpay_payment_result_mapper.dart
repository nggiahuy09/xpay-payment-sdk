import '../../base/localization/localization.dart';
import '../../core/domain/entities/payment_decline_entity.dart';
import '../../core/domain/entities/payment_decline_reason.dart';
import '../../core/domain/entities/payment_entry_mode_enum.dart';
import '../../core/domain/entities/payment_flow_outcome_entity.dart';
import '../xpay_payment_result.dart';

extension PaymentFlowOutcomeEntityMapper on PaymentFlowOutcomeEntity {
  XPayPaymentResult toResult(XPLocaleBase locale, {required bool canTapCard}) => switch (this) {
    final PaymentFlowAuthorizedOutcomeEntity outcome => outcome._toResult(locale, canTapCard),
    final PaymentFlowVerifiedOutcomeEntity outcome => outcome._toResult(locale, canTapCard),
    final PaymentFlowWalletCapturedOutcomeEntity outcome => XPayPaymentResult(
      status: XPayPaymentStatus.captured,
      createdAt: outcome.createdAt,
      authId: outcome.authId,
      currency: outcome.currency,
      externalRef: outcome.externalRef,
      amount: outcome.amount._toAmount(),
    ),
    final PaymentFlowWalletDeclinedOutcomeEntity outcome => XPayPaymentResult(
      failureCategory: XPayFailureCategory.corporatePolicy,
      status: XPayPaymentStatus.declined,
      currency: outcome.currency,
      externalRef: outcome.externalRef,
      message: locale.payment.xpay.paymentDeclinedBody,
      amount: outcome.amount._toAmount(),
    ),
    final PaymentFlowExpiredOutcomeEntity outcome => XPayPaymentResult(status: XPayPaymentStatus.expired, authId: outcome.authId),
    final PaymentFlowCancelledOutcomeEntity outcome => XPayPaymentResult(status: XPayPaymentStatus.cancelled, authId: outcome.authId),
    PaymentFlowConflictOutcomeEntity _ => XPayPaymentResult(
      failureCategory: XPayFailureCategory.session,
      status: XPayPaymentStatus.duplicate,
      message: locale.payment.xpay.paymentDuplicateRequestBody,
    ),
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
    failureCategory: errorCode._toFailureCategory(),
    status: XPayPaymentStatus.failed,
    authId: authId,
    errorCode: errorCode,
    message: displayMessage ?? locale.payment.xpay.resultGenericError(errorCode),
  );
}

extension on PaymentFlowAuthorizeFailedOutcomeEntity {
  XPayPaymentResult _toResult(XPLocaleBase locale) => XPayPaymentResult(
    failureCategory: errorCode._toFailureCategory(),
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
    failureCategory: this?.reason._toFailureCategory() ?? XPayFailureCategory.unknown,
    status: XPayPaymentStatus.declined,
    authId: authId,
    currency: currency,
    declineCode: this?.rawErrorCode,
    externalRef: externalRef,
    message: this?.getMessage(locale, entryMode: entryMode, canTapCard: canTapCard) ?? locale.payment.xpay.decline.generic(null),
    amount: amount._toAmount(),
  );
}

extension on PaymentDeclineReason {
  XPayFailureCategory _toFailureCategory() => switch (this) {
    PaymentDeclineReason.insufficientFunds => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.cardInactive => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.cardBlocked => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.cardExpired => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.cardOutsideValidityWindow => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.cardLinkInactive => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.perTransactionLimitExceeded => XPayFailureCategory.corporatePolicy,
    PaymentDeclineReason.dailyLimitExceeded => XPayFailureCategory.corporatePolicy,
    PaymentDeclineReason.monthlyLimitExceeded => XPayFailureCategory.corporatePolicy,
    PaymentDeclineReason.corporateMonthlyLimitExceeded => XPayFailureCategory.corporatePolicy,
    PaymentDeclineReason.tripBudgetExceeded => XPayFailureCategory.corporatePolicy,
    PaymentDeclineReason.policyViolation => XPayFailureCategory.corporatePolicy,
    PaymentDeclineReason.employeePolicyViolation => XPayFailureCategory.corporatePolicy,
    PaymentDeclineReason.employeePolicyUnavailable => XPayFailureCategory.system,
    PaymentDeclineReason.merchantNotAllowed => XPayFailureCategory.system,
    PaymentDeclineReason.mccNotAllowed => XPayFailureCategory.system,
    PaymentDeclineReason.channelNotAllowed => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.velocityLimitExceeded => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.tokenInvalidOrExpired => XPayFailureCategory.cardholderRetry,
    PaymentDeclineReason.verificationCodeRequired => XPayFailureCategory.cardholderRetry,
    PaymentDeclineReason.verificationCodeInvalid => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.verificationExpired => XPayFailureCategory.cardholderRetry,
    PaymentDeclineReason.cardLockedTooManyAttempts => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.chipCryptogramInvalid => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.chipNonceReplayed => XPayFailureCategory.cardholderRetry,
    PaymentDeclineReason.chipCounterReplay => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.chipCredentialRevoked => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.chipCredentialNotActive => XPayFailureCategory.cardholderChange,
    PaymentDeclineReason.servicePaymentAuthFailed => XPayFailureCategory.system,
    PaymentDeclineReason.servicePaymentInvalidRequest => XPayFailureCategory.system,
    PaymentDeclineReason.servicePaymentDuplicateOrder => XPayFailureCategory.session,
    PaymentDeclineReason.servicePaymentUserInvalid => XPayFailureCategory.corporatePolicy,
    PaymentDeclineReason.servicePaymentInFlight => XPayFailureCategory.session,
    PaymentDeclineReason.servicePaymentFailed => XPayFailureCategory.system,
    PaymentDeclineReason.servicePaymentInsufficientFunds => XPayFailureCategory.corporatePolicy,
    PaymentDeclineReason.servicePaymentDeclined => XPayFailureCategory.corporatePolicy,
    PaymentDeclineReason.servicePaymentUnavailable => XPayFailureCategory.system,
    PaymentDeclineReason.unknown => XPayFailureCategory.unknown,
  };
}

extension on String? {
  int? _toAmount() => num.tryParse(this ?? '')?.toInt();

  XPayFailureCategory _toFailureCategory() => switch (this) {
    XPayErrorCode.unexpectedResponse || 'otp_delivery_failed' => XPayFailureCategory.system,
    'no_connection' || 'no_host' || 'timeout' => XPayFailureCategory.network,
    'not_found' => XPayFailureCategory.cardholderRetry,
    'no_registered_phone' || 'static_code_unavailable' => XPayFailureCategory.cardholderChange,
    XPayErrorCode.busy ||
    XPayErrorCode.invalidRequest ||
    XPayErrorCode.notInitialized ||
    'amount_locked' ||
    'ride_already_paid' ||
    'ride_card_not_found' ||
    'ride_not_found' ||
    'ride_not_on_corporate_wallet' ||
    'ride_payment_session_revoked' ||
    'token_expired' ||
    'token_not_found' => XPayFailureCategory.session,
    _ => XPayFailureCategory.unknown,
  };
}

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../base/define/constant/constant.dart';
import '../../../base/localization/localization.dart';
import 'payment_decline_reason.dart';

@immutable
final class PaymentFailureEntity with Equatable {
  const PaymentFailureEntity({required this.kind, this.authId, this.detail, this.errorCode, this.pendingAuthId, this.isResumable = false});

  final PaymentFailureKind kind;
  final String? authId;
  final String? detail;
  final String? errorCode;
  final String? pendingAuthId;
  final bool isResumable;

  PaymentFailureRoute get route => kind.route;

  PaymentFailureReason get reason => kind.reason;

  PaymentFailureEntity toRetriesExhausted() =>
      PaymentFailureEntity(kind: PaymentFailureKind.retriesExhausted, authId: authId, errorCode: errorCode, pendingAuthId: pendingAuthId, isResumable: isResumable);

  PaymentFailureEntity withTrail({required String? declinedAuthId, required String? pendingAuthId}) => PaymentFailureEntity(
    kind: kind,
    authId: authId ?? declinedAuthId,
    detail: detail,
    errorCode: errorCode,
    pendingAuthId: this.pendingAuthId ?? pendingAuthId,
    isResumable: isResumable,
  );

  @override
  List<Object?> get props => [kind, authId, detail, errorCode, pendingAuthId, isResumable];
}

enum PaymentFailureKind {
  cardInactive(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  cardBlocked(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  cardExpired(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  cardOutsideValidityWindow(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  channelNotAllowed(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  cardLinkInactive(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  merchantNotAllowed(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  insufficientFunds(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  cardLimitExceeded(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  servicePaymentInsufficientFunds(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  verificationExpired(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  verificationFailed(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  cardLocked(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  velocityLimitExceeded(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  tokenInvalidOrExpired(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  resendLimitReached(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  noRegisteredPhone(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  staticCodeUnavailable(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  otpDeliveryFailed(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  cardNotFound(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  rideCardNotFound(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  chipUnusable(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  chipReadFailed(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  qrExpired(PaymentFailureRoute.retryInSdk, PaymentFailureReason.paymentDeclined),
  fareChanged(PaymentFailureRoute.retryInPartner, PaymentFailureReason.fareChanged),
  sessionInvalid(PaymentFailureRoute.retryInPartner, PaymentFailureReason.sdkError),
  sessionUnavailable(PaymentFailureRoute.retryInPartner, PaymentFailureReason.sdkError),
  integrationError(PaymentFailureRoute.retryInPartner, PaymentFailureReason.sdkError),
  corporateBudgetExceeded(PaymentFailureRoute.callHotline, PaymentFailureReason.paymentDeclined),
  corporatePolicyRejected(PaymentFailureRoute.callHotline, PaymentFailureReason.paymentDeclined),
  policyCheckUnavailable(PaymentFailureRoute.callHotline, PaymentFailureReason.sdkError),
  xperiseWalletDeclined(PaymentFailureRoute.callHotline, PaymentFailureReason.paymentDeclined),
  xperiseWalletUnavailable(PaymentFailureRoute.callHotline, PaymentFailureReason.sdkError),
  corporateWalletRefused(PaymentFailureRoute.callHotline, PaymentFailureReason.paymentDeclined),
  systemError(PaymentFailureRoute.callHotline, PaymentFailureReason.sdkError),
  unauthorized(PaymentFailureRoute.callHotline, PaymentFailureReason.sdkError),
  retriesExhausted(PaymentFailureRoute.callHotline, PaymentFailureReason.paymentDeclined),
  rideAlreadyPaid(PaymentFailureRoute.checkRide, PaymentFailureReason.sdkError),
  rideNotFound(PaymentFailureRoute.checkRide, PaymentFailureReason.sdkError),
  verificationNotPending(PaymentFailureRoute.checkRide, PaymentFailureReason.sdkError),
  rideOnCorporateWallet(PaymentFailureRoute.switchMethod, PaymentFailureReason.sdkError),
  rideNotOnCorporateWallet(PaymentFailureRoute.switchMethod, PaymentFailureReason.sdkError);

  const PaymentFailureKind(this.route, this.reason);

  final PaymentFailureRoute route;
  final PaymentFailureReason reason;

  static PaymentFailureKind fromDecline(PaymentDeclineReason? value) => switch (value) {
    PaymentDeclineReason.insufficientFunds => PaymentFailureKind.insufficientFunds,
    PaymentDeclineReason.cardInactive => PaymentFailureKind.cardInactive,
    PaymentDeclineReason.cardBlocked => PaymentFailureKind.cardBlocked,
    PaymentDeclineReason.cardExpired => PaymentFailureKind.cardExpired,
    PaymentDeclineReason.cardOutsideValidityWindow => PaymentFailureKind.cardOutsideValidityWindow,
    PaymentDeclineReason.cardLinkInactive => PaymentFailureKind.cardLinkInactive,
    PaymentDeclineReason.perTransactionLimitExceeded ||
    PaymentDeclineReason.dailyLimitExceeded ||
    PaymentDeclineReason.monthlyLimitExceeded => PaymentFailureKind.cardLimitExceeded,
    PaymentDeclineReason.corporateMonthlyLimitExceeded => PaymentFailureKind.corporateBudgetExceeded,
    PaymentDeclineReason.tripBudgetExceeded || PaymentDeclineReason.policyViolation || PaymentDeclineReason.employeePolicyViolation => PaymentFailureKind.corporatePolicyRejected,
    PaymentDeclineReason.employeePolicyUnavailable => PaymentFailureKind.policyCheckUnavailable,
    PaymentDeclineReason.merchantNotAllowed || PaymentDeclineReason.mccNotAllowed => PaymentFailureKind.merchantNotAllowed,
    PaymentDeclineReason.channelNotAllowed => PaymentFailureKind.channelNotAllowed,
    PaymentDeclineReason.velocityLimitExceeded => PaymentFailureKind.velocityLimitExceeded,
    PaymentDeclineReason.tokenInvalidOrExpired => PaymentFailureKind.tokenInvalidOrExpired,
    PaymentDeclineReason.verificationCodeRequired || PaymentDeclineReason.verificationCodeInvalid => PaymentFailureKind.verificationFailed,
    PaymentDeclineReason.verificationExpired => PaymentFailureKind.verificationExpired,
    PaymentDeclineReason.cardLockedTooManyAttempts => PaymentFailureKind.cardLocked,
    PaymentDeclineReason.chipCryptogramInvalid || PaymentDeclineReason.chipNonceReplayed || PaymentDeclineReason.chipCounterReplay => PaymentFailureKind.chipReadFailed,
    PaymentDeclineReason.chipCredentialRevoked || PaymentDeclineReason.chipCredentialNotActive => PaymentFailureKind.chipUnusable,
    PaymentDeclineReason.servicePaymentInsufficientFunds => PaymentFailureKind.servicePaymentInsufficientFunds,
    PaymentDeclineReason.servicePaymentAuthFailed ||
    PaymentDeclineReason.servicePaymentInvalidRequest ||
    PaymentDeclineReason.servicePaymentFailed ||
    PaymentDeclineReason.servicePaymentUnavailable ||
    PaymentDeclineReason.servicePaymentInFlight => PaymentFailureKind.xperiseWalletUnavailable,
    PaymentDeclineReason.servicePaymentDeclined ||
    PaymentDeclineReason.servicePaymentUserInvalid ||
    PaymentDeclineReason.servicePaymentDuplicateOrder => PaymentFailureKind.xperiseWalletDeclined,
    PaymentDeclineReason.unknown || null => PaymentFailureKind.corporatePolicyRejected,
  };

  static PaymentFailureKind fromErrorCode(String? value) => switch (value) {
    'ride_already_paid' => PaymentFailureKind.rideAlreadyPaid,
    'ride_not_found' => PaymentFailureKind.rideNotFound,
    'verification_not_pending' => PaymentFailureKind.verificationNotPending,
    'ride_on_corporate_wallet' => PaymentFailureKind.rideOnCorporateWallet,
    'ride_not_on_corporate_wallet' => PaymentFailureKind.rideNotOnCorporateWallet,
    'resend_limit_reached' => PaymentFailureKind.resendLimitReached,
    'otp_expired' => PaymentFailureKind.verificationExpired,
    'no_registered_phone' => PaymentFailureKind.noRegisteredPhone,
    'static_code_unavailable' => PaymentFailureKind.staticCodeUnavailable,
    'otp_delivery_failed' => PaymentFailureKind.otpDeliveryFailed,
    'not_found' => PaymentFailureKind.cardNotFound,
    'ride_card_not_found' => PaymentFailureKind.rideCardNotFound,
    'ride_payment_session_revoked' || XPErrorCodes.sessionAmountChanged => PaymentFailureKind.fareChanged,
    'ride_payment_session_invalid' => PaymentFailureKind.sessionInvalid,
    'ride_payment_session_expired' => PaymentFailureKind.sessionUnavailable,
    'amount_locked' || 'validation_failed' || 'unsupported_entry_mode' || 'idempotency_conflict' || 'forbidden_sub_account_allocation' => PaymentFailureKind.integrationError,
    'corporate_wallet_refused' => PaymentFailureKind.corporateWalletRefused,
    'unauthorized' => PaymentFailureKind.unauthorized,
    _ => PaymentFailureKind.systemError,
  };

  static PaymentFailureKind fromConflictCode(String? value) => switch (value) {
    'amount_locked' => PaymentFailureKind.fareChanged,
    null => PaymentFailureKind.integrationError,
    _ => fromErrorCode(value),
  };

  String getTitle(XPLocaleBase locale) {
    final xpayLocale = locale.payment.xpay;
    return switch (reason) {
      PaymentFailureReason.paymentDeclined || PaymentFailureReason.fareChanged => xpayLocale.paymentDeclinedTitle,
      PaymentFailureReason.sdkError => xpayLocale.paymentNotProcessedTitle,
    };
  }

  String? getBody(XPLocaleBase locale) {
    final outcomeLocale = locale.payment.outcome;
    return switch (this) {
      PaymentFailureKind.cardInactive => outcomeLocale.cardInactiveBody,
      PaymentFailureKind.cardBlocked => outcomeLocale.cardBlockedBody,
      PaymentFailureKind.cardExpired => outcomeLocale.cardExpiredBody,
      PaymentFailureKind.cardOutsideValidityWindow => outcomeLocale.cardOutsideValidityWindowBody,
      PaymentFailureKind.channelNotAllowed => outcomeLocale.channelNotAllowedBody,
      PaymentFailureKind.cardLinkInactive => outcomeLocale.cardLinkInactiveBody,
      PaymentFailureKind.merchantNotAllowed => outcomeLocale.merchantNotAllowedBody,
      PaymentFailureKind.insufficientFunds => outcomeLocale.insufficientFundsBody,
      PaymentFailureKind.cardLimitExceeded => outcomeLocale.cardLimitExceededBody,
      PaymentFailureKind.servicePaymentInsufficientFunds => outcomeLocale.servicePaymentInsufficientFundsBody,
      PaymentFailureKind.verificationExpired => outcomeLocale.verificationExpiredBody,
      PaymentFailureKind.verificationFailed => outcomeLocale.verificationFailedBody,
      PaymentFailureKind.cardLocked => outcomeLocale.cardLockedBody,
      PaymentFailureKind.velocityLimitExceeded => outcomeLocale.velocityLimitExceededBody,
      PaymentFailureKind.tokenInvalidOrExpired => outcomeLocale.tokenInvalidOrExpiredBody,
      PaymentFailureKind.resendLimitReached => outcomeLocale.resendLimitReachedBody,
      PaymentFailureKind.noRegisteredPhone => outcomeLocale.noRegisteredPhoneBody,
      PaymentFailureKind.staticCodeUnavailable => outcomeLocale.staticCodeUnavailableBody,
      PaymentFailureKind.otpDeliveryFailed => outcomeLocale.otpDeliveryFailedBody,
      PaymentFailureKind.cardNotFound => outcomeLocale.cardNotFoundBody,
      PaymentFailureKind.rideCardNotFound => outcomeLocale.rideCardNotFoundBody,
      PaymentFailureKind.chipUnusable => outcomeLocale.chipUnusableBody,
      PaymentFailureKind.chipReadFailed => outcomeLocale.chipReadFailedBody,
      PaymentFailureKind.qrExpired => outcomeLocale.qrExpiredBody,
      PaymentFailureKind.fareChanged => outcomeLocale.fareChangedBody,
      PaymentFailureKind.sessionInvalid => outcomeLocale.sessionInvalidBody,
      PaymentFailureKind.sessionUnavailable => outcomeLocale.sessionUnavailableBody,
      PaymentFailureKind.integrationError => outcomeLocale.integrationErrorBody,
      PaymentFailureKind.corporateBudgetExceeded => outcomeLocale.corporateBudgetExceededBody,
      PaymentFailureKind.corporatePolicyRejected => outcomeLocale.corporatePolicyRejectedBody,
      PaymentFailureKind.policyCheckUnavailable => outcomeLocale.policyCheckUnavailableBody,
      PaymentFailureKind.xperiseWalletDeclined => outcomeLocale.xperiseWalletUnavailableBody,
      PaymentFailureKind.xperiseWalletUnavailable => outcomeLocale.xperiseWalletUnavailableBody,
      PaymentFailureKind.corporateWalletRefused => outcomeLocale.corporateWalletRefusedBody,
      PaymentFailureKind.systemError => outcomeLocale.systemErrorBody,
      PaymentFailureKind.unauthorized => outcomeLocale.unauthorizedBody,
      PaymentFailureKind.retriesExhausted => outcomeLocale.retriesExhaustedBody,
      PaymentFailureKind.rideAlreadyPaid => null,
      PaymentFailureKind.rideNotFound => null,
      PaymentFailureKind.verificationNotPending => null,
      PaymentFailureKind.rideOnCorporateWallet => null,
      PaymentFailureKind.rideNotOnCorporateWallet => null,
    };
  }
}

enum PaymentFailureRoute { switchMethod, retryInSdk, retryInPartner, callHotline, checkRide }

enum PaymentFailureReason {
  paymentDeclined(XPColorSurface.negative, XPColorIcon.negative, Remix.close_circle_line),
  sdkError(XPColorSurface.warning, XPColorIcon.warning, Remix.error_warning_line),
  fareChanged(XPColorSurface.info, XPColorIcon.info, Remix.refresh_line);

  const PaymentFailureReason(this.backgroundColor, this.iconColor, this.icon);

  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
}

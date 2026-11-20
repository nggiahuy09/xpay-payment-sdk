import '../../../base/localization/localization.dart';
import 'payment_entry_mode_enum.dart';

enum PaymentDeclineReason {
  insufficientFunds,
  cardInactive,
  cardBlocked,
  cardExpired,
  cardOutsideValidityWindow,
  cardLinkInactive,
  perTransactionLimitExceeded,
  dailyLimitExceeded,
  monthlyLimitExceeded,
  corporateMonthlyLimitExceeded,
  tripBudgetExceeded,
  policyViolation,
  employeePolicyViolation,
  employeePolicyUnavailable,
  merchantNotAllowed,
  mccNotAllowed,
  channelNotAllowed,
  velocityLimitExceeded,
  tokenInvalidOrExpired,
  verificationCodeRequired,
  verificationCodeInvalid,
  verificationExpired,
  cardLockedTooManyAttempts,
  chipCryptogramInvalid,
  chipNonceReplayed,
  chipCounterReplay,
  chipCredentialRevoked,
  chipCredentialNotActive,
  servicePaymentAuthFailed,
  servicePaymentInvalidRequest,
  servicePaymentDuplicateOrder,
  servicePaymentUserInvalid,
  servicePaymentInFlight,
  servicePaymentFailed,
  servicePaymentInsufficientFunds,
  servicePaymentDeclined,
  servicePaymentUnavailable,
  unknown;

  static PaymentDeclineReason fromRemote(String? value) => switch (value) {
    'insufficient_funds' => PaymentDeclineReason.insufficientFunds,
    'card_inactive' => PaymentDeclineReason.cardInactive,
    'card_blocked' => PaymentDeclineReason.cardBlocked,
    'card_expired' => PaymentDeclineReason.cardExpired,
    'card_outside_validity_window' => PaymentDeclineReason.cardOutsideValidityWindow,
    'card_link_inactive' => PaymentDeclineReason.cardLinkInactive,
    'per_transaction_limit_exceeded' => PaymentDeclineReason.perTransactionLimitExceeded,
    'daily_limit_exceeded' => PaymentDeclineReason.dailyLimitExceeded,
    'monthly_limit_exceeded' => PaymentDeclineReason.monthlyLimitExceeded,
    'corporate_monthly_limit_exceeded' => PaymentDeclineReason.corporateMonthlyLimitExceeded,
    'trip_budget_exceeded' => PaymentDeclineReason.tripBudgetExceeded,
    'policy_violation' => PaymentDeclineReason.policyViolation,
    'employee_policy_violation' => PaymentDeclineReason.employeePolicyViolation,
    'employee_policy_unavailable' => PaymentDeclineReason.employeePolicyUnavailable,
    'merchant_not_allowed' => PaymentDeclineReason.merchantNotAllowed,
    'mcc_not_allowed' => PaymentDeclineReason.mccNotAllowed,
    'channel_not_allowed' => PaymentDeclineReason.channelNotAllowed,
    'velocity_limit_exceeded' => PaymentDeclineReason.velocityLimitExceeded,
    'token_invalid_or_expired' => PaymentDeclineReason.tokenInvalidOrExpired,
    'verification_code_required' => PaymentDeclineReason.verificationCodeRequired,
    'verification_code_invalid' => PaymentDeclineReason.verificationCodeInvalid,
    'verification_expired' => PaymentDeclineReason.verificationExpired,
    'card_locked_too_many_attempts' => PaymentDeclineReason.cardLockedTooManyAttempts,
    'chip_cryptogram_invalid' => PaymentDeclineReason.chipCryptogramInvalid,
    'chip_nonce_replayed' => PaymentDeclineReason.chipNonceReplayed,
    'chip_counter_replay' => PaymentDeclineReason.chipCounterReplay,
    'chip_credential_revoked' => PaymentDeclineReason.chipCredentialRevoked,
    'chip_credential_not_active' => PaymentDeclineReason.chipCredentialNotActive,
    'service_payment_auth_failed' => PaymentDeclineReason.servicePaymentAuthFailed,
    'service_payment_invalid_request' => PaymentDeclineReason.servicePaymentInvalidRequest,
    'service_payment_duplicate_order' => PaymentDeclineReason.servicePaymentDuplicateOrder,
    'service_payment_user_invalid' => PaymentDeclineReason.servicePaymentUserInvalid,
    'service_payment_in_flight' => PaymentDeclineReason.servicePaymentInFlight,
    'service_payment_failed' => PaymentDeclineReason.servicePaymentFailed,
    'service_payment_insufficient_funds' => PaymentDeclineReason.servicePaymentInsufficientFunds,
    'service_payment_declined' => PaymentDeclineReason.servicePaymentDeclined,
    'service_payment_unavailable' => PaymentDeclineReason.servicePaymentUnavailable,
    _ => PaymentDeclineReason.unknown,
  };

  bool get isExpired => this == PaymentDeclineReason.verificationExpired || this == PaymentDeclineReason.tokenInvalidOrExpired;

  /// Marks the reasons that come from our own payment service rather than the card network, so the UI can drop the card-decline framing and point the merchant at
  /// the corporate admin — nothing about the card or a different card would resolve these.
  bool get isServiceError =>
      this == PaymentDeclineReason.employeePolicyUnavailable ||
      this == PaymentDeclineReason.servicePaymentAuthFailed ||
      this == PaymentDeclineReason.servicePaymentInvalidRequest ||
      this == PaymentDeclineReason.servicePaymentDuplicateOrder ||
      this == PaymentDeclineReason.servicePaymentUserInvalid ||
      this == PaymentDeclineReason.servicePaymentInFlight ||
      this == PaymentDeclineReason.servicePaymentFailed ||
      this == PaymentDeclineReason.servicePaymentInsufficientFunds ||
      this == PaymentDeclineReason.servicePaymentDeclined ||
      this == PaymentDeclineReason.servicePaymentUnavailable;

  /// [entryMode] names the channel the card was refused on, and is only known while the payment is being taken — a decline read back from a stored payment carries no
  /// entry mode, so [PaymentDeclineReason.channelNotAllowed] falls back to copy that does not name one.
  String getMessage(XPLocaleBase locale, {PaymentEntryMode? entryMode, bool canTapCard = false, String? Function()? errorCode}) {
    final declineLocale = locale.payment.xpay.decline;
    return switch (this) {
      PaymentDeclineReason.insufficientFunds => declineLocale.insufficientFunds,
      PaymentDeclineReason.cardInactive => declineLocale.cardInactive,
      PaymentDeclineReason.cardBlocked => declineLocale.cardBlocked,
      PaymentDeclineReason.cardExpired => declineLocale.cardExpired,
      PaymentDeclineReason.cardOutsideValidityWindow => declineLocale.cardOutsideValidityWindow,
      PaymentDeclineReason.cardLinkInactive => declineLocale.cardLinkInactive,
      PaymentDeclineReason.perTransactionLimitExceeded => declineLocale.perTransactionLimitExceeded,
      PaymentDeclineReason.dailyLimitExceeded => declineLocale.dailyLimitExceeded,
      PaymentDeclineReason.monthlyLimitExceeded => declineLocale.monthlyLimitExceeded,
      PaymentDeclineReason.corporateMonthlyLimitExceeded => declineLocale.corporateMonthlyLimitExceeded,
      PaymentDeclineReason.tripBudgetExceeded => declineLocale.tripBudgetExceeded,
      PaymentDeclineReason.policyViolation => declineLocale.policyViolation,
      PaymentDeclineReason.employeePolicyViolation => declineLocale.employeePolicyViolation,
      PaymentDeclineReason.employeePolicyUnavailable => declineLocale.employeePolicyUnavailable,
      PaymentDeclineReason.merchantNotAllowed => declineLocale.merchantNotAllowed,
      PaymentDeclineReason.mccNotAllowed => declineLocale.mccNotAllowed,
      PaymentDeclineReason.channelNotAllowed => declineLocale.channelNotAllowed(entryMode?.getTitle(locale), entryMode?.getAlternativeTitles(locale, canTapCard)),
      PaymentDeclineReason.velocityLimitExceeded => declineLocale.velocityLimitExceeded,
      PaymentDeclineReason.tokenInvalidOrExpired => declineLocale.tokenInvalidOrExpired,
      PaymentDeclineReason.verificationCodeRequired => declineLocale.verificationCodeRequired,
      PaymentDeclineReason.verificationCodeInvalid => declineLocale.verificationCodeInvalid,
      PaymentDeclineReason.verificationExpired => declineLocale.verificationExpired,
      PaymentDeclineReason.cardLockedTooManyAttempts => declineLocale.cardLockedTooManyAttempts,
      PaymentDeclineReason.chipCryptogramInvalid => declineLocale.chipCryptogramInvalid,
      PaymentDeclineReason.chipNonceReplayed => declineLocale.chipNonceReplayed,
      PaymentDeclineReason.chipCounterReplay => declineLocale.chipCounterReplay,
      PaymentDeclineReason.chipCredentialRevoked => declineLocale.chipCredentialRevoked,
      PaymentDeclineReason.chipCredentialNotActive => declineLocale.chipCredentialNotActive,
      PaymentDeclineReason.servicePaymentAuthFailed => declineLocale.servicePaymentAuthFailed,
      PaymentDeclineReason.servicePaymentInvalidRequest => declineLocale.servicePaymentInvalidRequest,
      PaymentDeclineReason.servicePaymentDuplicateOrder => declineLocale.servicePaymentDuplicateOrder,
      PaymentDeclineReason.servicePaymentUserInvalid => declineLocale.servicePaymentUserInvalid,
      PaymentDeclineReason.servicePaymentInFlight => declineLocale.servicePaymentInFlight,
      PaymentDeclineReason.servicePaymentFailed => declineLocale.servicePaymentFailed,
      PaymentDeclineReason.servicePaymentInsufficientFunds => declineLocale.servicePaymentInsufficientFunds,
      PaymentDeclineReason.servicePaymentDeclined => declineLocale.servicePaymentDeclined,
      PaymentDeclineReason.servicePaymentUnavailable => declineLocale.servicePaymentUnavailable,
      PaymentDeclineReason.unknown => declineLocale.generic(errorCode?.call()),
    };
  }
}

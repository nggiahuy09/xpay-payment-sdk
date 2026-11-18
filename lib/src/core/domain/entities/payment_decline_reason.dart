import '../../../base/localization/localization.dart';
import 'payment_entry_mode_enum.dart';

enum PaymentDeclineReason {
  insufficientFunds,
  cardInactive,
  cardBlocked,
  cardExpired,
  perTransactionLimitExceeded,
  dailyLimitExceeded,
  monthlyLimitExceeded,
  corporateMonthlyLimitExceeded,
  tripBudgetExceeded,
  policyViolation,
  merchantNotAllowed,
  mccNotAllowed,
  channelNotAllowed,
  velocityLimitExceeded,
  tokenInvalidOrExpired,
  verificationCodeRequired,
  verificationCodeInvalid,
  verificationExpired,
  cardLockedTooManyAttempts,
  servicePaymentDuplicateOrder,
  servicePaymentUserInvalid,
  servicePaymentInsufficientFunds,
  unknown;

  static PaymentDeclineReason fromRemote(String? value) => switch (value) {
    'insufficient_funds' => PaymentDeclineReason.insufficientFunds,
    'card_inactive' => PaymentDeclineReason.cardInactive,
    'card_blocked' => PaymentDeclineReason.cardBlocked,
    'card_expired' => PaymentDeclineReason.cardExpired,
    'per_transaction_limit_exceeded' => PaymentDeclineReason.perTransactionLimitExceeded,
    'daily_limit_exceeded' => PaymentDeclineReason.dailyLimitExceeded,
    'monthly_limit_exceeded' => PaymentDeclineReason.monthlyLimitExceeded,
    'corporate_monthly_limit_exceeded' => PaymentDeclineReason.corporateMonthlyLimitExceeded,
    'trip_budget_exceeded' => PaymentDeclineReason.tripBudgetExceeded,
    'policy_violation' => PaymentDeclineReason.policyViolation,
    'merchant_not_allowed' => PaymentDeclineReason.merchantNotAllowed,
    'mcc_not_allowed' => PaymentDeclineReason.mccNotAllowed,
    'channel_not_allowed' => PaymentDeclineReason.channelNotAllowed,
    'velocity_limit_exceeded' => PaymentDeclineReason.velocityLimitExceeded,
    'token_invalid_or_expired' => PaymentDeclineReason.tokenInvalidOrExpired,
    'verification_code_required' => PaymentDeclineReason.verificationCodeRequired,
    'verification_code_invalid' => PaymentDeclineReason.verificationCodeInvalid,
    'verification_expired' => PaymentDeclineReason.verificationExpired,
    'card_locked_too_many_attempts' => PaymentDeclineReason.cardLockedTooManyAttempts,
    'service_payment_duplicate_order' => PaymentDeclineReason.servicePaymentDuplicateOrder,
    'service_payment_user_invalid' => PaymentDeclineReason.servicePaymentUserInvalid,
    'service_payment_insufficient_funds' => PaymentDeclineReason.servicePaymentInsufficientFunds,
    _ => PaymentDeclineReason.unknown,
  };

  bool get isExpired => this == PaymentDeclineReason.verificationExpired || this == PaymentDeclineReason.tokenInvalidOrExpired;

  /// Marks the reasons that come from our own payment service rather than the card network, so the UI can drop the card-decline framing and point the merchant at
  /// the corporate admin — nothing about the card or a different card would resolve these.
  bool get isServiceError =>
      this == PaymentDeclineReason.servicePaymentDuplicateOrder ||
      this == PaymentDeclineReason.servicePaymentUserInvalid ||
      this == PaymentDeclineReason.servicePaymentInsufficientFunds;

  /// [entryMode] names the channel the card was refused on, and is only known while the payment is being taken — a decline read back from a stored payment carries no
  /// entry mode, so [PaymentDeclineReason.channelNotAllowed] falls back to copy that does not name one.
  String getMessage(XPLocaleBase locale, {PaymentEntryMode? entryMode, bool canTapCard = false, String? Function()? errorCode}) {
    final declineLocale = locale.payment.xpay.decline;
    return switch (this) {
      PaymentDeclineReason.insufficientFunds => declineLocale.insufficientFunds,
      PaymentDeclineReason.cardInactive => declineLocale.cardInactive,
      PaymentDeclineReason.cardBlocked => declineLocale.cardBlocked,
      PaymentDeclineReason.cardExpired => declineLocale.cardExpired,
      PaymentDeclineReason.perTransactionLimitExceeded => declineLocale.perTransactionLimitExceeded,
      PaymentDeclineReason.dailyLimitExceeded => declineLocale.dailyLimitExceeded,
      PaymentDeclineReason.monthlyLimitExceeded => declineLocale.monthlyLimitExceeded,
      PaymentDeclineReason.corporateMonthlyLimitExceeded => declineLocale.corporateMonthlyLimitExceeded,
      PaymentDeclineReason.tripBudgetExceeded => declineLocale.tripBudgetExceeded,
      PaymentDeclineReason.policyViolation => declineLocale.policyViolation,
      PaymentDeclineReason.merchantNotAllowed => declineLocale.merchantNotAllowed,
      PaymentDeclineReason.mccNotAllowed => declineLocale.mccNotAllowed,
      PaymentDeclineReason.channelNotAllowed => declineLocale.channelNotAllowed(entryMode?.getTitle(locale), entryMode?.getAlternativeTitles(locale, canTapCard)),
      PaymentDeclineReason.velocityLimitExceeded => declineLocale.velocityLimitExceeded,
      PaymentDeclineReason.tokenInvalidOrExpired => declineLocale.tokenInvalidOrExpired,
      PaymentDeclineReason.verificationCodeRequired => declineLocale.verificationCodeRequired,
      PaymentDeclineReason.verificationCodeInvalid => declineLocale.verificationCodeInvalid,
      PaymentDeclineReason.verificationExpired => declineLocale.verificationExpired,
      PaymentDeclineReason.cardLockedTooManyAttempts => declineLocale.cardLockedTooManyAttempts,
      PaymentDeclineReason.servicePaymentDuplicateOrder => declineLocale.servicePaymentDuplicateOrder,
      PaymentDeclineReason.servicePaymentUserInvalid => declineLocale.servicePaymentUserInvalid,
      PaymentDeclineReason.servicePaymentInsufficientFunds => declineLocale.servicePaymentInsufficientFunds,
      PaymentDeclineReason.unknown => declineLocale.generic(errorCode?.call()),
    };
  }
}

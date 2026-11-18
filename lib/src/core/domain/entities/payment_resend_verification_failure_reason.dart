import '../../../base/localization/localization.dart';

/// Why the server refused to send a fresh verification code.
///
/// Each reason implies a different next move for the merchant — wait, stop asking, or abandon the sale — so they are kept distinct rather than collapsed into one
/// generic failure message.
enum PaymentResendVerificationFailureReason {
  /// The card's code is printed rather than sent, so there is nothing to resend (HTTP 422).
  notApplicable,

  /// Still inside the per-send cooldown (HTTP 429).
  tooSoon,

  /// The per-sale resend cap is used up (HTTP 422).
  limitReached,
  recipientRequired,
  recipientInvalid,
  unknown;

  static PaymentResendVerificationFailureReason fromRemote(String? value) => switch (value) {
    'resend_not_applicable' => PaymentResendVerificationFailureReason.notApplicable,
    'resend_too_soon' => PaymentResendVerificationFailureReason.tooSoon,
    'resend_limit_reached' => PaymentResendVerificationFailureReason.limitReached,
    'otp_recipient_required' => PaymentResendVerificationFailureReason.recipientRequired,
    'otp_recipient_invalid' => PaymentResendVerificationFailureReason.recipientInvalid,
    _ => PaymentResendVerificationFailureReason.unknown,
  };

  /// Whether this refusal is final, so the UI should retire the resend action rather than leave a button that can only fail again.
  ///
  /// Deliberately expressed as an allow-list of the two settled cases instead of "anything but the cooldown". [unknown] covers every unrecognized code — including the
  /// network and timeout codes a transport failure carries — and "we could not classify this" is far too weak a basis for permanently removing the merchant's only way
  /// to get a code to the customer. Anything uncertain stays retryable.
  bool get isFinal => this == PaymentResendVerificationFailureReason.notApplicable || this == PaymentResendVerificationFailureReason.limitReached;

  String getMessageTitle(XPLocaleBase locale) {
    final viewLocale = locale.payment.verification;
    return switch (this) {
      PaymentResendVerificationFailureReason.notApplicable => viewLocale.resendNotApplicableTitle,
      PaymentResendVerificationFailureReason.tooSoon => viewLocale.resendTooSoonTitle,
      PaymentResendVerificationFailureReason.limitReached => viewLocale.resendLimitReachedTitle,
      PaymentResendVerificationFailureReason.recipientRequired => viewLocale.resendRecipientRequiredTitle,
      PaymentResendVerificationFailureReason.recipientInvalid => viewLocale.resendRecipientInvalidTitle,
      PaymentResendVerificationFailureReason.unknown => viewLocale.resendFailedTitle,
    };
  }

  String getMessageBody(XPLocaleBase locale, {String? Function()? errorCode}) {
    final viewLocale = locale.payment.verification;
    return switch (this) {
      PaymentResendVerificationFailureReason.notApplicable => viewLocale.resendNotApplicableBody,
      PaymentResendVerificationFailureReason.tooSoon => viewLocale.resendTooSoonBody,
      PaymentResendVerificationFailureReason.limitReached => viewLocale.resendLimitReachedBody,
      PaymentResendVerificationFailureReason.recipientRequired => viewLocale.resendRecipientRequiredBody,
      PaymentResendVerificationFailureReason.recipientInvalid => viewLocale.resendRecipientInvalidBody,
      PaymentResendVerificationFailureReason.unknown => locale.payment.xpay.resultGenericError(errorCode?.call()),
    };
  }
}

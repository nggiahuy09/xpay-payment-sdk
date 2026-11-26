part of '../locale_en.dart';

final class $XPLocaleENPaymentXpayDecline implements $XPLocaleBasePaymentXpayDecline {
  const $XPLocaleENPaymentXpayDecline();

  @override
  String get insufficientFunds => 'The card has insufficient funds. Please use another card.';
  @override
  String get cardInactive => 'This card is not active. Please use another card.';
  @override
  String get cardBlocked => 'This card has been blocked. Please use another card.';
  @override
  String get cardExpired => 'This card has expired. Please use another card.';
  @override
  String get cardOutsideValidityWindow => 'The card entered cannot be used at this time of day. Please use another card, or contact your corporate admin.';
  @override
  String get cardLinkInactive => 'You do not have permission to pay with this card. Please use another card to complete the payment.';
  @override
  String get perTransactionLimitExceeded => 'The amount exceeds the per-transaction limit for this card.';
  @override
  String get dailyLimitExceeded => 'The daily spending limit for this card has been reached.';
  @override
  String get monthlyLimitExceeded => 'The monthly spending limit for this card has been reached.';
  @override
  String get corporateMonthlyLimitExceeded => 'The business\'s monthly limit is insufficient to cover this transaction. Please contact your corporate admin to resolve it.';
  @override
  String get tripBudgetExceeded => 'This payment exceeds the allowed trip budget.';
  @override
  String get policyViolation => 'This payment is not allowed by the spending policy.';
  @override
  String get employeePolicyViolation => 'This payment is not allowed by the employee spending policy. Please contact your corporate admin to resolve it.';
  @override
  String get employeePolicyUnavailable => 'The spending policy could not be checked at this time. Please try again in a few minutes.';
  @override
  String get merchantNotAllowed => 'This card cannot be used with this merchant.';
  @override
  String get mccNotAllowed => 'This card cannot be used for this type of merchant.';
  @override
  String channelNotAllowed(String? current, [List<String>? others]) {
    final alternatives = others?.where((other) => other.isNotEmpty) ?? const <String>[];
    if (current == null || current.isEmpty || alternatives.isEmpty) return 'Please use another method to enter the card details.';

    final alternativesText = alternatives.joinWithLast(separator: ', ', lastSeparator: ', or ');
    return 'This card is not supported for payments via $current. Please $alternativesText to pay.';
  }

  @override
  String get velocityLimitExceeded => 'This card has been locked due to too many payments in a short time. Please use another card or payment method, or contact support.';
  @override
  String get tokenInvalidOrExpired => 'The payment code is invalid or has expired. Please scan again.';
  @override
  String get verificationCodeRequired => 'A verification code is required to complete this payment.';
  @override
  String get verificationCodeInvalid => 'The verification code is incorrect. Please try again.';
  @override
  String get verificationExpired => 'The verification has expired. Please try again.';
  @override
  String get cardLockedTooManyAttempts => 'This card is temporarily locked due to multiple incorrect PIN attempts. Please try again after a few minutes.';
  @override
  String get chipCryptogramInvalid => 'This card could not be verified for NFC payment. Please use another payment method to continue.';
  @override
  String get chipNonceReplayed => 'This tap has already been used for a previous payment. Please tap the card again.';
  @override
  String get chipCounterReplay =>
      'Please try another payment method (QR, manual PAN) to continue with your payment. To re-enable NFC payment for this card, please contact support.';
  @override
  String get chipCredentialRevoked => 'This card has been deactivated and cannot be charged. Ask the cardholder to contact the issuer.';
  @override
  String get chipCredentialNotActive => 'This card has not finished setup yet and cannot be charged. Please use another card or contact support.';

  @override
  String get servicePaymentAuthFailed => 'The payment could not be verified with the corporate account. Please contact support to resolve it.';
  @override
  String get servicePaymentInvalidRequest => 'The corporate account could not process this payment request. Please contact support to resolve it.';
  @override
  String get servicePaymentDuplicateOrder => 'A payment for this order has already been recorded. Please contact your corporate admin to resolve it.';
  @override
  String get servicePaymentUserInvalid => 'The cardholder account is not valid for this payment. Please contact your corporate admin to resolve it.';
  @override
  String get servicePaymentInFlight => 'A payment for this order is still being processed. Please check the transaction list before trying again.';
  @override
  String get servicePaymentFailed => 'The corporate account could not complete this payment. Please try again later.';
  @override
  String get servicePaymentInsufficientFunds => 'The corporate account does not have enough balance for this payment. Please contact your corporate admin to resolve it.';
  @override
  String get servicePaymentDeclined => 'The corporate account declined this payment. Please contact your corporate admin to resolve it.';
  @override
  String get servicePaymentUnavailable => 'The corporate account service is temporarily unavailable. Please try again in a few minutes.';

  @override
  String generic(String? errorCode) => 'The payment was not successful. Please try again or use another card.${errorCode != null ? '\nError code: $errorCode' : ''}';
}

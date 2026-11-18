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
  String get velocityLimitExceeded => 'Too many payments have been created for this card in a short time. Please try again in 5 minutes.';
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
  String get servicePaymentDuplicateOrder => 'A payment for this order has already been recorded. Please contact your corporate admin to resolve it.';
  @override
  String get servicePaymentUserInvalid => 'The cardholder account is not valid for this payment. Please contact your corporate admin to resolve it.';
  @override
  String get servicePaymentInsufficientFunds => 'The corporate account does not have enough balance for this payment. Please contact your corporate admin to resolve it.';

  @override
  String generic(String? errorCode) => 'The payment was not successful. Please try again or use another card.${errorCode != null ? '\nError code: $errorCode' : ''}';
}

part of '../locale_base.dart';

abstract class $XPLocaleBasePaymentXpayDecline {
  String get insufficientFunds;
  String get cardInactive;
  String get cardBlocked;
  String get cardExpired;
  String get cardOutsideValidityWindow;
  String get cardLinkInactive;
  String get perTransactionLimitExceeded;
  String get dailyLimitExceeded;
  String get monthlyLimitExceeded;
  String get corporateMonthlyLimitExceeded;
  String get tripBudgetExceeded;
  String get policyViolation;
  String get employeePolicyViolation;
  String get employeePolicyUnavailable;
  String get merchantNotAllowed;
  String get mccNotAllowed;
  String channelNotAllowed(String? current, [List<String>? others]);
  String get velocityLimitExceeded;
  String get tokenInvalidOrExpired;
  String get verificationCodeRequired;
  String get verificationCodeInvalid;
  String get verificationExpired;
  String get cardLockedTooManyAttempts;
  String get chipCryptogramInvalid;
  String get chipNonceReplayed;
  String get chipCounterReplay;
  String get chipCredentialRevoked;
  String get chipCredentialNotActive;

  String get servicePaymentAuthFailed;
  String get servicePaymentInvalidRequest;
  String get servicePaymentDuplicateOrder;
  String get servicePaymentUserInvalid;
  String get servicePaymentInFlight;
  String get servicePaymentFailed;
  String get servicePaymentInsufficientFunds;
  String get servicePaymentDeclined;
  String get servicePaymentUnavailable;

  String generic(String? errorCode);
}

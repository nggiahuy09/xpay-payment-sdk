part of '../locale_base.dart';

abstract class $XPLocaleBasePaymentOutcome {
  const $XPLocaleBasePaymentOutcome();

  String get statusCheckTitle;
  String get statusCheckBody;

  String get backToCheckout;
  String get hotlineCallBody;
  String get hotlineNumberLabel;
  String get hotlineCopiedLabel;
  String get hotlineConfirmLabel;
  String get continueLabel;

  String get optionsTitle;
  String get optionsBody;
  String get retryXpayTitle;
  String get retryXpayBody;
  String get otherMethodTitle;
  String get otherMethodBody;
  String get hotlinePayTitle;
  String get hotlinePayBody;

  String get hotlineWaitTitle;
  String get hotlineWaitBody;
  String get hotlineWaitTimeLeftLabel;

  String get paidByHotlineLabel;
  String get backLabel;
  String autoBackLabel(int seconds);

  String get rideCompletedTitle;
  String get rideCompletedBody;
  String get rideCancelledTitle;
  String get rideCancelledBody;
  String get rideStatusLabel;
  String get rideStatusCompleted;
  String get rideStatusCancelled;
  String get amountCollectedLabel;

  String get cardInactiveBody;
  String get cardBlockedBody;
  String get cardExpiredBody;
  String get cardOutsideValidityWindowBody;
  String get channelNotAllowedBody;
  String get cardLinkInactiveBody;
  String get merchantNotAllowedBody;
  String get insufficientFundsBody;
  String get cardLimitExceededBody;
  String get servicePaymentInsufficientFundsBody;
  String get verificationExpiredBody;
  String get verificationFailedBody;
  String get cardLockedBody;
  String get velocityLimitExceededBody;
  String get tokenInvalidOrExpiredBody;
  String get resendLimitReachedBody;
  String get noRegisteredPhoneBody;
  String get staticCodeUnavailableBody;
  String get otpDeliveryFailedBody;
  String get cardNotFoundBody;
  String get rideCardNotFoundBody;
  String get chipUnusableBody;
  String get chipReadFailedBody;
  String get qrExpiredBody;

  String get fareChangedBody;
  String get sessionInvalidBody;
  String get sessionUnavailableBody;
  String get integrationErrorBody;

  String get corporateBudgetExceededBody;
  String get corporatePolicyRejectedBody;
  String get policyCheckUnavailableBody;
  String get xperiseWalletUnavailableBody;
  String get corporateWalletRefusedBody;
  String get systemErrorBody;
  String get unauthorizedBody;
  String get retriesExhaustedBody;
}

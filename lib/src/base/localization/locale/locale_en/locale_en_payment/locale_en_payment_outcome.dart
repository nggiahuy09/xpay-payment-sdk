part of '../locale_en.dart';

final class $XPLocaleENPaymentOutcome implements $XPLocaleBasePaymentOutcome {
  const $XPLocaleENPaymentOutcome();

  @override
  String get statusCheckTitle => 'Checking the ride status';
  @override
  String get statusCheckBody => 'Please wait a moment.';

  @override
  String get backToCheckout => 'Back to checkout';
  @override
  String get hotlineCallBody => 'Please call the XPAY hotline for help before you continue.';
  @override
  String get hotlineNumberLabel => 'XPAY hotline';
  @override
  String get hotlineCopiedLabel => 'Hotline number copied. Paste it into your phone app to call.';
  @override
  String get hotlineConfirmLabel => 'I have called and confirmed with the hotline';
  @override
  String get continueLabel => 'Continue';

  @override
  String get optionsTitle => 'Payment not completed';
  @override
  String get optionsBody => 'Choose how to continue the payment, as agreed with the hotline.';
  @override
  String get retryXpayTitle => 'Try again with XPAY';
  @override
  String get retryXpayBody => 'Go back to choosing how to pay with XPAY';
  @override
  String get otherMethodTitle => 'Try again with another payment method';
  @override
  String get otherMethodBody => 'Close XPAY and pick another method at checkout';
  @override
  String get hotlinePayTitle => 'Let the hotline pay';
  @override
  String get hotlinePayBody => 'The XPAY hotline pays on the customer’s behalf';

  @override
  String get hotlineWaitTitle => 'Waiting for the hotline to pay';
  @override
  String get hotlineWaitBody => 'Please keep this screen open until the hotline has finished the payment.';
  @override
  String get hotlineWaitTimeLeftLabel => 'Time left';

  @override
  String get paidByHotlineLabel => 'Paid by the hotline';
  @override
  String get backLabel => 'Go back';
  @override
  String autoBackLabel(int seconds) => 'Go back · auto in ${seconds}s';

  @override
  String get rideCompletedTitle => 'The hotline closed the ride without a charge';
  @override
  String get rideCompletedBody => 'The XPAY hotline closed this ride without charging the customer. Do not collect anything else.';
  @override
  String get rideCancelledTitle => 'Ride cancelled';
  @override
  String get rideCancelledBody => 'This ride was cancelled or moved to another provider. Do not charge the customer.';
  @override
  String get rideStatusLabel => 'Ride status';
  @override
  String get rideStatusCompleted => 'Closed';
  @override
  String get rideStatusCancelled => 'Cancelled';
  @override
  String get amountCollectedLabel => 'Amount collected';

  @override
  String get cardInactiveBody => 'The card is not activated. Use another card or another payment method.';
  @override
  String get cardBlockedBody => 'The card is blocked. Use another card.';
  @override
  String get cardExpiredBody => 'The card has expired. Use another card.';
  @override
  String get cardOutsideValidityWindowBody => 'The card cannot be used at this time. Use another card.';
  @override
  String get channelNotAllowedBody => 'The card does not allow paying this way. Try another way.';
  @override
  String get cardLinkInactiveBody => 'The customer’s access to this card has expired. Use another card.';
  @override
  String get merchantNotAllowedBody => 'The card cannot be used for this taxi ride. Use another card.';
  @override
  String get insufficientFundsBody => 'The card balance is not enough. Use another card.';
  @override
  String get cardLimitExceededBody => 'The card limit is exceeded. Use another card.';
  @override
  String get servicePaymentInsufficientFundsBody => 'The customer’s Xperise wallet balance is not enough.';
  @override
  String get verificationExpiredBody => 'The confirmation time ran out. Pay again.';
  @override
  String get verificationFailedBody => 'Verification failed. Pay again.';
  @override
  String get cardLockedBody => 'Too many wrong codes, the card is locked for 15 minutes. Use another card.';
  @override
  String get velocityLimitExceededBody => 'The card was tried too many times. Wait a few minutes or use another way.';
  @override
  String get tokenInvalidOrExpiredBody => 'The payment code in the app has expired. Ask the customer to open a new one.';
  @override
  String get resendLimitReachedBody => 'The code was resent the maximum number of times. Pay again or choose another way.';
  @override
  String get noRegisteredPhoneBody => 'The card has no phone number to receive the code. Use another way.';
  @override
  String get staticCodeUnavailableBody => 'The card has no confirmation code yet. Use another way.';
  @override
  String get otpDeliveryFailedBody => 'The SMS code could not be sent. Try again.';
  @override
  String get cardNotFoundBody => 'Card not found. Check the card number or the QR code.';
  @override
  String get rideCardNotFoundBody => 'The ride has no linked card. Use the card the customer hands you.';
  @override
  String get chipUnusableBody => 'The chip card cannot be used. Use another way.';
  @override
  String get chipReadFailedBody => 'The chip card could not be read. Use another way.';
  @override
  String get qrExpiredBody => 'The QR code has expired. Create a new one.';

  @override
  String get fareChangedBody => 'The fare has been updated. Go back to checkout to confirm the new amount.';
  @override
  String get sessionInvalidBody => 'The payment session is not valid. Go back to checkout.';
  @override
  String get sessionUnavailableBody => 'The payment session could not be opened. Go back to checkout.';
  @override
  String get integrationErrorBody => 'Something went wrong while processing the payment.';

  @override
  String get corporateBudgetExceededBody => 'The company has used up its monthly budget. Call the XPAY hotline.';
  @override
  String get corporatePolicyRejectedBody => 'The company policy declined this transaction. Call the XPAY hotline.';
  @override
  String get policyCheckUnavailableBody => 'The policy check system is not responding. Call the XPAY hotline.';
  @override
  String get xperiseWalletUnavailableBody => 'The Xperise wallet is having problems. Call the XPAY hotline.';
  @override
  String get corporateWalletRefusedBody => 'The company wallet refused the payment. Call the XPAY hotline.';
  @override
  String get systemErrorBody => 'The system is having problems. Call the XPAY hotline.';
  @override
  String get unauthorizedBody => 'Could not connect to XPAY. Call the XPAY hotline.';
  @override
  String get retriesExhaustedBody => 'The payment did not go through. Call the XPAY hotline.';
}

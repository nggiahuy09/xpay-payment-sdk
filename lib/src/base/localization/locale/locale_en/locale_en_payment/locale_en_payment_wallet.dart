part of '../locale_en.dart';

final class $XPLocaleENPaymentWallet implements $XPLocaleBasePaymentWallet {
  const $XPLocaleENPaymentWallet();

  @override
  String get methodQrTitle => 'Show QR code';
  @override
  String get methodQrBody => 'The customer scans it with the XPERISE app';
  @override
  String get methodSmsTitle => 'Send code by SMS';
  @override
  String get methodEmailTitle => 'Send code by email';
  @override
  String get recipientsLoadFailedTitle => 'Could not load code recipients';
  @override
  String get recipientsLoadFailedBody => 'You can still collect with the QR code, or try loading again.';

  @override
  String get qrTitle => 'Verify with QR code';
  @override
  String get qrHeading => 'Scan to pay';
  @override
  String get qrBody => 'Ask the customer to scan the QR code below with the XPERISE app to pay from the corporate wallet';
  @override
  String get qrAmountLabel => 'Amount to collect';
  @override
  String get qrWaiting => 'Waiting for the customer to pay…';
  @override
  String get qrCreateFailedTitle => 'Could not create the QR code';
  @override
  String get qrRenderFailed => 'Could not display the QR code';
  @override
  String get qrCancelFailedTitle => 'Could not cancel the QR code';
  @override
  String get qrCancelFailedBody => 'The customer can still scan this code to pay. Please try again.';

  @override
  String otpSentSmsBody(String destination) => 'A 6-digit OTP was sent to the phone $destination. Please enter the code to verify.';
  @override
  String otpSentEmailBody(String destination) => 'A 6-digit OTP was sent to the email $destination. Please enter the code to verify.';
  @override
  String get channelSmsLabel => 'SMS';
  @override
  String get channelEmailLabel => 'Email';
  @override
  String get changeButton => 'Change';
  @override
  String get changeSheetTitle => 'Change OTP delivery method';
  @override
  String get changeSheetBody => 'Pick another phone number or email to send a new code.';
  @override
  String get changeCurrentLabel => 'Current';
  @override
  String get changeOthersLabel => 'Other methods';
  @override
  String get changeKeepButton => 'Keep current method';
  @override
  String codeSentBody(String destination) => 'To $destination';

  @override
  String get otpExpiredTitle => 'Code expired';
  @override
  String get otpExpiredBody => 'The verification code has expired. Please resend a new code.';
  @override
  String get otpLockedTitle => 'Code locked';
  @override
  String get otpLockedBody => 'The code was locked after too many incorrect attempts. Please resend a new code.';
  @override
  String get otpNotPendingTitle => 'Code no longer valid';
  @override
  String get otpNotPendingBody => 'This code can no longer be used. Please resend a new code.';
  @override
  String get otpVelocityExceededTitle => 'Too many codes requested';
  @override
  String get otpVelocityExceededBody => 'Too many codes were requested in a short time. Please try again in a few minutes or use the QR code.';
  @override
  String get otpDeliveryFailedTitle => 'Could not send the OTP';
  @override
  String get otpDeliveryFailedBody => 'The code could not be sent to the selected method. Please try again or pick another method.';
  @override
  String get otpRecipientUnavailableTitle => 'No contact on file';
  @override
  String get otpRecipientUnavailableBody => 'The recipient has no contact on file for this method. Please pick another method or use the QR code.';
  @override
  String get walletRefusedTitle => 'Corporate wallet refused the payment';
  @override
  String get walletRefusedBody => 'The corporate wallet did not accept this payment. The code is still valid, please try again later.';
  @override
  String get walletUnavailableTitle => 'Corporate wallet unavailable';
  @override
  String get walletUnavailableBody => 'The corporate wallet could not be reached. The code is still valid, please try again in a few minutes.';
  @override
  String get amountLockedTitle => 'Amount changed';
  @override
  String get amountLockedBody => 'The ride amount was just updated. Please start the payment again.';
  @override
  String get rideNotFoundTitle => 'Ride closed';
  @override
  String get rideNotFoundBody => 'The ride is no longer open for payment. Please check the ride status.';
  @override
  String get rideNotOnCorporateWalletTitle => 'Corporate wallet not available';
  @override
  String get rideNotOnCorporateWalletBody => 'This ride was not booked on the corporate wallet, so it cannot be paid this way.';
}

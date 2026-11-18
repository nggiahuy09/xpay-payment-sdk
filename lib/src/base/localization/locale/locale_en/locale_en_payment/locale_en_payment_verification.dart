part of '../locale_en.dart';

final class $XPLocaleENPaymentVerification implements $XPLocaleBasePaymentVerification {
  const $XPLocaleENPaymentVerification();

  @override
  String get otpTitle => 'Verify OTP';
  @override
  String get otpHeading => 'Enter verification code';
  @override
  String get expired => 'Expired';
  @override
  String get expiresIn => 'Expires in';
  @override
  String get verifyAndPayButton => 'Verify & pay';

  @override
  String get pinTitle => 'Enter PIN';
  @override
  String get pinHeading => 'Enter the card PIN';
  @override
  String get pinBody => 'Please hand the device to the cardholder to enter their 6-digit PIN.';
  @override
  String get tokenPinHeading => 'Enter the PIN from the app';
  @override
  String get tokenPinBody => 'Please hand the device to the cardholder to enter the 6-digit PIN shown in the XPERISE app.';
  @override
  String get verificationStaticCodeSuccessNote => 'The amount will be collected once the customer enters the correct card PIN.';
  @override
  String get verificationTokenPinSuccessNote => 'The amount will be collected once the customer enters the correct PIN shown in the XPERISE app.';
  @override
  String get confirmPaymentButton => 'Confirm payment';

  @override
  String get sessionExpiredTitle => 'Payment session expired';
  @override
  String get sessionExpiredBody => 'The payment time has run out. Please go back to the home screen and create a new transaction.';
  @override
  String get backToHomeButton => 'Back to home';
  @override
  String get backToDetailsButton => 'Back to transaction';
  @override
  String attemptsRemaining(int count) => '$count ${count > 1 ? 'attempts' : 'attempt'} remaining';

  @override
  String get abandonSheetTitle => 'Leave without verifying?';
  @override
  String get abandonSheetBody => 'This payment has not been verified yet, so the amount has not been collected from the user\'s card.';
  @override
  String get abandonStayButton => 'Keep verifying';
  @override
  String get abandonLeaveButton => 'Leave anyway';

  @override
  String get resendExpiredPrompt => 'This OTP code has expired.';
  @override
  String get resendButton => 'Resend code';
  @override
  String get resendSentTitle => 'New code sent';
  @override
  String resendSentBody(String phoneMasked) => 'A new OTP has been sent to the phone number ending in $phoneMasked. Please enter the new code to complete the payment.';
  @override
  String get resendSentButton => 'Got it';

  @override
  String get otpSentToLabel => 'Code sent to';
  @override
  String get otpSentBody => 'A 6-digit OTP was sent to the selected phone. Please enter the code to verify.';
  @override
  String get recipientChangeButton => 'Change';
  @override
  String get attemptsLeftLabel => 'Attempts';
  @override
  String attemptsLeftValue(int count) => '$count left';
  @override
  String resendButtonCooldown(int seconds) => 'Resend code (${seconds}s)';
  @override
  String get recipientPhoneCaption => 'Phone ending in';
  @override
  String get recipientPickerTitle => 'Choose OTP recipient';
  @override
  String get recipientPickerBody => 'Hand the device to the customer to pick the phone number that gets the code.';
  @override
  String get recipientSendButton => 'Send OTP';
  @override
  String get recipientCancelButton => 'Cancel';
  @override
  String get recipientSheetTitle => 'Change OTP recipient';
  @override
  String get recipientSheetBody => 'Pick another phone number to send a new code.';
  @override
  String get recipientCurrentLabel => 'Current number';
  @override
  String get recipientOthersLabel => 'Other numbers';
  @override
  String get recipientConfirmButton => 'Confirm and send OTP';
  @override
  String recipientConfirmButtonCooldown(int seconds) => 'Confirm and send OTP (${seconds}s)';
  @override
  String get recipientKeepButton => 'Keep current number';
  @override
  String get codeSentTitle => 'OTP sent';
  @override
  String codeSentBody(String phoneMasked) => 'The OTP has been sent to the phone number ending in $phoneMasked.';

  @override
  String get resendFailedTitle => 'Could not resend OTP code';
  @override
  String get resendNotApplicableTitle => 'Resend unavailable';
  @override
  String get resendNotApplicableBody => 'This card uses a printed PIN, so there is no code to send. Ask the customer to enter the PIN on the card.';
  @override
  String get resendTooSoonTitle => 'Please wait a moment';
  @override
  String get resendTooSoonBody => 'A code was just sent. Please wait a little longer before requesting another one.';
  @override
  String get resendLimitReachedTitle => 'No OTP resends left';
  @override
  String get resendLimitReachedBody => 'You have requested an OTP too many times for this payment. Please enter the OTP you received, or create a new transaction to try again.';
  @override
  String get resendRecipientRequiredTitle => 'Choose a phone number';
  @override
  String get resendRecipientRequiredBody => 'Please choose which phone number should receive the OTP.';
  @override
  String get resendRecipientInvalidTitle => 'Phone number unavailable';
  @override
  String get resendRecipientInvalidBody => 'This phone number can no longer receive codes for this card. Please choose another one.';

  @override
  String get verifyFailedTitle => 'Verification failed';
  @override
  String get invalidCodeTitle => 'Incorrect code';
  @override
  String get invalidCodeBody => 'The code you entered is incorrect. Please try again.';
  @override
  String get otpInvalidTitle => 'Invalid OTP';
  @override
  String get otpInvalidBody => 'The OTP entered is incorrect. Please check and try again.';
  @override
  String get pinInvalidTitle => 'Invalid PIN';
  @override
  String get pinInvalidBody => 'The PIN entered is incorrect. Please check and try again.';
}

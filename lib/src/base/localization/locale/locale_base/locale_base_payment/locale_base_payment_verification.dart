part of '../locale_base.dart';

abstract class $XPLocaleBasePaymentVerification {
  const $XPLocaleBasePaymentVerification();

  String get otpTitle;
  String get otpHeading;
  String get expired;
  String get expiresIn;
  String get verifyAndPayButton;

  String get pinTitle;
  String get pinHeading;
  String get pinBody;
  String get tokenPinHeading;
  String get tokenPinBody;
  String get verificationStaticCodeSuccessNote;
  String get verificationTokenPinSuccessNote;
  String get confirmPaymentButton;

  String get sessionExpiredTitle;
  String get sessionExpiredBody;
  String get backToHomeButton;
  String get backToDetailsButton;
  String attemptsRemaining(int count);

  String get abandonSheetTitle;
  String get abandonSheetBody;
  String get abandonStayButton;
  String get abandonLeaveButton;

  String get resendExpiredPrompt;
  String get resendButton;
  String get resendSentTitle;
  String resendSentBody(String phoneMasked);
  String get resendSentButton;

  String get otpSentToLabel;
  String get otpSentBody;
  String get recipientChangeButton;
  String get attemptsLeftLabel;
  String attemptsLeftValue(int count);
  String resendButtonCooldown(int seconds);
  String get recipientPhoneCaption;
  String get recipientPickerTitle;
  String get recipientPickerBody;
  String get recipientSendButton;
  String get recipientCancelButton;
  String get recipientSheetTitle;
  String get recipientSheetBody;
  String get recipientCurrentLabel;
  String get recipientOthersLabel;
  String get recipientConfirmButton;
  String recipientConfirmButtonCooldown(int seconds);
  String get recipientKeepButton;
  String get codeSentTitle;
  String codeSentBody(String phoneMasked);

  String get resendFailedTitle;
  String get resendNotApplicableTitle;
  String get resendNotApplicableBody;
  String get resendTooSoonTitle;
  String get resendTooSoonBody;
  String get resendLimitReachedTitle;
  String get resendLimitReachedBody;
  String get resendRecipientRequiredTitle;
  String get resendRecipientRequiredBody;
  String get resendRecipientInvalidTitle;
  String get resendRecipientInvalidBody;

  String get verifyFailedTitle;
  String get invalidCodeTitle;
  String get invalidCodeBody;
  String get otpInvalidTitle;
  String get otpInvalidBody;
  String get pinInvalidTitle;
  String get pinInvalidBody;
}

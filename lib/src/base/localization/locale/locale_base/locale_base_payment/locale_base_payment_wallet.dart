part of '../locale_base.dart';

abstract class $XPLocaleBasePaymentWallet {
  const $XPLocaleBasePaymentWallet();

  String get methodQrTitle;
  String get methodQrBody;
  String get methodSmsTitle;
  String get methodEmailTitle;
  String get recipientsLoadFailedTitle;
  String get recipientsLoadFailedBody;

  String get qrTitle;
  String get qrHeading;
  String get qrBody;
  String get qrAmountLabel;
  String get qrWaiting;
  String get qrCreateFailedTitle;
  String get qrRenderFailed;
  String get qrCancelFailedTitle;
  String get qrCancelFailedBody;

  String otpSentSmsBody(String destination);
  String otpSentEmailBody(String destination);
  String get channelSmsLabel;
  String get channelEmailLabel;
  String get changeButton;
  String get changeSheetTitle;
  String get changeSheetBody;
  String get changeCurrentLabel;
  String get changeOthersLabel;
  String get changeKeepButton;
  String codeSentBody(String destination);

  String get otpExpiredTitle;
  String get otpExpiredBody;
  String get otpLockedTitle;
  String get otpLockedBody;
  String get otpNotPendingTitle;
  String get otpNotPendingBody;
  String get otpVelocityExceededTitle;
  String get otpVelocityExceededBody;
  String get otpDeliveryFailedTitle;
  String get otpDeliveryFailedBody;
  String get otpRecipientUnavailableTitle;
  String get otpRecipientUnavailableBody;
  String get walletRefusedTitle;
  String get walletRefusedBody;
  String get walletUnavailableTitle;
  String get walletUnavailableBody;
  String get amountLockedTitle;
  String get amountLockedBody;
  String get rideNotFoundTitle;
  String get rideNotFoundBody;
  String get rideNotOnCorporateWalletTitle;
  String get rideNotOnCorporateWalletBody;
}

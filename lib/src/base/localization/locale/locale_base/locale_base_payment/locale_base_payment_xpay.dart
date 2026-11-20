part of '../locale_base.dart';

abstract class $XPLocaleBasePaymentXpay {
  $XPLocaleBasePaymentXpayDecline get decline;
  $XPLocaleBasePaymentXpayStatus get status;

  String get entryModeToken;
  String get entryModeManualPan;
  String get entryModeCardQr;
  String get entryModeChipTap;
  String get entryModeRideCard;

  String get entryModeManualPanAlternative;
  String get entryModeCardQrAlternative;
  String get entryModeChipTapAlternative;

  String get methodCardQrTitle;
  String get methodCardQrBody;
  String get methodManualPanTitle;
  String get methodManualPanBody;
  String get methodChipTapTitle;
  String get methodChipTapBody;
  String get methodTokenTitle;
  String get methodTokenBody;
  String get methodRideCardBody;

  String get entryTripTitle;
  String get entryRideRefLabel;
  String get entryPickupLabel;
  String get entryDestinationLabel;
  String get entryPlateNumberLabel;
  String get entryMethodsTitle;

  String get paymentItemFallbackTitle;
  String paymentItemTypeTitle(String type);

  String get paymentSuccessTitle;
  String get paymentSuccessBody;
  String get paymentFailedTitle;
  String resultGenericError(String? errorCode);

  String get paymentDuplicateRequestTitle;
  String get paymentDuplicateRequestBody;

  String get paymentTokenNotFoundBody;
  String get paymentManualPanNotFoundBody;
  String get paymentCardQrNotFoundBody;
  String get paymentChipTapNotFoundBody;
  String get paymentRideCardNotFoundBody;

  String get paymentNoRegisteredPhoneBody;
  String get paymentStaticCodeUnavailableBody;
  String get paymentOtpDeliveryFailedBody;
  String get paymentRideAlreadyPaidBody;

  String get paymentDeclinedTitle;
  String get paymentDeclinedBody;

  String get paymentNotProcessedTitle;
  String get paymentNotProcessedBody;

  String get successBadge;
  String get transactionIdLabel;
  String get transactionIdCopied;
  String get bookingRefLabel;
  String get bookingRefCopied;
  String get methodLabel;
  String get verifiedViaLabel;
  String get invoiceContentLabel;
  String get transactionTimeLabel;
  String get todayLabel;
  String get sendReceipt;
  String get newTransaction;
  String get finish;
  String get home;
  String get viewTransactionDetails;
  String get backToPreviousPage;

  String get scanQrTitle;
  String get nfcTitle;
  String get amountToChargeLabel;
  String get amountToCollectLabel;
  String get scanQrHint;
  String get uploadQrFromGallery;
  String get invalidQrCode;
  String get invalidQrCodeTitle;
  String get invalidQrCodeBody;

  String get nfcHintTitle;
  String get nfcHintBody;
  String get nfcNotSupportedTitle;
  String get nfcNotSupportedBody;
  String get nfcNotEnabledTitle;
  String get nfcNotEnabledBody;
  String get nfcNotSupportedCardTitle;
  String get nfcNotSupportedCardBody;
  String get nfcCardRevokedTitle;
  String get nfcCardRevokedBody;
  String get nfcCardNotActiveTitle;
  String get nfcCardNotActiveBody;
  String get nfcNotClassicCardBody;
  String get nfcReadFailedTitle;
  String get nfcVerifyFailedTitle;
  String nfcReadFailedBody(String? errorCode);
  String get nfcReadRetryBody;
  String get nfcCounterOutOfSyncBody;

  String get cameraPermissionRequiredTitle;
  String get cameraPermissionRequiredBody;
  String get openSettings;
  String get retry;
  String get close;
  String get gotIt;
}

part of '../locale_en.dart';

final class $XPLocaleENPaymentXpay implements $XPLocaleBasePaymentXpay {
  const $XPLocaleENPaymentXpay();

  @override
  $XPLocaleBasePaymentXpayDecline get decline => const $XPLocaleENPaymentXpayDecline();
  @override
  $XPLocaleBasePaymentXpayStatus get status => const $XPLocaleENPaymentXpayStatus();

  @override
  String get entryModeToken => 'a one-time payment code';
  @override
  String get entryModeManualPan => 'manual card number entry';
  @override
  String get entryModeCardQr => 'a card QR scan';
  @override
  String get entryModeChipTap => 'a card tap (NFC)';
  @override
  String get entryModeRideCard => "the customer's linked card";

  @override
  String get entryModeManualPanAlternative => 'enter the card number manually';
  @override
  String get entryModeCardQrAlternative => 'scan the QR printed on the card';
  @override
  String get entryModeChipTapAlternative => 'tap the card (NFC)';

  @override
  String get methodCardQrTitle => 'Scan QR code';
  @override
  String get methodCardQrBody => 'Scan the QR code printed on the XPAY card';
  @override
  String get methodManualPanTitle => 'Enter card manually';
  @override
  String get methodManualPanBody => 'Type the card number (PAN) and expiry';
  @override
  String get methodChipTapTitle => 'Tap card (NFC)';
  @override
  String get methodChipTapBody => 'Hold the payment card against the device to read';
  @override
  String get methodTokenTitle => 'One-time payment code';
  @override
  String get methodTokenBody => 'Scan the one-time payment code in the XPERISE app';
  @override
  String get methodRideCardBody => 'Linked card';

  @override
  String get entryTripTitle => 'Trip details';
  @override
  String get entryRideRefLabel => 'Ride ref';
  @override
  String get entryPickupLabel => 'Pickup';
  @override
  String get entryDestinationLabel => 'Destination';
  @override
  String get entryPlateNumberLabel => 'Plate number';
  @override
  String get entryMethodsTitle => 'Choose how to accept payment';

  @override
  String get paymentItemFallbackTitle => 'Payment';
  @override
  String paymentItemTypeTitle(String type) => 'Pay for $type';

  @override
  String get paymentSuccessTitle => 'Payment successful';
  @override
  String get paymentSuccessBody => 'The transaction has been recorded successfully.';
  @override
  String get paymentFailedTitle => 'Failed';
  @override
  String resultGenericError(String? errorCode) => 'Something went wrong while processing your payment. Please try again.${errorCode != null ? '\nError code: $errorCode' : ''}';

  @override
  String get paymentDuplicateRequestTitle => 'Duplicate request';
  @override
  String get paymentDuplicateRequestBody => 'This request matches a payment that was just sent. Check the transaction list before creating a new payment.';

  @override
  String get paymentTokenNotFoundBody => 'This payment code does not exist. Please ask the customer to open the QR code in the app again.';
  @override
  String get paymentManualPanNotFoundBody => 'The card details entered do not exist. Please check and enter the correct card number.';
  @override
  String get paymentCardQrNotFoundBody => 'No card matches this QR code. Please scan the QR code printed on the card again.';
  @override
  String get paymentChipTapNotFoundBody => 'The tapped card cannot be recognized. Please use the correct card provided by XPERISE.';
  @override
  String get paymentRideCardNotFoundBody => 'This ride is no longer assigned to you or can no longer be paid. Please check the ride again.';

  @override
  String get paymentNoRegisteredPhoneBody => 'No phone number was found to send the OTP to complete the payment. Please use another card, or contact your corporate admin.';
  @override
  String get paymentStaticCodeUnavailableBody => 'This card does not have a PIN set up to complete the payment. Please use another card, or contact your corporate admin.';
  @override
  String get paymentOtpDeliveryFailedBody => 'The OTP could not be sent to the cardholder\'s phone number. Please try again.';
  @override
  String get paymentRideAlreadyPaidBody => 'This ride already has a payment. Please check the ride status again.';

  @override
  String get paymentDeclinedTitle => 'Payment not successful';
  @override
  String get paymentDeclinedBody => 'The transaction was recorded but the payment was not completed.';

  @override
  String get paymentNotProcessedTitle => 'Payment could not be processed';
  @override
  String get paymentNotProcessedBody => 'This payment was not processed by the system.';

  @override
  String get successBadge => 'Success';
  @override
  String get transactionIdLabel => 'Transaction ID';
  @override
  String get transactionIdCopied => 'Transaction ID copied';
  @override
  String get bookingRefLabel => 'Booking ref';
  @override
  String get bookingRefCopied => 'Booking ref copied';
  @override
  String get methodLabel => 'Method';
  @override
  String get verifiedViaLabel => 'Verified via';
  @override
  String get invoiceContentLabel => 'Invoice description';
  @override
  String get transactionTimeLabel => 'Time';
  @override
  String get todayLabel => 'Today';
  @override
  String get sendReceipt => 'Send receipt';
  @override
  String get newTransaction => 'New transaction';
  @override
  String get finish => 'Finish';
  @override
  String get home => 'Home';
  @override
  String get viewTransactionDetails => 'View transaction';
  @override
  String get backToPreviousPage => 'Back to previous page';

  @override
  String get scanQrTitle => 'Scan QR code';
  @override
  String get nfcTitle => 'Tap card (NFC)';
  @override
  String get amountToChargeLabel => 'Amount to charge';
  @override
  String get amountToCollectLabel => 'Amount to collect';
  @override
  String get scanQrHint => 'Point your camera at the QR code to collect payment.';
  @override
  String get uploadQrFromGallery => 'Upload QR from gallery';
  @override
  String get invalidQrCode => 'Invalid QR code. Please scan the supported QR code.';
  @override
  String get invalidQrCodeTitle => 'Invalid QR code';
  @override
  String get invalidQrCodeBody => 'Please scan the supported QR code.';

  @override
  String get nfcHintTitle => 'Hold card to back of device';
  @override
  String get nfcHintBody => 'Hold still until the device finishes reading it.';
  @override
  String get nfcNotSupportedTitle => 'NFC not supported';
  @override
  String get nfcNotSupportedBody => 'Your device does not support NFC. Please select another payment method.';
  @override
  String get nfcNotEnabledTitle => 'NFC not enabled';
  @override
  String get nfcNotEnabledBody => 'Please enable NFC in from your device Settings.';
  @override
  String get nfcNotSupportedCardTitle => 'Invalid card used';
  @override
  String get nfcNotSupportedCardBody => 'This card cannot be recognized. Please use the correct card provided by XPERISE to start paying.';
  @override
  String get nfcCardRevokedTitle => 'Card no longer valid';
  @override
  String get nfcCardRevokedBody => 'This card has been deactivated and cannot be charged. Ask the cardholder to contact the issuer.';
  @override
  String get nfcCardNotActiveTitle => 'Card not activated';
  @override
  String get nfcCardNotActiveBody => 'This card has not finished setup yet and cannot be charged. Please use another card or contact support.';
  @override
  String get nfcNotClassicCardBody => 'This card cannot be charged by tapping. Please use another payment method.';
  @override
  String get nfcReadFailedTitle => 'Could not read card';
  @override
  String get nfcVerifyFailedTitle => 'Cannot verify this card for NFC payment';
  @override
  String nfcReadFailedBody(String? errorCode) => 'The card could not be read. Please try tapping again.${errorCode != null ? '\nError code: $errorCode' : ''}';
  @override
  String get nfcReadRetryBody => 'The card moved before it could be read. Hold it flat against the back of the phone and tap again.';
  @override
  String get nfcCounterOutOfSyncBody =>
      'Please try another payment method (QR, manual PAN) to continue with your payment. To re-enable NFC payment for this card, please contact support.';

  @override
  String get cameraPermissionRequiredTitle => 'Camera access needed';
  @override
  String get cameraPermissionRequiredBody => 'To scan the QR code, allow camera access for this app in Settings.';
  @override
  String get openSettings => 'Open Settings';
  @override
  String get retry => 'Retry';
  @override
  String get close => 'Close';
  @override
  String get gotIt => 'Got it';
}

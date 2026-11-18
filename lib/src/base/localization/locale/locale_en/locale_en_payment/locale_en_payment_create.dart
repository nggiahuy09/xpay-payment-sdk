part of '../locale_en.dart';

final class $XPLocaleENPaymentCreate implements $XPLocaleBasePaymentCreate {
  const $XPLocaleENPaymentCreate();

  @override
  String get manualEntryTitle => 'Enter card manually';
  @override
  String get manualEntrySubtitle => 'Enter card details to complete';

  @override
  String get manualEntryAmountLabel => 'Amount to charge';

  @override
  String get manualEntryPanLabel => 'Card number (PAN)';
  @override
  String get manualEntryPanHint => '0000 0000 0000 0000';
  @override
  String get manualEntryPanValid => 'Card number is valid';
  @override
  String get manualEntryPanInvalid => 'Card number is invalid';

  @override
  String get manualEntryExpiryLabel => 'Expiry date';
  @override
  String get manualEntryExpiryHint => 'MM/YY';

  @override
  String get manualEntryEncryptedNote => 'Card details are encrypted and never stored on the device.';

  @override
  String get manualEntrySubmitButton => 'Confirm payment';
}

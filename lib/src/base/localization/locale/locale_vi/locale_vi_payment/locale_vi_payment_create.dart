part of '../locale_vi.dart';

final class $XPLocaleVIPaymentCreate implements $XPLocaleBasePaymentCreate {
  const $XPLocaleVIPaymentCreate();

  @override
  String get manualEntryTitle => 'Nhập thẻ thủ công';
  @override
  String get manualEntrySubtitle => 'Nhập thông tin thẻ để hoàn tất';

  @override
  String get manualEntryAmountLabel => 'Số tiền cần thu';

  @override
  String get manualEntryPanLabel => 'Số thẻ (PAN)';
  @override
  String get manualEntryPanHint => '0000 0000 0000 0000';
  @override
  String get manualEntryPanValid => 'Số thẻ hợp lệ';
  @override
  String get manualEntryPanInvalid => 'Số thẻ không hợp lệ';

  @override
  String get manualEntryExpiryLabel => 'Ngày hết hạn';
  @override
  String get manualEntryExpiryHint => 'MM/YY';

  @override
  String get manualEntryEncryptedNote => 'Thông tin thẻ được mã hoá và không lưu trên thiết bị.';

  @override
  String get manualEntrySubmitButton => 'Xác nhận thanh toán';
}

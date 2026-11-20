part of '../locale_vi.dart';

final class $XPLocaleVIPaymentXpay implements $XPLocaleBasePaymentXpay {
  const $XPLocaleVIPaymentXpay();

  @override
  $XPLocaleBasePaymentXpayDecline get decline => const $XPLocaleVIPaymentXpayDecline();
  @override
  $XPLocaleBasePaymentXpayStatus get status => const $XPLocaleVIPaymentXpayStatus();

  @override
  String get entryModeToken => 'mã dùng một lần';
  @override
  String get entryModeManualPan => 'nhập số thẻ thủ công';
  @override
  String get entryModeCardQr => 'quét QR thẻ';
  @override
  String get entryModeChipTap => 'chạm thẻ (NFC)';
  @override
  String get entryModeRideCard => 'thẻ đã liên kết của khách';

  @override
  String get entryModeManualPanAlternative => 'nhập số thẻ thủ công';
  @override
  String get entryModeCardQrAlternative => 'quét QR in trên thẻ';
  @override
  String get entryModeChipTapAlternative => 'chạm thẻ (NFC)';

  @override
  String get methodCardQrTitle => 'Quét mã QR';
  @override
  String get methodCardQrBody => 'Quét mã QR in trên thẻ XPAY';
  @override
  String get methodManualPanTitle => 'Nhập số thẻ thủ công';
  @override
  String get methodManualPanBody => 'Nhập số thẻ (PAN) và ngày hết hạn';
  @override
  String get methodChipTapTitle => 'Chạm thẻ (NFC)';
  @override
  String get methodChipTapBody => 'Chạm thẻ thanh toán vào thiết bị để đọc thông tin';
  @override
  String get methodTokenTitle => 'Mã thanh toán 1 lần';
  @override
  String get methodTokenBody => 'Quét mã thanh toán dùng một lần trên ứng dụng XPERISE';
  @override
  String get methodRideCardBody => 'Thẻ đã liên kết';

  @override
  String get entryTripTitle => 'Thông tin chuyến đi';
  @override
  String get entryRideRefLabel => 'Mã cuốc';
  @override
  String get entryPickupLabel => 'Điểm đón';
  @override
  String get entryDestinationLabel => 'Điểm trả';
  @override
  String get entryPlateNumberLabel => 'Biển số xe';
  @override
  String get entryMethodsTitle => 'Chọn cách nhận thanh toán';

  @override
  String get paymentItemFallbackTitle => 'Thanh toán';
  @override
  String paymentItemTypeTitle(String type) => 'Thanh toán cho $type';

  @override
  String get paymentSuccessTitle => 'Thanh toán thành công';
  @override
  String get paymentSuccessBody => 'Giao dịch đã được ghi nhận thành công.';
  @override
  String get paymentFailedTitle => 'Thất bại';
  @override
  String resultGenericError(String? errorCode) => 'Đã xảy ra lỗi khi xử lý thanh toán. Vui lòng thử lại.${errorCode != null ? '\nMã lỗi: $errorCode' : ''}';

  @override
  String get paymentDuplicateRequestTitle => 'Yêu cầu trùng lặp';
  @override
  String get paymentDuplicateRequestBody => 'Yêu cầu này trùng với một giao dịch vừa được gửi. Vui lòng kiểm tra danh sách giao dịch trước khi tạo giao dịch mới.';

  @override
  String get paymentTokenNotFoundBody => 'Mã thanh toán không tồn tại. Vui lòng yêu cầu khách mở lại mã QR trong ứng dụng.';
  @override
  String get paymentManualPanNotFoundBody => 'Thông tin thẻ đã nhập không tồn tại. Vui lòng kiểm tra lại và nhập đúng số thẻ.';
  @override
  String get paymentCardQrNotFoundBody => 'Không có thẻ nào khớp với mã QR này. Vui lòng quét lại mã QR in trên thẻ.';
  @override
  String get paymentChipTapNotFoundBody => 'Không nhận diện được thẻ đã chạm. Vui lòng sử dụng đúng thẻ được cung cấp bởi XPERISE.';
  @override
  String get paymentRideCardNotFoundBody => 'Chuyến đi này không còn được giao cho bạn hoặc không còn ở trạng thái có thể thanh toán. Vui lòng kiểm tra lại chuyến đi.';

  @override
  String get paymentNoRegisteredPhoneBody => 'Không tìm thấy số điện thoại để gửi mã OTP hoàn tất thanh toán. Vui lòng sử dụng thẻ khác, hoặc liên hệ quản trị viên doanh nghiệp.';
  @override
  String get paymentStaticCodeUnavailableBody => 'Thẻ này chưa được thiết lập mã PIN để hoàn tất thanh toán. Vui lòng sử dụng thẻ khác, hoặc liên hệ quản trị viên doanh nghiệp.';
  @override
  String get paymentOtpDeliveryFailedBody => 'Gửi mã OTP đến số điện thoại của chủ thẻ không thành công. Vui lòng thử lại.';
  @override
  String get paymentRideAlreadyPaidBody => 'Chuyến đi này đã có giao dịch thanh toán. Vui lòng kiểm tra lại trạng thái chuyến đi.';

  @override
  String get paymentDeclinedTitle => 'Thanh toán không thành công';
  @override
  String get paymentDeclinedBody => 'Giao dịch đã được ghi nhận nhưng thanh toán chưa hoàn tất.';

  @override
  String get paymentNotProcessedTitle => 'Không thể xử lý thanh toán';
  @override
  String get paymentNotProcessedBody => 'Hệ thống không xử lý được giao dịch này.';

  @override
  String get successBadge => 'Thành công';
  @override
  String get transactionIdLabel => 'Mã giao dịch';
  @override
  String get transactionIdCopied => 'Đã sao chép mã giao dịch';
  @override
  String get bookingRefLabel => 'Mã đặt chỗ';
  @override
  String get bookingRefCopied => 'Đã sao chép mã đặt chỗ';
  @override
  String get methodLabel => 'Phương thức';
  @override
  String get verifiedViaLabel => 'Xác thực qua';
  @override
  String get invoiceContentLabel => 'Nội dung hoá đơn';
  @override
  String get transactionTimeLabel => 'Thời gian';
  @override
  String get todayLabel => 'Hôm nay';
  @override
  String get sendReceipt => 'Gửi biên lai';
  @override
  String get newTransaction => 'Giao dịch mới';
  @override
  String get finish => 'Hoàn tất';
  @override
  String get home => 'Trang chủ';
  @override
  String get viewTransactionDetails => 'Xem giao dịch';
  @override
  String get backToPreviousPage => 'Quay lại trang trước';

  @override
  String get scanQrTitle => 'Quét mã QR';
  @override
  String get nfcTitle => 'Chạm thẻ (NFC)';
  @override
  String get amountToChargeLabel => 'Số tiền cần thu';
  @override
  String get amountToCollectLabel => 'Số tiền cần thu';
  @override
  String get scanQrHint => 'Hướng camera vào mã QR để thực hiện giao dịch.';
  @override
  String get uploadQrFromGallery => 'Tải ảnh QR từ thư viện';
  @override
  String get invalidQrCode => 'Mã QR không hợp lệ. Vui lòng quét đúng mã QR được hỗ trợ.';
  @override
  String get invalidQrCodeTitle => 'Mã QR không hợp lệ';
  @override
  String get invalidQrCodeBody => 'Vui lòng quét đúng mã QR được hỗ trợ.';

  @override
  String get nfcHintTitle => 'Đặt thẻ lên mặt sau thiết bị';
  @override
  String get nfcHintBody => 'Giữ yên cho đến khi thiết bị đọc xong';
  @override
  String get nfcNotSupportedTitle => 'NFC không được hỗ trợ';
  @override
  String get nfcNotSupportedBody => 'Thiết bị không hỗ trợ tính năng NFC. Vui lòng sử dụng phương thức thanh toán khác.';
  @override
  String get nfcNotEnabledTitle => 'NFC chưa được bật';
  @override
  String get nfcNotEnabledBody => 'Vui lòng bật tính năng NFC trong phần Cài đặt của thiết bị.';
  @override
  String get nfcNotSupportedCardTitle => 'Thẻ không hợp lệ';
  @override
  String get nfcNotSupportedCardBody => 'Thẻ không hợp lệ. Vui lòng sử dụng thẻ được cung cấp bởi XPERISE để thanh toán.';
  @override
  String get nfcCardRevokedTitle => 'Thẻ không còn hiệu lực';
  @override
  String get nfcCardRevokedBody => 'Thẻ này đã bị vô hiệu hóa và không thể thanh toán. Vui lòng đề nghị chủ thẻ liên hệ đơn vị phát hành.';
  @override
  String get nfcCardNotActiveTitle => 'Thẻ chưa được kích hoạt';
  @override
  String get nfcCardNotActiveBody => 'Thẻ này chưa hoàn tất thiết lập nên không thể thanh toán. Vui lòng dùng thẻ khác hoặc liên hệ bộ phận hỗ trợ.';
  @override
  String get nfcNotClassicCardBody => 'Thẻ này không thể thanh toán bằng cách chạm. Vui lòng sử dụng phương thức thanh toán khác.';
  @override
  String get nfcReadFailedTitle => 'Không đọc được thẻ';
  @override
  String get nfcVerifyFailedTitle => 'Không thể xác thực thẻ bằng NFC';
  @override
  String nfcReadFailedBody(String? errorCode) => 'Không thể đọc thẻ. Vui lòng chạm thẻ lại.${errorCode != null ? '\nMã lỗi: $errorCode' : ''}';
  @override
  String get nfcReadRetryBody => 'Thẻ bị di chuyển trước khi đọc xong. Vui lòng đặt thẻ sát mặt sau điện thoại và chạm lại.';
  @override
  String get nfcCounterOutOfSyncBody =>
      'Vui lòng sử dụng phương thức thanh toán khác (quét mã QR, điền số thẻ) để thanh toán. Để kích hoạt lại tính năng thanh toán bằng NFC cho thẻ, vui lòng liên hệ bộ phận hỗ trợ.';

  @override
  String get cameraPermissionRequiredTitle => 'Cần quyền camera';
  @override
  String get cameraPermissionRequiredBody => 'Để quét mã QR, vui lòng cho phép ứng dụng truy cập camera trong phần Cài đặt.';
  @override
  String get openSettings => 'Mở cài đặt';
  @override
  String get retry => 'Thử lại';
  @override
  String get close => 'Đóng';
  @override
  String get gotIt => 'Đã hiểu';
}

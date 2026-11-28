part of '../locale_vi.dart';

final class $XPLocaleVIPaymentWallet implements $XPLocaleBasePaymentWallet {
  const $XPLocaleVIPaymentWallet();

  @override
  String get methodQrTitle => 'Hiển thị mã QR';
  @override
  String get methodQrBody => 'Khách quét mã bằng ứng dụng XPERISE';
  @override
  String get methodSmsTitle => 'Gửi mã qua SMS';
  @override
  String get methodEmailTitle => 'Gửi mã qua email';
  @override
  String get recipientsLoadFailedTitle => 'Không tải được danh sách nhận mã';
  @override
  String get recipientsLoadFailedBody => 'Bạn vẫn có thể thu tiền bằng mã QR hoặc thử tải lại.';

  @override
  String get qrTitle => 'Xác thực bằng mã QR';
  @override
  String get qrHeading => 'Quét mã để thanh toán';
  @override
  String get qrBody => 'Hãy yêu cầu khách quét mã QR bên dưới bằng ứng dụng XPERISE để thanh toán bằng ví doanh nghiệp';
  @override
  String get qrAmountLabel => 'Số tiền sẽ thu';
  @override
  String get qrWaiting => 'Đang chờ khách thanh toán…';
  @override
  String get qrCreateFailedTitle => 'Không tạo được mã QR';
  @override
  String get qrRenderFailed => 'Không hiển thị được mã QR';
  @override
  String get qrCancelFailedTitle => 'Không huỷ được mã QR';
  @override
  String get qrCancelFailedBody => 'Khách vẫn có thể quét mã này để thanh toán. Vui lòng thử lại.';

  @override
  String otpSentSmsBody(String destination) => 'Mã OTP gồm 6 số đã được gửi tới số điện thoại $destination. Vui lòng nhập mã để xác thực.';
  @override
  String otpSentEmailBody(String destination) => 'Mã OTP gồm 6 số đã được gửi tới email $destination. Vui lòng nhập mã để xác thực.';
  @override
  String get channelSmsLabel => 'SMS';
  @override
  String get channelEmailLabel => 'Email';
  @override
  String get changeButton => 'Đổi';
  @override
  String get changeSheetTitle => 'Đổi phương thức nhận OTP';
  @override
  String get changeSheetBody => 'Chọn số điện thoại hoặc email khác để gửi mã mới.';
  @override
  String get changeCurrentLabel => 'Đang dùng';
  @override
  String get changeOthersLabel => 'Phương thức khác';
  @override
  String get changeKeepButton => 'Vẫn dùng phương thức cũ';
  @override
  String codeSentBody(String destination) => 'Tới $destination';

  @override
  String get otpExpiredTitle => 'Mã đã hết hạn';
  @override
  String get otpExpiredBody => 'Mã xác thực đã hết hạn. Vui lòng gửi lại mã mới.';
  @override
  String get otpLockedTitle => 'Mã đã bị khoá';
  @override
  String get otpLockedBody => 'Mã đã bị khoá do nhập sai quá số lần cho phép. Vui lòng gửi lại mã mới.';
  @override
  String get otpNotPendingTitle => 'Mã không còn hiệu lực';
  @override
  String get otpNotPendingBody => 'Mã này không còn dùng được. Vui lòng gửi lại mã mới.';
  @override
  String get otpVelocityExceededTitle => 'Gửi mã quá nhiều lần';
  @override
  String get otpVelocityExceededBody => 'Đã yêu cầu quá nhiều mã trong thời gian ngắn. Vui lòng thử lại sau ít phút hoặc dùng mã QR.';
  @override
  String get otpDeliveryFailedTitle => 'Không gửi được mã OTP';
  @override
  String get otpDeliveryFailedBody => 'Không thể gửi mã tới phương thức đã chọn. Vui lòng thử lại hoặc chọn phương thức khác.';
  @override
  String get otpRecipientUnavailableTitle => 'Không có thông tin nhận mã';
  @override
  String get otpRecipientUnavailableBody => 'Người nhận chưa có thông tin cho phương thức này. Vui lòng chọn phương thức khác hoặc dùng mã QR.';
  @override
  String get walletRefusedTitle => 'Ví doanh nghiệp từ chối thanh toán';
  @override
  String get walletRefusedBody => 'Ví doanh nghiệp chưa chấp nhận thanh toán này. Mã vẫn còn hiệu lực, vui lòng thử lại sau.';
  @override
  String get walletUnavailableTitle => 'Ví doanh nghiệp tạm thời gián đoạn';
  @override
  String get walletUnavailableBody => 'Không kết nối được ví doanh nghiệp. Mã vẫn còn hiệu lực, vui lòng thử lại sau ít phút.';
  @override
  String get amountLockedTitle => 'Số tiền đã thay đổi';
  @override
  String get amountLockedBody => 'Số tiền của chuyến đi vừa được cập nhật. Vui lòng tạo lại giao dịch.';
  @override
  String get rideNotFoundTitle => 'Chuyến đi đã đóng';
  @override
  String get rideNotFoundBody => 'Chuyến đi không còn mở để thanh toán. Vui lòng kiểm tra lại trạng thái chuyến đi.';
  @override
  String get rideNotOnCorporateWalletTitle => 'Không dùng được ví doanh nghiệp';
  @override
  String get rideNotOnCorporateWalletBody => 'Chuyến đi này không được đặt bằng ví doanh nghiệp nên không thể thanh toán theo cách này.';
}

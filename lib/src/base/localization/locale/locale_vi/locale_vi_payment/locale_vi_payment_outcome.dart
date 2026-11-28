part of '../locale_vi.dart';

final class $XPLocaleVIPaymentOutcome implements $XPLocaleBasePaymentOutcome {
  const $XPLocaleVIPaymentOutcome();

  @override
  String get statusCheckTitle => 'Đang kiểm tra trạng thái chuyến';
  @override
  String get statusCheckBody => 'Vui lòng chờ trong giây lát.';

  @override
  String get backToCheckout => 'Quay lại trang thanh toán';
  @override
  String get hotlineCallBody => 'Vui lòng gọi tổng đài XPAY để được hỗ trợ trước khi tiếp tục.';
  @override
  String get hotlineNumberLabel => 'Tổng đài XPAY';
  @override
  String get hotlineCopiedLabel => 'Đã sao chép số tổng đài. Dán vào ứng dụng gọi điện để gọi.';
  @override
  String get hotlineConfirmLabel => 'Tôi đã gọi và xác nhận với tổng đài';
  @override
  String get continueLabel => 'Tiếp tục';

  @override
  String get optionsTitle => 'Thanh toán chưa thành công';
  @override
  String get optionsBody => 'Hãy chọn cách thanh toán tiếp theo như đã thống nhất với tổng đài.';
  @override
  String get retryXpayTitle => 'Thử lại với XPAY';
  @override
  String get retryXpayBody => 'Quay lại chọn cách thanh toán bằng XPAY';
  @override
  String get otherMethodTitle => 'Thử lại với phương thức thanh toán khác';
  @override
  String get otherMethodBody => 'Đóng XPAY, chọn phương thức khác trên màn thanh toán';
  @override
  String get hotlinePayTitle => 'Tổng đài thanh toán dùm';
  @override
  String get hotlinePayBody => 'Tổng đài XPAY sẽ thanh toán giúp khách';

  @override
  String get hotlineWaitTitle => 'Đang chờ tổng đài thanh toán';
  @override
  String get hotlineWaitBody => 'Vui lòng giữ nguyên màn hình này cho đến khi tổng đài thanh toán xong.';
  @override
  String get hotlineWaitTimeLeftLabel => 'Thời gian chờ còn lại';

  @override
  String get paidByHotlineLabel => 'Tổng đài đã thanh toán';
  @override
  String get backLabel => 'Quay lại';
  @override
  String autoBackLabel(int seconds) => 'Quay lại · tự động sau $seconds giây';

  @override
  String get rideCompletedTitle => 'Tổng đài đã đóng chuyến, không thu';
  @override
  String get rideCompletedBody => 'Tổng đài XPAY đã đóng chuyến này mà không trừ tiền của khách. Không thu thêm.';
  @override
  String get rideCancelledTitle => 'Chuyến đã huỷ';
  @override
  String get rideCancelledBody => 'Chuyến này đã bị huỷ hoặc đã chuyển sang hãng khác. Không thu tiền của khách.';
  @override
  String get rideStatusLabel => 'Trạng thái chuyến';
  @override
  String get rideStatusCompleted => 'Đã đóng';
  @override
  String get rideStatusCancelled => 'Đã huỷ';
  @override
  String get amountCollectedLabel => 'Số tiền thu';

  @override
  String get cardInactiveBody => 'Thẻ chưa được kích hoạt. Dùng thẻ khác hoặc cách thanh toán khác.';
  @override
  String get cardBlockedBody => 'Thẻ đang bị khoá. Dùng thẻ khác.';
  @override
  String get cardExpiredBody => 'Thẻ đã hết hạn. Dùng thẻ khác.';
  @override
  String get cardOutsideValidityWindowBody => 'Thẻ chưa được phép dùng vào lúc này. Dùng thẻ khác.';
  @override
  String get channelNotAllowedBody => 'Thẻ không cho thanh toán theo cách này. Thử cách khác.';
  @override
  String get cardLinkInactiveBody => 'Quyền dùng thẻ của khách đã hết hạn. Dùng thẻ khác.';
  @override
  String get merchantNotAllowedBody => 'Thẻ không dùng được cho chuyến taxi này. Dùng thẻ khác.';
  @override
  String get insufficientFundsBody => 'Thẻ không đủ số dư. Dùng thẻ khác.';
  @override
  String get cardLimitExceededBody => 'Vượt hạn mức của thẻ. Dùng thẻ khác.';
  @override
  String get servicePaymentInsufficientFundsBody => 'Ví Xperise của khách không đủ số dư.';
  @override
  String get verificationExpiredBody => 'Quá thời gian xác nhận. Thanh toán lại.';
  @override
  String get verificationFailedBody => 'Xác thực không thành công. Thanh toán lại.';
  @override
  String get cardLockedBody => 'Nhập sai mã quá số lần, thẻ tạm khoá 15 phút. Dùng thẻ khác.';
  @override
  String get velocityLimitExceededBody => 'Thẻ đã thử quá nhiều lần. Chờ vài phút hoặc dùng cách khác.';
  @override
  String get tokenInvalidOrExpiredBody => 'Mã thanh toán trong app đã hết hạn. Nhờ khách mở mã mới.';
  @override
  String get resendLimitReachedBody => 'Đã gửi lại mã tối đa. Thanh toán lại hoặc chọn cách khác.';
  @override
  String get noRegisteredPhoneBody => 'Thẻ chưa có số điện thoại nhận mã. Dùng cách khác.';
  @override
  String get staticCodeUnavailableBody => 'Thẻ chưa có mã xác nhận. Dùng cách khác.';
  @override
  String get otpDeliveryFailedBody => 'Không gửi được mã SMS. Thử lại.';
  @override
  String get cardNotFoundBody => 'Không tìm thấy thẻ. Kiểm tra lại số thẻ hoặc mã QR.';
  @override
  String get rideCardNotFoundBody => 'Chuyến không gắn thẻ. Dùng thẻ khách đưa.';
  @override
  String get chipUnusableBody => 'Thẻ chip không dùng được. Dùng cách khác.';
  @override
  String get chipReadFailedBody => 'Đọc thẻ chip lỗi. Dùng cách khác.';
  @override
  String get qrExpiredBody => 'Mã QR đã hết hạn. Tạo mã mới.';

  @override
  String get fareChangedBody => 'Cước đã được cập nhật. Quay lại trang thanh toán để xác nhận số tiền mới.';
  @override
  String get sessionInvalidBody => 'Phiên thanh toán không hợp lệ. Quay lại trang thanh toán.';
  @override
  String get sessionUnavailableBody => 'Không mở được phiên thanh toán. Quay lại trang thanh toán.';
  @override
  String get integrationErrorBody => 'Đã xảy ra lỗi khi xử lý thanh toán.';

  @override
  String get corporateBudgetExceededBody => 'Công ty đã hết ngân sách tháng. Gọi tổng đài XPAY.';
  @override
  String get corporatePolicyRejectedBody => 'Giao dịch bị chính sách công ty từ chối. Gọi tổng đài XPAY.';
  @override
  String get policyCheckUnavailableBody => 'Hệ thống kiểm tra chính sách không phản hồi. Gọi tổng đài XPAY.';
  @override
  String get xperiseWalletUnavailableBody => 'Ví Xperise đang lỗi. Gọi tổng đài XPAY.';
  @override
  String get corporateWalletRefusedBody => 'Ví công ty từ chối thanh toán. Gọi tổng đài XPAY.';
  @override
  String get systemErrorBody => 'Hệ thống đang gặp sự cố. Gọi tổng đài XPAY.';
  @override
  String get unauthorizedBody => 'Không kết nối được XPAY. Gọi tổng đài XPAY.';
  @override
  String get retriesExhaustedBody => 'Thanh toán chưa thành công. Gọi tổng đài XPAY.';
}

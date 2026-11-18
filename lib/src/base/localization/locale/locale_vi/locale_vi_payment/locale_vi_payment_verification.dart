part of '../locale_vi.dart';

final class $XPLocaleVIPaymentVerification implements $XPLocaleBasePaymentVerification {
  const $XPLocaleVIPaymentVerification();

  @override
  String get otpTitle => 'Xác thực OTP';
  @override
  String get otpHeading => 'Nhập mã xác thực';
  @override
  String get expired => 'Đã hết hạn';
  @override
  String get expiresIn => 'Hết hạn sau';
  @override
  String get verifyAndPayButton => 'Xác thực & thanh toán';

  @override
  String get pinTitle => 'Nhập mã PIN';
  @override
  String get pinHeading => 'Nhập mã PIN của thẻ';
  @override
  String get pinBody => 'Hãy đưa thiết bị cho khách giữ thẻ để nhập mã PIN gồm 6 chữ số.';
  @override
  String get tokenPinHeading => 'Nhập mã PIN từ ứng dụng';
  @override
  String get tokenPinBody => 'Hãy đưa thiết bị cho khách giữ thẻ để nhập mã PIN gồm 6 chữ số đang hiển thị trên ứng dụng XPERISE.';
  @override
  String get verificationStaticCodeSuccessNote => 'Tiền sẽ được thu khi khách nhập đúng mã PIN của thẻ.';
  @override
  String get verificationTokenPinSuccessNote => 'Tiền sẽ được thu khi khách nhập đúng mã PIN đang hiển thị trên ứng dụng XPERISE.';
  @override
  String get confirmPaymentButton => 'Xác nhận thanh toán';

  @override
  String get sessionExpiredTitle => 'Phiên thanh toán hết hạn';
  @override
  String get sessionExpiredBody => 'Đã hết thời gian thanh toán. Vui lòng quay về trang chủ và tạo giao dịch mới.';
  @override
  String get backToHomeButton => 'Quay về trang chủ';
  @override
  String get backToDetailsButton => 'Về chi tiết giao dịch';
  @override
  String attemptsRemaining(int count) => 'Còn $count lần thử';

  @override
  String get abandonSheetTitle => 'Thoát mà không xác thực?';
  @override
  String get abandonSheetBody => 'Giao dịch này chưa được xác thực nên tiền chưa được thu.';
  @override
  String get abandonStayButton => 'Tiếp tục xác thực';
  @override
  String get abandonLeaveButton => 'Vẫn thoát';

  @override
  String get resendExpiredPrompt => 'Mã OTP này đã hết hạn.';
  @override
  String get resendButton => 'Gửi lại mã';
  @override
  String get resendSentTitle => 'Đã gửi mã OTP mới';
  @override
  String resendSentBody(String phoneMasked) => 'Mã OTP mới đã được gửi đến số điện thoại có đuôi $phoneMasked. Vui lòng nhập mã mới để hoàn tất giao dịch.';
  @override
  String get resendSentButton => 'Đã hiểu';

  @override
  String get otpSentToLabel => 'Đã gửi mã tới';
  @override
  String get otpSentBody => 'Mã OTP 6 số đã được gửi tới số điện thoại đã chọn. Vui lòng nhập mã để xác thực.';
  @override
  String get recipientChangeButton => 'Đổi số';
  @override
  String get attemptsLeftLabel => 'Lượt thử';
  @override
  String attemptsLeftValue(int count) => 'còn $count';
  @override
  String resendButtonCooldown(int seconds) => 'Gửi lại mã (${seconds}s)';
  @override
  String get recipientPhoneCaption => 'Số điện thoại đuôi';
  @override
  String get recipientPickerTitle => 'Chọn số nhận OTP';
  @override
  String get recipientPickerBody => 'Đưa thiết bị cho khách để chọn số điện thoại sẽ nhận mã.';
  @override
  String get recipientSendButton => 'Gửi OTP';
  @override
  String get recipientCancelButton => 'Huỷ';
  @override
  String get recipientSheetTitle => 'Đổi số nhận OTP';
  @override
  String get recipientSheetBody => 'Chọn số điện thoại khác để gửi mã mới.';
  @override
  String get recipientCurrentLabel => 'Số hiện tại';
  @override
  String get recipientOthersLabel => 'Số khác';
  @override
  String get recipientConfirmButton => 'Xác nhận và gửi OTP';
  @override
  String recipientConfirmButtonCooldown(int seconds) => 'Xác nhận và gửi OTP (${seconds}s)';
  @override
  String get recipientKeepButton => 'Giữ số hiện tại';
  @override
  String get codeSentTitle => 'Đã gửi mã OTP';
  @override
  String codeSentBody(String phoneMasked) => 'Mã OTP đã được gửi đến số điện thoại có đuôi $phoneMasked.';

  @override
  String get resendFailedTitle => 'Không gửi lại được mã OTP';
  @override
  String get resendNotApplicableTitle => 'Không thể gửi lại';
  @override
  String get resendNotApplicableBody => 'Thẻ này dùng mã PIN in trên thẻ nên không có mã để gửi. Vui lòng đề nghị khách nhập mã PIN trên thẻ.';
  @override
  String get resendTooSoonTitle => 'Vui lòng đợi một chút';
  @override
  String get resendTooSoonBody => 'Mã vừa được gửi. Vui lòng đợi thêm một chút trước khi yêu cầu mã mới.';
  @override
  String get resendLimitReachedTitle => 'Đã hết lượt gửi OTP';
  @override
  String get resendLimitReachedBody => 'Bạn đã yêu cầu OTP quá nhiều lần cho giao dịch này. Vui lòng nhập OTP đã nhận, hoặc tạo giao dịch mới để thử lại.';
  @override
  String get resendRecipientRequiredTitle => 'Chưa chọn số điện thoại';
  @override
  String get resendRecipientRequiredBody => 'Vui lòng chọn số điện thoại sẽ nhận mã OTP.';
  @override
  String get resendRecipientInvalidTitle => 'Số điện thoại không hợp lệ';
  @override
  String get resendRecipientInvalidBody => 'Số điện thoại này không còn nhận được mã cho thẻ. Vui lòng chọn số khác.';

  @override
  String get verifyFailedTitle => 'Xác thực thất bại';
  @override
  String get invalidCodeTitle => 'Mã không đúng';
  @override
  String get invalidCodeBody => 'Mã bạn nhập không đúng. Vui lòng thử lại.';
  @override
  String get otpInvalidTitle => 'Mã OTP không hợp lệ';
  @override
  String get otpInvalidBody => 'Mã OTP đã nhập không đúng. Vui lòng kiểm tra và thử lại.';
  @override
  String get pinInvalidTitle => 'Mã PIN không hợp lệ';
  @override
  String get pinInvalidBody => 'Mã PIN đã nhập không đúng. Vui lòng kiểm tra và thử lại.';
}

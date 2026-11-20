part of '../locale_vi.dart';

final class $XPLocaleVIPaymentXpayDecline implements $XPLocaleBasePaymentXpayDecline {
  const $XPLocaleVIPaymentXpayDecline();

  @override
  String get insufficientFunds => 'Thẻ không đủ số dư. Vui lòng dùng thẻ khác.';
  @override
  String get cardInactive => 'Thẻ chưa được kích hoạt. Vui lòng dùng thẻ khác.';
  @override
  String get cardBlocked => 'Thẻ đã bị khóa. Vui lòng dùng thẻ khác.';
  @override
  String get cardExpired => 'Thẻ đã hết hạn. Vui lòng dùng thẻ khác.';
  @override
  String get cardOutsideValidityWindow => 'Thẻ đã nhập không dùng được tại thời điểm này trong ngày. Vui lòng sử dụng thẻ khác, hoặc liên hệ quản trị viên doanh nghiệp.';
  @override
  String get cardLinkInactive => 'Bạn không có quyền thanh toán bằng thẻ đã dùng. Vui lòng sử dụng thẻ khác để hoàn tất thanh toán.';
  @override
  String get perTransactionLimitExceeded => 'Số tiền vượt quá hạn mức mỗi giao dịch của thẻ.';
  @override
  String get dailyLimitExceeded => 'Thẻ đã đạt hạn mức chi tiêu trong ngày.';
  @override
  String get monthlyLimitExceeded => 'Thẻ đã đạt hạn mức chi tiêu trong tháng.';
  @override
  String get corporateMonthlyLimitExceeded => 'Hạn mức hằng tháng doanh nghiệp không đủ để thanh toán cho giao dịch này. Vui lòng liên hệ quản trị viên doanh nghiệp để xử lý.';
  @override
  String get tripBudgetExceeded => 'Giao dịch vượt quá ngân sách cho phép của chuyến đi.';
  @override
  String get policyViolation => 'Giao dịch không được phép theo chính sách chi tiêu.';
  @override
  String get employeePolicyViolation => 'Giao dịch không được phép theo chính sách chi tiêu của nhân viên. Vui lòng liên hệ quản trị viên doanh nghiệp để xử lý.';
  @override
  String get employeePolicyUnavailable => 'Hiện chưa thể kiểm tra chính sách chi tiêu. Vui lòng thử lại sau vài phút.';
  @override
  String get merchantNotAllowed => 'Thẻ không được phép dùng với đơn vị chấp nhận này.';
  @override
  String get mccNotAllowed => 'Thẻ không được phép dùng cho loại đơn vị chấp nhận này.';
  @override
  String channelNotAllowed(String? current, [List<String>? others]) {
    final alternatives = others?.where((other) => other.isNotEmpty) ?? const <String>[];
    if (current == null || current.isEmpty || alternatives.isEmpty) return 'Vui lòng sử dụng phương thức khác để nhập thông tin thẻ.';

    final alternativesText = alternatives.joinWithLast(separator: ', ', lastSeparator: ', hoặc ');
    return 'Thẻ này chưa được hỗ trợ thanh toán thông qua $current. Vui lòng $alternativesText để thanh toán.';
  }

  @override
  String get velocityLimitExceeded => 'Quá nhiều giao dịch được tạo cho thẻ này trong thời gian ngắn. Vui lòng thử lại sau 5 phút.';
  @override
  String get tokenInvalidOrExpired => 'Mã thanh toán không hợp lệ hoặc đã hết hạn. Vui lòng quét lại.';
  @override
  String get verificationCodeRequired => 'Cần mã xác thực để hoàn tất giao dịch này.';
  @override
  String get verificationCodeInvalid => 'Mã xác thực không đúng. Vui lòng thử lại.';
  @override
  String get verificationExpired => 'Phiên xác thực đã hết hạn. Vui lòng thử lại.';
  @override
  String get cardLockedTooManyAttempts => 'Thẻ tạm thời bị khóa do nhập sai mã PIN nhiều lần. Vui lòng thử lại sau vài phút.';
  @override
  String get chipCryptogramInvalid => 'Không thể xác thực thẻ để thanh toán bằng NFC. Vui lòng sử dụng phương thức thanh toán khác để tiếp tục.';
  @override
  String get chipNonceReplayed => 'Lượt chạm thẻ này đã được dùng cho một giao dịch trước đó. Vui lòng chạm thẻ lại.';
  @override
  String get chipCounterReplay =>
      'Vui lòng sử dụng phương thức thanh toán khác (quét mã QR, điền số thẻ) để thanh toán. Để kích hoạt lại tính năng thanh toán bằng NFC cho thẻ, vui lòng liên hệ bộ phận hỗ trợ.';
  @override
  String get chipCredentialRevoked => 'Thẻ này đã bị vô hiệu hóa và không thể thanh toán. Vui lòng đề nghị chủ thẻ liên hệ đơn vị phát hành.';
  @override
  String get chipCredentialNotActive => 'Thẻ này chưa hoàn tất thiết lập nên không thể thanh toán. Vui lòng dùng thẻ khác hoặc liên hệ bộ phận hỗ trợ.';

  @override
  String get servicePaymentAuthFailed => 'Không thể xác thực giao dịch với tài khoản doanh nghiệp. Vui lòng liên hệ bộ phận hỗ trợ để xử lý.';
  @override
  String get servicePaymentInvalidRequest => 'Tài khoản doanh nghiệp không thể xử lý yêu cầu thanh toán này. Vui lòng liên hệ bộ phận hỗ trợ để xử lý.';
  @override
  String get servicePaymentDuplicateOrder => 'Đơn hàng này đã được ghi nhận thanh toán trước đó. Vui lòng liên hệ quản trị viên doanh nghiệp để xử lý.';
  @override
  String get servicePaymentUserInvalid => 'Tài khoản chủ thẻ không hợp lệ cho giao dịch này. Vui lòng liên hệ quản trị viên doanh nghiệp để xử lý.';
  @override
  String get servicePaymentInFlight => 'Một giao dịch cho đơn hàng này đang được xử lý. Vui lòng kiểm tra danh sách giao dịch trước khi thử lại.';
  @override
  String get servicePaymentFailed => 'Tài khoản doanh nghiệp không thể hoàn tất giao dịch này. Vui lòng thử lại sau.';
  @override
  String get servicePaymentInsufficientFunds => 'Tài khoản doanh nghiệp không đủ số dư cho giao dịch này. Vui lòng liên hệ quản trị viên doanh nghiệp để xử lý.';
  @override
  String get servicePaymentDeclined => 'Tài khoản doanh nghiệp đã từ chối giao dịch này. Vui lòng liên hệ quản trị viên doanh nghiệp để xử lý.';
  @override
  String get servicePaymentUnavailable => 'Dịch vụ tài khoản doanh nghiệp tạm thời gián đoạn. Vui lòng thử lại sau vài phút.';

  @override
  String generic(String? errorCode) => 'Thanh toán không thành công. Vui lòng thử lại hoặc dùng thẻ khác.${errorCode != null ? '\nMã lỗi: $errorCode' : ''}';
}

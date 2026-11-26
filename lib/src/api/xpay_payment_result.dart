final class XPayPaymentResult {
  const XPayPaymentResult({
    this.failureCategory,
    required this.status,
    this.createdAt,
    this.authId,
    this.bookingRef,
    this.captureId,
    this.currency,
    this.declineCode,
    this.errorCode,
    this.externalRef,
    this.message,
    this.amount,
  });

  final XPayFailureCategory? failureCategory;
  final XPayPaymentStatus status;
  final DateTime? createdAt;
  final String? authId;
  final String? bookingRef;
  final String? captureId;
  final String? currency;
  final String? declineCode;
  final String? errorCode;
  final String? externalRef;
  final String? message;
  final int? amount;

  bool get isSuccessful => status == XPayPaymentStatus.approved || status == XPayPaymentStatus.captured;

  @override
  String toString() =>
      'XPayPaymentResult(status: ${status.name}, failureCategory: ${failureCategory?.name}, authId: $authId, captureId: $captureId, externalRef: $externalRef, amount: $amount, currency: $currency, createdAt: $createdAt, '
      'bookingRef: $bookingRef, declineCode: $declineCode, errorCode: $errorCode, message: $message)';
}

abstract final class XPayErrorCode {
  static const String busy = 'sdk_busy';
  static const String notInitialized = 'sdk_not_initialized';
  static const String invalidRequest = 'sdk_invalid_request';
  static const String unexpectedResponse = 'sdk_unexpected_response';
}

enum XPayPaymentStatus {
  approved,
  captured,
  declined,
  cancelled,
  duplicate,
  failed,
  expired,
  unsupported,
}

enum XPayFailureCategory {
  system,
  network,
  cardholderRetry,
  cardholderChange,
  corporatePolicy,
  session,
  unknown,
}

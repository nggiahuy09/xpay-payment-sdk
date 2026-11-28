import '../base/define/constant/constant.dart';

final class XPayPaymentResult {
  const XPayPaymentResult({
    this.failure,
    this.paidBy,
    this.rideStatus,
    required this.status,
    this.createdAt,
    this.authId,
    this.captureId,
    this.currency,
    this.errorCode,
    this.externalRef,
    this.pendingAuthId,
    this.amount,
  });

  final XPayPaymentFailure? failure;
  final XPayPaidBy? paidBy;
  final XPayRideStatus? rideStatus;
  final XPayPaymentStatus status;
  final DateTime? createdAt;
  final String? authId;
  final String? captureId;
  final String? currency;
  final String? errorCode;
  final String? externalRef;
  final String? pendingAuthId;
  final int? amount;

  bool get isRetryable => status.isRetryable;

  bool get isSuccessful => status == XPayPaymentStatus.paid;

  @override
  String toString() =>
      'XPayPaymentResult(status: ${status.name}, isRetryable: $isRetryable, failure: $failure, paidBy: ${paidBy?.name}, rideStatus: ${rideStatus?.name}, authId: $authId, '
      'pendingAuthId: $pendingAuthId, captureId: $captureId, externalRef: $externalRef, amount: $amount, currency: $currency, createdAt: $createdAt, errorCode: $errorCode)';
}

final class XPayPaymentFailure {
  const XPayPaymentFailure({required this.reason, this.authId, this.errorCode, this.note});

  final XPayFailureReason reason;
  final String? authId;
  final String? errorCode;
  final String? note;

  @override
  String toString() => 'XPayPaymentFailure(reason: ${reason.name}, authId: $authId, errorCode: $errorCode, note: $note)';
}

abstract final class XPayErrorCode {
  static const String busy = 'sdk_busy';
  static const String notInitialized = 'sdk_not_initialized';
  static const String invalidRequest = 'sdk_invalid_request';
  static const String sessionAmountChanged = XPErrorCodes.sessionAmountChanged;
  static const String unexpectedResponse = 'sdk_unexpected_response';
  static const String unsupported = 'sdk_unsupported';
}

enum XPayPaymentStatus {
  paid,
  retryInPartner,
  otherMethod,
  csPending,
  rideClosed,
  cancelled,
  unavailable;

  bool get isRetryable => switch (this) {
    XPayPaymentStatus.paid => false,
    XPayPaymentStatus.retryInPartner => true,
    XPayPaymentStatus.otherMethod => false,
    XPayPaymentStatus.csPending => false,
    XPayPaymentStatus.rideClosed => false,
    XPayPaymentStatus.cancelled => true,
    XPayPaymentStatus.unavailable => false,
  };
}

enum XPayFailureReason {
  paymentDeclined,
  sdkError,
  other;

  String toRemote() => switch (this) {
    XPayFailureReason.paymentDeclined => 'payment_declined',
    XPayFailureReason.sdkError => 'sdk_error',
    XPayFailureReason.other => 'other',
  };
}

enum XPayPaidBy { partner, cs }

enum XPayRideStatus { completed, cancelled }

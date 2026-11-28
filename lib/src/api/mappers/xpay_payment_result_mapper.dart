import '../../core/domain/entities/payment_checkout_result_entity.dart';
import '../../core/domain/entities/payment_failure_entity.dart';
import '../../core/domain/entities/ride_payment_status_entity.dart';
import '../xpay_payment_result.dart';

extension PaymentCheckoutResultEntityMapper on PaymentCheckoutResultEntity {
  XPayPaymentResult toResult() => switch (this) {
    PaymentCheckoutPaidResultEntity(:final payment) => XPayPaymentResult(
      paidBy: payment.paidBy._toPaidBy(),
      status: XPayPaymentStatus.paid,
      createdAt: payment.createdAt,
      authId: payment.authId,
      captureId: payment.captureId,
      currency: payment.currency,
      externalRef: payment.externalRef,
      amount: payment.amount._toAmount(),
    ),
    PaymentCheckoutRetryInPartnerResultEntity(:final failure) => XPayPaymentResult(failure: failure._toFailure(), status: XPayPaymentStatus.retryInPartner),
    PaymentCheckoutOtherMethodResultEntity(:final failure) => XPayPaymentResult(
      failure: failure._toFailure(),
      status: XPayPaymentStatus.otherMethod,
      pendingAuthId: failure.pendingAuthId,
    ),
    PaymentCheckoutHotlinePendingResultEntity(:final failure) => XPayPaymentResult(
      failure: XPayPaymentFailure(reason: XPayFailureReason.paymentDeclined, authId: failure.authId, errorCode: failure.errorCode, note: _kHotlineTimeoutNote),
      status: XPayPaymentStatus.csPending,
      pendingAuthId: failure.pendingAuthId,
    ),
    PaymentCheckoutRideClosedResultEntity(:final settlement) => XPayPaymentResult(rideStatus: settlement._toRideStatus(), status: XPayPaymentStatus.rideClosed),
    PaymentCheckoutCancelledResultEntity(:final pendingAuthId) => XPayPaymentResult(status: XPayPaymentStatus.cancelled, pendingAuthId: pendingAuthId),
    PaymentCheckoutUnavailableResultEntity(:final errorCode) => XPayPaymentResult(
      failure: XPayPaymentFailure(reason: XPayFailureReason.sdkError, errorCode: errorCode, note: errorCode),
      status: XPayPaymentStatus.unavailable,
      errorCode: errorCode,
    ),
  };
}

const String _kFareChangedNote = 'cước đổi';
const String _kHotlineTimeoutNote = 'chờ tổng đài quá 5 phút';

extension on PaymentFailureEntity {
  XPayPaymentFailure _toFailure() => switch (reason) {
    PaymentFailureReason.paymentDeclined => XPayPaymentFailure(reason: XPayFailureReason.paymentDeclined, authId: authId, errorCode: errorCode),
    PaymentFailureReason.sdkError => XPayPaymentFailure(reason: XPayFailureReason.sdkError, authId: authId, errorCode: errorCode, note: errorCode ?? kind.name),
    PaymentFailureReason.fareChanged => XPayPaymentFailure(reason: XPayFailureReason.other, authId: authId, errorCode: errorCode, note: _kFareChangedNote),
  };
}

extension on RidePaymentPayer {
  XPayPaidBy? _toPaidBy() => switch (this) {
    RidePaymentPayer.partner => XPayPaidBy.partner,
    RidePaymentPayer.cs => XPayPaidBy.cs,
    RidePaymentPayer.unknown => null,
  };
}

extension on RideSettlement {
  XPayRideStatus? _toRideStatus() => switch (this) {
    RideSettlement.closedWithoutPayment => XPayRideStatus.completed,
    RideSettlement.cancelled => XPayRideStatus.cancelled,
    RideSettlement.open || RideSettlement.paid => null,
  };
}

extension on String? {
  int? _toAmount() => num.tryParse(this ?? '')?.toInt();
}

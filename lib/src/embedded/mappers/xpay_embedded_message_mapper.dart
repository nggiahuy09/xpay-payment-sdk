import '../../api/xpay_config.dart';
import '../../api/xpay_log_event.dart';
import '../../api/xpay_payment_request.dart';
import '../../api/xpay_payment_result.dart';
import '../xpay_embedded_api.g.dart';

extension XPayEmbeddedLanguageMapper on XPayEmbeddedLanguage {
  XPayLanguage toLanguage() => switch (this) {
    XPayEmbeddedLanguage.en => XPayLanguage.en,
    XPayEmbeddedLanguage.vi => XPayLanguage.vi,
  };
}

extension XPayEmbeddedRequestMessageMapper on XPayEmbeddedRequestMessage {
  XPayPaymentRequest toRequest(XPayEmbeddedHostApi hostApi) => XPayPaymentRequest.fromSession(sessionJson, canFetchSession ? hostApi.fetchSession : null);
}

extension XPayPaymentResultMessageMapper on XPayPaymentResult {
  XPayEmbeddedResultMessage toMessage() => XPayEmbeddedResultMessage(
    failure: failure?._toMessage(),
    paidBy: paidBy?._toMessage(),
    rideStatus: rideStatus?._toMessage(),
    status: status._toMessage(),
    authId: authId,
    captureId: captureId,
    currency: currency,
    errorCode: errorCode,
    externalRef: externalRef,
    pendingAuthId: pendingAuthId,
    amount: amount,
    createdAtEpochMillis: createdAt?.millisecondsSinceEpoch,
  );
}

extension XPayLogEventMessageMapper on XPayLogEvent {
  XPayEmbeddedLogMessage toMessage() => XPayEmbeddedLogMessage(
    input: input,
    category: category._toMessage(),
    level: level._toMessage(),
    action: action,
    errorCode: errorCode,
    feature: feature,
    reason: reason,
    serverMessage: serverMessage,
  );
}

extension on XPayPaymentFailure {
  XPayEmbeddedFailureMessage _toMessage() => XPayEmbeddedFailureMessage(reason: reason._toMessage(), authId: authId, errorCode: errorCode, note: note);
}

extension on XPayFailureReason {
  XPayEmbeddedFailureReason _toMessage() => switch (this) {
    XPayFailureReason.paymentDeclined => XPayEmbeddedFailureReason.paymentDeclined,
    XPayFailureReason.sdkError => XPayEmbeddedFailureReason.sdkError,
    XPayFailureReason.other => XPayEmbeddedFailureReason.other,
  };
}

extension on XPayPaidBy {
  XPayEmbeddedPaidBy _toMessage() => switch (this) {
    XPayPaidBy.partner => XPayEmbeddedPaidBy.partner,
    XPayPaidBy.cs => XPayEmbeddedPaidBy.cs,
  };
}

extension on XPayRideStatus {
  XPayEmbeddedRideStatus _toMessage() => switch (this) {
    XPayRideStatus.completed => XPayEmbeddedRideStatus.completed,
    XPayRideStatus.cancelled => XPayEmbeddedRideStatus.cancelled,
  };
}

extension on XPayPaymentStatus {
  XPayEmbeddedPaymentStatus _toMessage() => switch (this) {
    XPayPaymentStatus.paid => XPayEmbeddedPaymentStatus.paid,
    XPayPaymentStatus.retryInPartner => XPayEmbeddedPaymentStatus.retryInPartner,
    XPayPaymentStatus.otherMethod => XPayEmbeddedPaymentStatus.otherMethod,
    XPayPaymentStatus.csPending => XPayEmbeddedPaymentStatus.csPending,
    XPayPaymentStatus.rideClosed => XPayEmbeddedPaymentStatus.rideClosed,
    XPayPaymentStatus.cancelled => XPayEmbeddedPaymentStatus.cancelled,
    XPayPaymentStatus.unavailable => XPayEmbeddedPaymentStatus.unavailable,
  };
}

extension on XPayLogCategory {
  XPayEmbeddedLogCategory _toMessage() => switch (this) {
    XPayLogCategory.api => XPayEmbeddedLogCategory.api,
    XPayLogCategory.behavior => XPayEmbeddedLogCategory.behavior,
    XPayLogCategory.error => XPayEmbeddedLogCategory.error,
  };
}

extension on XPayLogLevel {
  XPayEmbeddedLogLevel _toMessage() => switch (this) {
    XPayLogLevel.info => XPayEmbeddedLogLevel.info,
    XPayLogLevel.warn => XPayEmbeddedLogLevel.warn,
    XPayLogLevel.error => XPayEmbeddedLogLevel.error,
  };
}

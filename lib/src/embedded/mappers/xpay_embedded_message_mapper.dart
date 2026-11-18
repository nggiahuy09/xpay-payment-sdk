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
  XPayPaymentRequest toRequest() => XPayPaymentRequest.fromSession(sessionJson);
}

extension XPayPaymentResultMessageMapper on XPayPaymentResult {
  XPayEmbeddedResultMessage toMessage() => XPayEmbeddedResultMessage(
    status: status._toMessage(),
    authId: authId,
    bookingRef: bookingRef,
    captureId: captureId,
    currency: currency,
    declineCode: declineCode,
    errorCode: errorCode,
    externalRef: externalRef,
    message: message,
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

extension on XPayPaymentStatus {
  XPayEmbeddedPaymentStatus _toMessage() => switch (this) {
    XPayPaymentStatus.approved => XPayEmbeddedPaymentStatus.approved,
    XPayPaymentStatus.captured => XPayEmbeddedPaymentStatus.captured,
    XPayPaymentStatus.declined => XPayEmbeddedPaymentStatus.declined,
    XPayPaymentStatus.cancelled => XPayEmbeddedPaymentStatus.cancelled,
    XPayPaymentStatus.duplicate => XPayEmbeddedPaymentStatus.duplicate,
    XPayPaymentStatus.failed => XPayEmbeddedPaymentStatus.failed,
    XPayPaymentStatus.expired => XPayEmbeddedPaymentStatus.expired,
    XPayPaymentStatus.unsupported => XPayEmbeddedPaymentStatus.unsupported,
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

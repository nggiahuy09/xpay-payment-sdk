import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/embedded/xpay_embedded_api.g.dart',
    dartPackageName: 'xpay_payment_sdk',
    kotlinOut: 'android/src/main/kotlin/com/xperise/xpay/payment/XPayEmbeddedApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.xperise.xpay.payment', errorClassName: 'XPayEmbeddedError'),
  ),
)
class XPayEmbeddedConfigMessage {
  XPayEmbeddedConfigMessage({required this.language, required this.baseUrl});

  XPayEmbeddedLanguage language;
  String baseUrl;
}

class XPayEmbeddedRequestMessage {
  XPayEmbeddedRequestMessage({required this.sessionJson});

  String sessionJson;
}

class XPayEmbeddedResultMessage {
  XPayEmbeddedResultMessage({
    required this.status,
    this.authId,
    this.bookingRef,
    this.captureId,
    this.currency,
    this.declineCode,
    this.errorCode,
    this.externalRef,
    this.message,
    this.amount,
    this.createdAtEpochMillis,
  });

  XPayEmbeddedPaymentStatus status;
  String? authId;
  String? bookingRef;
  String? captureId;
  String? currency;
  String? declineCode;
  String? errorCode;
  String? externalRef;
  String? message;
  int? amount;
  int? createdAtEpochMillis;
}

class XPayEmbeddedLogMessage {
  XPayEmbeddedLogMessage({
    required this.input,
    required this.category,
    required this.level,
    required this.action,
    this.errorCode,
    required this.feature,
    this.reason,
    this.serverMessage,
  });

  Map<String, Object?> input;
  XPayEmbeddedLogCategory category;
  XPayEmbeddedLogLevel level;
  String action;
  String? errorCode;
  String feature;
  String? reason;
  String? serverMessage;
}

@FlutterApi()
abstract class XPayEmbeddedFlutterApi {
  @asyncCallback
  void initialize(XPayEmbeddedConfigMessage config);

  @asyncCallback
  XPayEmbeddedResultMessage start(XPayEmbeddedRequestMessage request);

  @asyncCallback
  void cancel();
}

@HostApi()
abstract class XPayEmbeddedHostApi {
  void onLog(XPayEmbeddedLogMessage event);
}

enum XPayEmbeddedLanguage { en, vi }

enum XPayEmbeddedLogCategory { api, behavior, error }

enum XPayEmbeddedLogLevel { info, warn, error }

enum XPayEmbeddedPaymentStatus { approved, captured, declined, cancelled, duplicate, failed, expired, unsupported }

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/embedded/xpay_embedded_api.g.dart',
    dartPackageName: 'xpay_payment_sdk',
    kotlinOut: 'android/src/main/kotlin/com/xperise/xpay/payment/XPayEmbeddedApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.xperise.xpay.payment', errorClassName: 'XPayEmbeddedError'),
    swiftOut: 'ios/xpay_payment_sdk/Sources/xpay_payment_sdk/XPayEmbeddedApi.g.swift',
    swiftOptions: SwiftOptions(errorClassName: 'XPayEmbeddedError'),
  ),
)
class XPayEmbeddedConfigMessage {
  XPayEmbeddedConfigMessage({required this.language, required this.baseUrl});

  XPayEmbeddedLanguage language;
  String baseUrl;
}

class XPayEmbeddedRequestMessage {
  XPayEmbeddedRequestMessage({required this.sessionJson, required this.canFetchSession});

  String sessionJson;
  bool canFetchSession;
}

class XPayEmbeddedFailureMessage {
  XPayEmbeddedFailureMessage({required this.reason, this.authId, this.errorCode, this.note});

  XPayEmbeddedFailureReason reason;
  String? authId;
  String? errorCode;
  String? note;
}

class XPayEmbeddedResultMessage {
  XPayEmbeddedResultMessage({
    this.failure,
    this.paidBy,
    this.rideStatus,
    required this.status,
    this.authId,
    this.captureId,
    this.currency,
    this.errorCode,
    this.externalRef,
    this.pendingAuthId,
    this.amount,
    this.createdAtEpochMillis,
  });

  XPayEmbeddedFailureMessage? failure;
  XPayEmbeddedPaidBy? paidBy;
  XPayEmbeddedRideStatus? rideStatus;
  XPayEmbeddedPaymentStatus status;
  String? authId;
  String? captureId;
  String? currency;
  String? errorCode;
  String? externalRef;
  String? pendingAuthId;
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

  @asyncCallback
  String fetchSession();
}

enum XPayEmbeddedFailureReason { paymentDeclined, sdkError, other }

enum XPayEmbeddedLanguage { en, vi }

enum XPayEmbeddedLogCategory { api, behavior, error }

enum XPayEmbeddedLogLevel { info, warn, error }

enum XPayEmbeddedPaidBy { partner, cs }

enum XPayEmbeddedPaymentStatus { paid, retryInPartner, otherMethod, csPending, rideClosed, cancelled, unavailable }

enum XPayEmbeddedRideStatus { completed, cancelled }

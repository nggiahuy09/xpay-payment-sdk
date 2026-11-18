import '../../api/xpay_log_event.dart';
import '../../base/define/logging/logger.dart';
import '../../base/domain/exceptions/xp_exception.dart';

final class XPBusinessLogger {
  const XPBusinessLogger(this._onLog);

  final void Function(XPayLogEvent event)? _onLog;

  void logBusiness({
    required Map<String, dynamic> input,
    XPayLogCategory category = XPayLogCategory.api,
    XPayLogLevel level = XPayLogLevel.error,
    XPException? exception,
    required String action,
    required String feature,
    String? reason,
  }) {
    final onLog = _onLog;
    if (onLog == null) return;

    try {
      onLog.call(
        XPayLogEvent(
          input: Map.unmodifiable(input),
          category: category,
          level: level,
          action: action,
          errorCode: exception?.errorCode,
          feature: feature,
          reason: reason,
          serverMessage: exception?.serverMessage,
        ),
      );
    } catch (e) {
      XPLogger.warning('onLog callback failed: $e', name: 'XPBusinessLogger');
    }
  }
}

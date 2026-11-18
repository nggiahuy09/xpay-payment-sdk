final class XPayLogEvent {
  const XPayLogEvent({
    this.input = const {},
    required this.category,
    required this.level,
    required this.action,
    this.errorCode,
    required this.feature,
    this.reason,
    this.serverMessage,
  });

  final Map<String, Object?> input;
  final XPayLogCategory category;
  final XPayLogLevel level;
  final String action;
  final String? errorCode;
  final String feature;
  final String? reason;
  final String? serverMessage;

  @override
  String toString() =>
      'XPayLogEvent(level: ${level.name}, category: ${category.name}, feature: $feature, action: $action, reason: $reason, errorCode: $errorCode, serverMessage: $serverMessage, input: $input)';
}

enum XPayLogCategory { api, behavior, error }

enum XPayLogLevel { info, warn, error }

import 'xpay_log_event.dart';

final class XPayConfig {
  const XPayConfig({required this.environment, this.language = XPayLanguage.vi, this.onLog});

  final XPayEnvironment environment;
  final XPayLanguage language;
  final void Function(XPayLogEvent event)? onLog;
}

final class XPayEnvironment {
  const XPayEnvironment({required this.baseUrl});

  final String baseUrl;
}

enum XPayLanguage { en, vi }

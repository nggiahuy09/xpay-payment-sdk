import 'dart:developer' as dev;

import 'package:intl/intl.dart';

abstract class XPLogger {
  static const _kIsReleaseMode = bool.fromEnvironment('dart.vm.product');

  static void setLog(XPLoggerMixin logMixin) {
    XPLoggerMixin.setLog(logMixin);
  }

  static Future<void> info(Object? message, {String? name, bool printPath = true}) async {
    if (_kIsReleaseMode) return;
    XPLoggerMixin._logger.info(message.toString(), name: name, printPath: printPath).catchError((e, s) {
      XPLoggerMixin._logger.error(error: e, stackTrace: s, name: 'LogCenter');
      XPLoggerMixin._logger.info('message: $message,\nname: $name');
    });
  }

  static Future<void> warning(Object? message, {String? name, bool printPath = true}) async {
    if (_kIsReleaseMode) return;
    XPLoggerMixin._logger.warning(message.toString(), name: name, printPath: printPath).catchError((e, s) {
      XPLoggerMixin._logger.error(error: e, stackTrace: s, name: 'LogCenter');
      XPLoggerMixin._logger.info('message: $message,\nname: $name');
    });
  }

  static Future<void> error({dynamic error, StackTrace? stackTrace, String? name, String? message, bool printPath = true}) async {
    if (_kIsReleaseMode) return;
    XPLoggerMixin._logger.error(error: error, stackTrace: stackTrace, name: name, message: message, printPath: printPath).catchError((e, s) {
      XPLoggerMixin._logger.error(error: e, stackTrace: s, name: 'LogCenter');
      XPLoggerMixin._logger.info('error: $error,\nstackTrace: $stackTrace,\nname: $name');
    });
  }

  static Future<void> route({required String routeName, dynamic argument, String? name, bool printPath = true}) async {
    if (_kIsReleaseMode) return;
    XPLoggerMixin._logger.route(routeName: routeName, argument: argument, name: name, printPath: printPath).catchError((e, s) {
      XPLoggerMixin._logger.error(error: e, stackTrace: s, name: 'LogCenter');
      XPLoggerMixin._logger.info('routeName: $routeName,\nargument: $argument,\nname: $name');
    });
  }
}

/*class _XPLoggerDefault with XPLoggerMixin {
  @override
  Future<void> info(String message, {String? name, bool printPath = true}) async {
    dev.log(message, name: name ?? 'INFO');
  }

  @override
  Future<void> warning(String message, {String? name, bool printPath = true}) async {
    dev.log(message, name: name ?? 'WARNING');
  }

  @override
  Future<void> error({error, StackTrace? stackTrace, String? name, String? message, bool printPath = true}) async {
    dev.log(message ?? '', name: name ?? 'ERROR', error: error, stackTrace: stackTrace);
  }

  @override
  Future<void> route({required String routeName, argument, String? name, bool printPath = true}) async {
    dev.log('routeName: $routeName,\nargument: $argument', name: name ?? 'ROUTE');
  }

  @override
  List<XPInterceptor> get interceptors => [];
}*/

class _XPLoggerDetailed with XPLoggerMixin {
  static const int _kMobileStackTraceIndex = 3;
  static const String _defaultColorString = '\x1B[36m';

  @override
  Future<void> info(String message, {String? name, bool printPath = true}) async {
    dev.log(_generateMessage(message, _XPLogLevel.info, printPath), name: name ?? _XPLogLevel.info.name);
  }

  @override
  Future<void> warning(String message, {String? name, bool printPath = true}) async {
    dev.log(_generateMessage(message, _XPLogLevel.warning, printPath), name: name ?? _XPLogLevel.warning.name);
  }

  @override
  Future<void> route({required String routeName, argument, String? name, bool printPath = true}) async {
    dev.log(_generateMessage('routeName: $routeName, argument: $argument', _XPLogLevel.route, printPath), name: name ?? _XPLogLevel.route.name);
  }

  @override
  Future<void> error({error, StackTrace? stackTrace, String? name, String? message, bool printPath = true}) async {
    dev.log(_generateMessage(message ?? '', _XPLogLevel.error, printPath), name: name ?? _XPLogLevel.error.name, error: error, stackTrace: stackTrace);
  }

  String _generateMessage(String message, _XPLogLevel level, bool printPath) {
    final String formattedMessage;

    final stackTraceString = StackTrace.current.toString().split("\n")[_kMobileStackTraceIndex];
    final regex = RegExp(r'\((package:[^:]+(?:/[^:]+)+\.dart):\d+:\d+\)');

    String filePath = ' ';
    if (printPath) {
      filePath = regex.allMatches(stackTraceString).firstOrNull?.group(0)?.trim() ?? '';
      filePath = filePath.startsWith('(') ? filePath.substring(1) : filePath;
      filePath = filePath.endsWith(')') ? filePath.substring(0, filePath.length - 1) : filePath;
      filePath = '<$filePath> ';
    }

    final String printColor;
    switch (level) {
      case _XPLogLevel.debug:
        printColor = '\x1B[38;5;244m'; // Gray
        break;
      case _XPLogLevel.info:
      case _XPLogLevel.route:
        printColor = _defaultColorString; // Cyan
        break;
      case _XPLogLevel.success:
        printColor = '\x1B[32m'; // Green
        break;
      case _XPLogLevel.warning:
        printColor = '\x1B[33m'; // Yellow
        break;
      case _XPLogLevel.error:
        printColor = '\x1B[31m'; // Red
        break;
      case _XPLogLevel.critical:
        printColor = '\x1B[38;5;9m'; // Bright Red (changed from background)
        break;
      case _XPLogLevel.verbose:
        printColor = '\x1B[35m'; // Magenta
        break;
      case _XPLogLevel.trace:
        printColor = '\x1B[38;5;242m'; // Light gray
        break;
      case _XPLogLevel.network:
        printColor = '\x1B[38;5;39m'; // Blue
        break;
      case _XPLogLevel.database:
        printColor = '\x1B[38;5;208m'; // Orange
        break;
      case _XPLogLevel.ui:
        printColor = '\x1B[38;5;135m'; // Purple
        break;
      case _XPLogLevel.security:
        printColor = '\x1B[38;5;196m'; // Bright red
        break;
    }

    formattedMessage = '$printColor ${_currentTimeText()}$filePath$message';
    return formattedMessage;
  }

  String _currentTimeText({bool printDate = true}) {
    final DateTime now = DateTime.now();
    return '[${DateFormat(printDate ? 'yyyy-MM-dd HH:mm:ss' : 'HH:mm:ss').format(now)}:${now.millisecond.toString().padLeft(3, '0')}]';
  }
}

mixin XPLoggerMixin {
  static XPLoggerMixin _logger = _XPLoggerDetailed();

  static void setLog(XPLoggerMixin logger) => _logger = logger;

  Future<void> info(String message, {String? name, bool printPath = true});

  Future<void> warning(String message, {String? name, bool printPath = true});

  Future<void> error({dynamic error, StackTrace? stackTrace, String? name, String? message, bool printPath = true});

  Future<void> route({required String routeName, dynamic argument, String? name, bool printPath = true});
}

enum _XPLogLevel {
  debug, // For detailed debugging information
  info, // General information
  route, // Info about routing
  success, // Successful operations
  warning, // Warnings
  error, // Errors
  critical, // Critical errors
  verbose, // Very detailed information
  trace, // For tracing code execution
  network, // Network-related logs
  database, // Database operations
  ui, // UI-related events
  security, // Security-related events
}

import 'package:dio/dio.dart';

import '../../define/logging/logger.dart';

final class XPRateLimitInterceptor extends InterceptorsWrapper {
  XPRateLimitInterceptor(this._dio);

  /// Max delay seconds to retry after rate limited. Won't exceed this number to avoid stalling.
  static const int _kMaxRetryDelaySeconds = 3;

  static const String _kRetryAfterHeader = 'retry-after';

  /// Used to mark request made by this interceptor when retrying, avoid infinite loops.
  static const String _kIsRateLimitRetry = '_xp_is_rate_limit_retry';

  final Dio _dio;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 429 || _isRetry(err.requestOptions)) return handler.next(err);

    final delaySeconds = _parseResetHeader(err.response);
    if (delaySeconds == null) {
      XPLogger.warning('Rate limit retry duration not found, skipping retry', name: 'XPRateLimitInterceptor');
      return handler.reject(err);
    }

    if (delaySeconds > _kMaxRetryDelaySeconds) {
      XPLogger.warning('Rate limit reset ($delaySeconds s) exceeds max retry delay, skipping retry', name: 'XPRateLimitInterceptor');
      return handler.reject(err);
    }

    XPLogger.info('Rate limited, retrying in $delaySeconds s', name: 'XPRateLimitInterceptor');
    await Future<void>.delayed(Duration(seconds: delaySeconds));

    try {
      final retryOptions = err.requestOptions..extra[_kIsRateLimitRetry] = true;
      final response = await _dio.fetch<Object?>(retryOptions);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.reject(retryError);
    } catch (_) {
      return handler.reject(err);
    }
  }

  int? _parseResetHeader(Response<dynamic>? response) {
    final value = response?.headers.value(_kRetryAfterHeader);
    return value == null ? null : int.tryParse(value);
  }

  bool _isRetry(RequestOptions options) => options.extra[_kIsRateLimitRetry] == true;
}

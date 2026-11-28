import 'package:dio/dio.dart';

import '../../define/logging/logger.dart';

final class XPRateLimitInterceptor extends InterceptorsWrapper {
  XPRateLimitInterceptor(this._dio);

  /// Max delay seconds to retry after rate limited. Won't exceed this number to avoid stalling.
  static const int _kMaxRetryDelaySeconds = 3;

  static const int _kMaxRetries = 3;

  static const Duration _kBaseBackoff = Duration(seconds: 1);

  static const String _kRetryAfterHeader = 'retry-after';

  /// Used to mark request made by this interceptor when retrying, avoid infinite loops.
  static const String _kRateLimitRetryCount = '_xp_rate_limit_retry_count';

  final Dio _dio;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final retryCount = options.extra[_kRateLimitRetryCount] as int? ?? 0;
    if (err.response?.statusCode != 429 || retryCount >= _kMaxRetries) return handler.next(err);

    final delaySeconds = _parseResetHeader(err.response);
    if (delaySeconds != null && delaySeconds > _kMaxRetryDelaySeconds) {
      XPLogger.warning('Rate limit reset ($delaySeconds s) exceeds max retry delay, skipping retry', name: 'XPRateLimitInterceptor');
      return handler.reject(err);
    }

    final delay = delaySeconds == null ? _kBaseBackoff * (1 << retryCount) : Duration(seconds: delaySeconds);
    XPLogger.info('Rate limited, retry ${retryCount + 1}/$_kMaxRetries in ${delay.inMilliseconds} ms', name: 'XPRateLimitInterceptor');
    await Future<void>.delayed(delay);

    try {
      final response = await _dio.fetch<Object?>(options..extra[_kRateLimitRetryCount] = retryCount + 1);
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
}

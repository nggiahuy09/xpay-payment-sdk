import 'package:dio/dio.dart';

import '../../define/constant/constant.dart';
import '../../define/logging/logger.dart';
import '../../extensions/response_extension.dart';

/// Replays a request that failed for a passing reason (timeout, lost connection, 5xx, `request_in_flight`) up to [_kMaxRetries] times, only when a replay cannot charge twice:
/// a `GET`, or a request that carries its `Idempotency-Key`.
final class XPTransientRetryInterceptor extends InterceptorsWrapper {
  XPTransientRetryInterceptor(this._dio);

  static const int _kMaxRetries = 3;

  static const Duration _kBaseBackoff = Duration(seconds: 1);
  static const Duration _kInFlightDelay = Duration(milliseconds: 500);

  static const String _kGetMethod = 'GET';
  static const String _kRequestInFlightCode = 'request_in_flight';

  /// How many replays this request has had, so the count survives each replay going back through the interceptors.
  static const String _kRetryCount = '_xp_transient_retry_count';

  final Dio _dio;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final retryCount = options.extra[_kRetryCount] as int? ?? 0;
    final delay = _getDelay(err, retryCount);
    if (delay == null || retryCount >= _kMaxRetries || _isReplayable(options) == false || options.extra[XPHttpHeaderKeys.kSkipTransientRetryExtra] == true) {
      return handler.next(err);
    }

    XPLogger.info('Transient failure, path=${options.path}, retry ${retryCount + 1}/$_kMaxRetries in ${delay.inMilliseconds} ms', name: 'XPTransientRetryInterceptor');
    await Future<void>.delayed(delay);
    try {
      return handler.resolve(await _dio.fetch<Object?>(options..extra[_kRetryCount] = retryCount + 1));
    } on DioException catch (retryError) {
      return handler.reject(retryError);
    }
  }

  Duration? _getDelay(DioException err, int retryCount) {
    final backoff = _kBaseBackoff * (1 << retryCount);
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return backoff;
      case DioExceptionType.badResponse:
        final response = err.response;
        final statusCode = response?.statusCode ?? 0;
        if (statusCode == 409 && response?.errorCode == _kRequestInFlightCode) return _kInFlightDelay;
        return statusCode >= 500 ? backoff : null;
      case DioExceptionType.transformTimeout:
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return null;
    }
  }

  bool _isReplayable(RequestOptions options) => options.method.toUpperCase() == _kGetMethod || options.headers.containsKey(XPHttpHeaderKeys.kIdempotencyKeyHeader);
}

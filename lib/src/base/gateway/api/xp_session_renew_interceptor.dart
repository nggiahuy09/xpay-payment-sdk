import 'package:dio/dio.dart';

import '../../define/constant/constant.dart';
import '../../define/logging/logger.dart';
import '../../domain/domain.dart';
import '../../extensions/response_extension.dart';
import 'api_type.dart';
import 'xp_token_provider.dart';

/// Renews an expired ride payment session through [XPTokenProvider.renewSessionToken], then replays the request once with the new token, keeping its body and `Idempotency-Key`.
final class XPSessionRenewInterceptor extends InterceptorsWrapper {
  XPSessionRenewInterceptor(this._dio, this._tokenProvider);

  static const String _kSessionExpiredCode = 'ride_payment_session_expired';

  /// Marks the replay so a second expiry ends the request instead of looping.
  static const String _kIsSessionRenewRetry = '_xp_is_session_renew_retry';

  final Dio _dio;
  final XPTokenProvider _tokenProvider;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    if (_isSessionExpired(err.response) == false || options.extra[XPHttpHeaderKeys.kApiTypeExtra] != APIType.user || options.extra[_kIsSessionRenewRetry] == true) {
      return handler.next(err);
    }

    final renewal = await _tokenProvider.renewSessionToken();
    final sessionToken = renewal == XPSessionRenewal.renewed ? await _tokenProvider.getSessionToken() : null;
    if (renewal == XPSessionRenewal.amountChanged) {
      XPLogger.warning('Ride payment session renewed with another amount, path=${options.path}', name: 'XPSessionRenewInterceptor');
      return handler.reject(
        DioException(
          requestOptions: options,
          response: err.response,
          type: DioExceptionType.unknown,
          error: XPApiException(errorCode: XPErrorCodes.sessionAmountChanged, statusCode: err.response?.statusCode),
        ),
      );
    }
    if (sessionToken == null) {
      XPLogger.warning('Ride payment session expired and could not be renewed, path=${options.path}', name: 'XPSessionRenewInterceptor');
      return handler.next(err);
    }

    XPLogger.info('Ride payment session renewed, replaying path=${options.path}', name: 'XPSessionRenewInterceptor');
    try {
      final retryOptions = options
        ..extra[_kIsSessionRenewRetry] = true
        ..headers[XPHttpHeaderKeys.kRidePaymentHeader] = sessionToken;
      return handler.resolve(await _dio.fetch<Object?>(retryOptions));
    } on DioException catch (retryError) {
      return handler.reject(retryError);
    }
  }

  bool _isSessionExpired(Response<dynamic>? response) => response?.statusCode == 401 && response?.errorCode == _kSessionExpiredCode;
}

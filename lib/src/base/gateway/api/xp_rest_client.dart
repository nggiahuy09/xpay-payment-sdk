import 'package:dio/dio.dart';

import '../../define/constant/constant.dart';
import '../../define/logging/logger.dart';
import '../../domain/domain.dart';
import '../../extensions/response_extension.dart';
import 'api_type.dart';
import 'xp_http_method.dart';
import 'xp_rate_limit_interceptor.dart';
import 'xp_resource.dart';
import 'xp_session_renew_interceptor.dart';
import 'xp_token_provider.dart';
import 'xp_transient_retry_interceptor.dart';

/// Shared Dio wrapper. All remote calls go through [request]; every Dio failure is mapped into the `XPException` hierarchy before it leaves this layer.
base class XPRestClient {
  XPRestClient({
    List<Interceptor> extraInterceptors = const [],
    required XPTokenProvider tokenProvider,
    required Duration connectTimeout,
    required Duration receiveTimeout,
    required String baseUrl,
  }) : this._(Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: connectTimeout, receiveTimeout: receiveTimeout)), tokenProvider, extraInterceptors);

  XPRestClient._(this._dio, this._tokenProvider, List<Interceptor> extraInterceptors) {
    _dio.interceptors.addAll([XPRateLimitInterceptor(_dio), XPSessionRenewInterceptor(_dio, _tokenProvider), XPTransientRetryInterceptor(_dio), ...extraInterceptors]);
  }

  final Dio _dio;
  final XPTokenProvider _tokenProvider;

  Future<T> request<T>(XPResource<T> resource, {required APIType type, Object Function(Map<String, dynamic> details)? onErrorDetails}) async {
    XPLogger.info('Execute API: path=${resource.path}, method=${resource.method.toDioMethod()}, ${resource.description}', name: 'XPRestClient');
    final timeout = resource.timeout;
    final cancelToken = timeout == null ? null : CancelToken();
    try {
      final request = _dio.request<Object?>(
        resource.path,
        data: resource.body,
        queryParameters: resource.queryParameters,
        cancelToken: cancelToken,
        options: Options(
          extra: {XPHttpHeaderKeys.kApiTypeExtra: type, if (resource.retriesTransientFailures == false) XPHttpHeaderKeys.kSkipTransientRetryExtra: true},
          headers: await _createHeaders(type, resource.headers),
          method: resource.method.toDioMethod(),
        ),
      );
      final response = await (timeout == null ? request : request.timeout(timeout, onTimeout: () => _onTimeout(cancelToken)));
      return resource.parse(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e, onErrorDetails: onErrorDetails);
    } on XPException catch (_) {
      rethrow;
    } catch (e) {
      throw XPUnknownException(error: e);
    }
  }

  Never _onTimeout(CancelToken? cancelToken) {
    cancelToken?.cancel();
    throw const XPNetworkException.timeout();
  }

  Future<Map<String, dynamic>> _createHeaders(APIType type, Map<String, dynamic>? extra) async {
    final headers = <String, dynamic>{...?extra};
    switch (type) {
      case APIType.public:
        break;
      case APIType.user:
        final sessionToken = await _tokenProvider.getSessionToken();
        if (sessionToken != null) headers[XPHttpHeaderKeys.kRidePaymentHeader] = sessionToken;
        break;
    }
    return headers;
  }

  XPException _mapDioException(DioException e, {Object Function(Map<String, dynamic> details)? onErrorDetails}) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return XPNetworkException.timeout(error: e);
      case DioExceptionType.connectionError:
        return XPNetworkException.noConnection(error: e);
      case DioExceptionType.cancel:
        return XPNetworkException(error: e);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return e.error is XPException ? e.error as XPException : XPNetworkException.noHost(error: e);
      case DioExceptionType.badResponse:
        final response = e.response;
        final statusCode = response?.statusCode;
        final errorDetails = response?.errorDetails;
        final details = errorDetails != null ? onErrorDetails?.call(errorDetails) : null;

        if (statusCode == 409) return XPConflictException(details: details, error: e, errorCode: response?.errorCode, serverMessage: response?.errorMessage);

        return XPApiException(details: details, error: e, errorCode: response?.errorCode, serverMessage: response?.errorMessage, statusCode: statusCode, data: response?.mapData);
    }
  }
}

extension on XPHttpMethod {
  String toDioMethod() => switch (this) {
    XPHttpMethod.get => 'GET',
    XPHttpMethod.post => 'POST',
    XPHttpMethod.put => 'PUT',
    XPHttpMethod.patch => 'PATCH',
    XPHttpMethod.delete => 'DELETE',
  };
}

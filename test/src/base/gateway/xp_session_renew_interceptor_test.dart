import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/src/base/define/constant/constant.dart';
import 'package:xpay_payment_sdk/src/base/domain/domain.dart';
import 'package:xpay_payment_sdk/src/base/gateway/api/api.dart';
import 'package:xpay_payment_sdk/src/core/data/datasources/remote/resource/ride_payment_status_resource.dart';

const Map<String, dynamic> _openRide = {'order_id': '3f6c1b2a-8d4e-4f71-9a0b-5c2e7d9f1a34', 'external_ref': 'XP-1048', 'ride_status': 'riding', 'payment': null};

final class _TokenProvider implements XPTokenProvider {
  _TokenProvider(this._renewal);

  final XPSessionRenewal _renewal;

  int renewCalls = 0;
  String token = 'rps_old';

  @override
  Future<String?> getSessionToken() async => token;

  @override
  Future<XPSessionRenewal> renewSessionToken() async {
    renewCalls++;
    if (_renewal == XPSessionRenewal.renewed) token = 'rps_new';
    return _renewal;
  }
}

final class _FakeServer extends Interceptor {
  final List<String?> tokens = [];

  int busyReplies = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = options.headers[XPHttpHeaderKeys.kRidePaymentHeader] as String?;
    tokens.add(token);
    if (token == 'rps_busy' && tokens.where((t) => t == 'rps_busy').length <= busyReplies) {
      final response = Response<Object?>(
        requestOptions: options,
        statusCode: 429,
        data: {'code': 'rate_limited'},
        headers: Headers.fromMap({
          'retry-after': ['0'],
        }),
      );
      return handler.reject(DioException(requestOptions: options, response: response, type: DioExceptionType.badResponse), true);
    }
    if (token == 'rps_down') {
      final response = Response<Object?>(requestOptions: options, statusCode: 503, data: {'code': 'internal_error'});
      return handler.reject(DioException(requestOptions: options, response: response, type: DioExceptionType.badResponse), true);
    }
    if (token == 'rps_old') {
      final response = Response<Object?>(requestOptions: options, statusCode: 401, data: {'code': 'ride_payment_session_expired', 'message': 'expired'});
      return handler.reject(DioException(requestOptions: options, response: response, type: DioExceptionType.badResponse), true);
    }

    handler.resolve(Response<Object?>(requestOptions: options, statusCode: 200, data: _openRide));
  }
}

(XPRestClient, _FakeServer) _client(_TokenProvider tokenProvider) {
  final server = _FakeServer();
  final client = XPRestClient(
    extraInterceptors: [server],
    tokenProvider: tokenProvider,
    connectTimeout: const Duration(seconds: 1),
    receiveTimeout: const Duration(seconds: 1),
    baseUrl: 'https://xpay.test',
  );
  return (client, server);
}

void main() {
  test('an expired session is renewed once and the request replayed with the new token', () async {
    final tokenProvider = _TokenProvider(XPSessionRenewal.renewed);
    final (client, server) = _client(tokenProvider);

    final model = await client.request(RidePaymentStatusResource(), type: APIType.user);

    expect(model.externalRef, 'XP-1048');
    expect(tokenProvider.renewCalls, 1);
    expect(server.tokens, ['rps_old', 'rps_new']);
  });

  test('a renewed session with another amount fails as a changed amount without replaying', () async {
    final tokenProvider = _TokenProvider(XPSessionRenewal.amountChanged);
    final (client, server) = _client(tokenProvider);

    await expectLater(
      client.request(RidePaymentStatusResource(), type: APIType.user),
      throwsA(isA<XPApiException>().having((e) => e.errorCode, 'errorCode', XPErrorCodes.sessionAmountChanged).having((e) => e.isSessionRejected, 'isSessionRejected', isTrue)),
    );
    expect(server.tokens, ['rps_old']);
  });

  test('a session that cannot be renewed keeps the expiry the server sent', () async {
    final tokenProvider = _TokenProvider(XPSessionRenewal.failed);
    final (client, server) = _client(tokenProvider);

    await expectLater(
      client.request(RidePaymentStatusResource(), type: APIType.user),
      throwsA(isA<XPApiException>().having((e) => e.errorCode, 'errorCode', 'ride_payment_session_expired').having((e) => e.statusCode, 'statusCode', 401)),
    );
    expect(server.tokens, ['rps_old']);
  });

  test('the ride status is not replayed after a 5xx, so a down server never holds the screen', () async {
    final tokenProvider = _TokenProvider(XPSessionRenewal.failed)..token = 'rps_down';
    final (client, server) = _client(tokenProvider);

    await expectLater(client.request(RidePaymentStatusResource(), type: APIType.user), throwsA(isA<XPApiException>().having((e) => e.statusCode, 'statusCode', 503)));
    expect(server.tokens, ['rps_down']);
  });

  test('a rate-limited request is replayed up to three times before the ride answers', () async {
    final tokenProvider = _TokenProvider(XPSessionRenewal.failed)..token = 'rps_busy';
    final (client, server) = _client(tokenProvider);
    server.busyReplies = 3;

    final model = await client.request(RidePaymentStatusResource(), type: APIType.user);

    expect(model.externalRef, 'XP-1048');
    expect(server.tokens, hasLength(4));
  });

  test('a request still rate-limited after three replays fails as rate limited', () async {
    final tokenProvider = _TokenProvider(XPSessionRenewal.failed)..token = 'rps_busy';
    final (client, server) = _client(tokenProvider);
    server.busyReplies = 10;

    await expectLater(client.request(RidePaymentStatusResource(), type: APIType.user), throwsA(isA<XPApiException>().having((e) => e.errorCode, 'errorCode', 'rate_limited')));
    expect(server.tokens, hasLength(4));
  });
}

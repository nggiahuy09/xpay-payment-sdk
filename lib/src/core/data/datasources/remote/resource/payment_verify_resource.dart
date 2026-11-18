import '../../../../../base/define/constant/constant.dart';
import '../../../../../base/gateway/api/api.dart';
import '../models/payment_verify_request_model.dart';
import '../models/payment_verify_response_model.dart';

final class PaymentVerifyResource extends XPResource<PaymentVerifyResponseModel> {
  PaymentVerifyResource({required String authId, required PaymentVerifyRequestModel request, required String idempotencyKey})
    : _authId = authId,
      _request = request,
      _idempotencyKey = idempotencyKey,
      super(description: 'Verify merchant payment, authId=$authId');

  final String _authId;
  final PaymentVerifyRequestModel _request;
  final String _idempotencyKey;

  @override
  Object? get body => _request.toJson();

  @override
  Map<String, dynamic>? get headers => {XPHttpHeaderKeys.kIdempotencyKeyHeader: _idempotencyKey};

  @override
  XPHttpMethod get method => XPHttpMethod.post;

  @override
  String get path => '/merchant/payments/$_authId/verify';

  @override
  PaymentVerifyResponseModel parse(Object? data) => PaymentVerifyResponseModel.fromJson(data as Map<String, dynamic>);
}

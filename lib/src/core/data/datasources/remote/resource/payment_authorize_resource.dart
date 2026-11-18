import '../../../../../base/define/constant/constant.dart';
import '../../../../../base/gateway/api/api.dart';
import '../models/payment_authorize_request_model.dart';
import '../models/payment_authorize_response_model.dart';

final class PaymentAuthorizeResource extends XPResource<PaymentAuthorizeResponseModel> {
  PaymentAuthorizeResource({required PaymentAuthorizeRequestModel request, required String idempotencyKey})
    : _request = request,
      _idempotencyKey = idempotencyKey,
      super(description: 'Authorize merchant payment, externalRef=${request.externalRef}, entryMode=${request.entryMode}');

  final PaymentAuthorizeRequestModel _request;
  final String _idempotencyKey;

  @override
  Object? get body => _request.toJson();

  @override
  Map<String, dynamic>? get headers => {XPHttpHeaderKeys.kIdempotencyKeyHeader: _idempotencyKey};

  @override
  XPHttpMethod get method => XPHttpMethod.post;

  @override
  String get path => '/merchant/payments/authorize';

  @override
  PaymentAuthorizeResponseModel parse(Object? data) => PaymentAuthorizeResponseModel.fromJson(data as Map<String, dynamic>);
}

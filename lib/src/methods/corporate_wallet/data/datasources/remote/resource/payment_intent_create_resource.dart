import '../../../../../../base/define/constant/constant.dart';
import '../../../../../../base/gateway/api/api.dart';
import '../models/payment_intent_create_request_model.dart';
import '../models/payment_intent_response_model.dart';

final class PaymentIntentCreateResource extends XPResource<PaymentIntentResponseModel> {
  PaymentIntentCreateResource({required PaymentIntentCreateRequestModel request, required String idempotencyKey})
    : _request = request,
      _idempotencyKey = idempotencyKey,
      super(description: 'Create merchant payment intent, externalRef=${request.externalRef}, amount=${request.amount}');

  final PaymentIntentCreateRequestModel _request;
  final String _idempotencyKey;

  @override
  Object? get body => _request.toJson();

  @override
  Map<String, dynamic>? get headers => {XPHttpHeaderKeys.kIdempotencyKeyHeader: _idempotencyKey};

  @override
  XPHttpMethod get method => XPHttpMethod.post;

  @override
  String get path => '/merchant/payment-intents';

  @override
  PaymentIntentResponseModel parse(Object? data) => PaymentIntentResponseModel.fromJson(data as Map<String, dynamic>);
}

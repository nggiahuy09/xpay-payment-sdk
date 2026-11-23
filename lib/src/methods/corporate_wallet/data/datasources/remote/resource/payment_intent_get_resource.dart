import '../../../../../../base/gateway/api/api.dart';
import '../models/payment_intent_response_model.dart';

final class PaymentIntentGetResource extends XPResource<PaymentIntentResponseModel> {
  PaymentIntentGetResource(String intentId) : _intentId = intentId, super(description: 'Get merchant payment intent, intentId=$intentId');

  final String _intentId;

  @override
  XPHttpMethod get method => XPHttpMethod.get;

  @override
  String get path => '/merchant/payment-intents/$_intentId';

  @override
  PaymentIntentResponseModel parse(Object? data) => PaymentIntentResponseModel.fromJson(data as Map<String, dynamic>);
}

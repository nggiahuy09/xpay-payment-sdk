import '../../../../../../base/gateway/api/api.dart';
import '../models/payment_intent_response_model.dart';

final class PaymentIntentCancelResource extends XPResource<PaymentIntentResponseModel> {
  PaymentIntentCancelResource(String intentId) : _intentId = intentId, super(description: 'Cancel merchant payment intent, intentId=$intentId');

  final String _intentId;

  @override
  XPHttpMethod get method => XPHttpMethod.post;

  @override
  String get path => '/merchant/payment-intents/$_intentId/cancel';

  @override
  PaymentIntentResponseModel parse(Object? data) => PaymentIntentResponseModel.fromJson(data as Map<String, dynamic>);
}

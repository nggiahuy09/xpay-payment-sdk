import '../../../../../base/gateway/api/api.dart';
import '../models/merchant_payment_response_model.dart';

final class MerchantPaymentResource extends XPResource<MerchantPaymentResponseModel> {
  MerchantPaymentResource(this._authId) : super(description: 'Get merchant payment, authId=$_authId');

  final String _authId;

  @override
  XPHttpMethod get method => XPHttpMethod.get;

  @override
  String get path => '/merchant/payments/$_authId';

  @override
  MerchantPaymentResponseModel parse(Object? data) => MerchantPaymentResponseModel.fromJson(data as Map<String, dynamic>);
}

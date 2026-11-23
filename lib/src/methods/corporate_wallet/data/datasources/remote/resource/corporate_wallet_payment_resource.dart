import '../../../../../../base/gateway/api/api.dart';
import '../models/corporate_wallet_payment_models.dart';
import '../models/corporate_wallet_payment_request_model.dart';

final class CorporateWalletPaymentResource extends XPResource<CorporateWalletChallengeModel> {
  CorporateWalletPaymentResource(CorporateWalletPaymentRequestModel request)
    : _request = request,
      super(description: 'Request corporate wallet payment OTP, method=${request.method}, recipientId=${request.recipientId}');

  final CorporateWalletPaymentRequestModel _request;

  @override
  Object? get body => _request.toJson();

  @override
  XPHttpMethod get method => XPHttpMethod.post;

  @override
  String get path => '/merchant/wallet-payments';

  @override
  CorporateWalletChallengeModel parse(Object? data) => CorporateWalletChallengeModel.fromJson(data as Map<String, dynamic>);
}

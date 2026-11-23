import '../../../../../../base/gateway/api/api.dart';
import '../models/corporate_wallet_payment_models.dart';
import '../models/corporate_wallet_verify_request_model.dart';

final class CorporateWalletVerifyResource extends XPResource<CorporateWalletPaymentResponseModel> {
  CorporateWalletVerifyResource(String walletPaymentId, CorporateWalletVerifyRequestModel request)
    : _walletPaymentId = walletPaymentId,
      _request = request,
      super(description: 'Verify corporate wallet payment OTP, walletPaymentId=$walletPaymentId');

  final String _walletPaymentId;
  final CorporateWalletVerifyRequestModel _request;

  @override
  Object? get body => _request.toJson();

  @override
  XPHttpMethod get method => XPHttpMethod.post;

  @override
  String get path => '/merchant/wallet-payments/$_walletPaymentId/verify';

  @override
  CorporateWalletPaymentResponseModel parse(Object? data) => CorporateWalletPaymentResponseModel.fromJson(data as Map<String, dynamic>);
}

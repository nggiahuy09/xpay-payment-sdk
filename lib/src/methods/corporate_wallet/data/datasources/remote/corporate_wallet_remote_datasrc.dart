import '../../../../../base/gateway/api/api.dart';
import '../../../../../di/di.dart';
import 'models/corporate_wallet_payment_models.dart';
import 'models/corporate_wallet_payment_request_model.dart';
import 'models/corporate_wallet_recipient_model.dart';
import 'models/corporate_wallet_verify_request_model.dart';
import 'models/payment_intent_create_request_model.dart';
import 'models/payment_intent_response_model.dart';
import 'resource/corporate_wallet_payment_resource.dart';
import 'resource/corporate_wallet_recipients_resource.dart';
import 'resource/corporate_wallet_verify_resource.dart';
import 'resource/payment_intent_cancel_resource.dart';
import 'resource/payment_intent_create_resource.dart';
import 'resource/payment_intent_get_resource.dart';

final class CorporateWalletRemoteDatasource {
  final _client = getIt.get<XPRestClient>();

  Future<List<CorporateWalletRecipientModel>> getRecipients() => _client.request(const CorporateWalletRecipientsResource(), type: APIType.user);

  Future<CorporateWalletChallengeModel> requestPayment(CorporateWalletPaymentRequestModel request) => _client.request(CorporateWalletPaymentResource(request), type: APIType.user);

  Future<CorporateWalletPaymentResponseModel> verify(String walletPaymentId, CorporateWalletVerifyRequestModel request) =>
      _client.request(CorporateWalletVerifyResource(walletPaymentId, request), type: APIType.user, onErrorDetails: CorporateWalletOtpErrorDetailsModel.fromJson);

  Future<PaymentIntentResponseModel> createIntent({required PaymentIntentCreateRequestModel request, required String idempotencyKey}) => _client.request(
    PaymentIntentCreateResource(request: request, idempotencyKey: idempotencyKey),
    type: APIType.user,
  );

  Future<PaymentIntentResponseModel> getIntent(String intentId) => _client.request(PaymentIntentGetResource(intentId), type: APIType.user);

  Future<PaymentIntentResponseModel> cancelIntent(String intentId) => _client.request(PaymentIntentCancelResource(intentId), type: APIType.user);
}

import '../../../../base/gateway/api/api_type.dart';
import '../../../../base/gateway/api/xp_rest_client.dart';
import '../../../../di/di.dart';
import 'models/merchant_payment_response_model.dart';
import 'models/payment_authorize_request_model.dart';
import 'models/payment_authorize_response_model.dart';
import 'models/payment_resend_verification_request_model.dart';
import 'models/payment_verify_request_model.dart';
import 'models/payment_verify_response_model.dart';
import 'resource/merchant_payment_resource.dart';
import 'resource/payment_authorize_resource.dart';
import 'resource/payment_resend_verification_resource.dart';
import 'resource/payment_verify_resource.dart';

final class PaymentAuthorizeRemoteDatasource {
  final _client = getIt.get<XPRestClient>();

  Future<PaymentAuthorizeResponseModel> authorize({required PaymentAuthorizeRequestModel request, required String idempotencyKey}) {
    final resource = PaymentAuthorizeResource(request: request, idempotencyKey: idempotencyKey);
    return _client.request(resource, type: APIType.user);
  }

  Future<PaymentVerifyResponseModel> verify({required String authId, required PaymentVerifyRequestModel request, required String idempotencyKey}) {
    final resource = PaymentVerifyResource(authId: authId, request: request, idempotencyKey: idempotencyKey);
    return _client.request(resource, type: APIType.user);
  }

  Future<PaymentVerifyResponseModel> resendVerification(String authId, PaymentResendVerificationRequestModel request) {
    return _client.request(PaymentResendVerificationResource(authId, request), type: APIType.user);
  }

  Future<MerchantPaymentResponseModel> getPayment(String authId) => _client.request(MerchantPaymentResource(authId), type: APIType.user);
}

import '../../../../../base/gateway/api/api.dart';
import '../models/payment_resend_verification_request_model.dart';
import '../models/payment_verify_response_model.dart';

/// Issues a fresh SMS OTP for a sale still awaiting verification, invalidating the previous code immediately.
///
/// Carries no idempotency key, unlike verify: replaying a resend must not replay the *original* send, because the point of the call is to put a new code in the
/// customer's hands. The server's cooldown and per-sale cap are what bound repeat calls instead.
final class PaymentResendVerificationResource extends XPResource<PaymentVerifyResponseModel> {
  PaymentResendVerificationResource(String authId, PaymentResendVerificationRequestModel request)
    : _authId = authId,
      _request = request,
      super(description: 'Resend merchant payment verification code, authId=$authId, recipientId=${request.recipientId}');

  final String _authId;
  final PaymentResendVerificationRequestModel _request;

  @override
  Object? get body => _request.toJson();

  @override
  XPHttpMethod get method => XPHttpMethod.post;

  @override
  String get path => '/merchant/payments/$_authId/resend-verification';

  @override
  PaymentVerifyResponseModel parse(Object? data) => PaymentVerifyResponseModel.fromJson(data as Map<String, dynamic>);
}

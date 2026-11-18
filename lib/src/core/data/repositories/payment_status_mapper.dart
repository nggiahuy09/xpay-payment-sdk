import '../../domain/entities/payment_authorize_entity.dart';

PaymentAuthorizeStatus paymentStatusFromRemote(String? value) => switch (value) {
  'pending_verification' => PaymentAuthorizeStatus.pendingVerification,
  'approved' => PaymentAuthorizeStatus.approved,
  'declined' => PaymentAuthorizeStatus.declined,
  'captured' => PaymentAuthorizeStatus.captured,
  'partially_captured' => PaymentAuthorizeStatus.partiallyCaptured,
  'voided' => PaymentAuthorizeStatus.voided,
  'expired' => PaymentAuthorizeStatus.expired,
  _ => PaymentAuthorizeStatus.unknown,
};

/// Maps a domain [PaymentAuthorizeStatus] to its remote wire value, or `null` for [PaymentAuthorizeStatus.unknown] (not a filterable server value).
String? paymentStatusToRemote(PaymentAuthorizeStatus status) => switch (status) {
  PaymentAuthorizeStatus.pendingVerification => 'pending_verification',
  PaymentAuthorizeStatus.approved => 'approved',
  PaymentAuthorizeStatus.declined => 'declined',
  PaymentAuthorizeStatus.captured => 'captured',
  PaymentAuthorizeStatus.partiallyCaptured => 'partially_captured',
  PaymentAuthorizeStatus.voided => 'voided',
  PaymentAuthorizeStatus.expired => 'expired',
  PaymentAuthorizeStatus.unknown => null,
};

PaymentAuthorizeVerificationMethod paymentVerificationMethodFromRemote(String? value) => switch (value) {
  'sms_otp' => PaymentAuthorizeVerificationMethod.smsOtp,
  'static_code' => PaymentAuthorizeVerificationMethod.staticCode,
  'token_pin' => PaymentAuthorizeVerificationMethod.tokenPin,
  _ => PaymentAuthorizeVerificationMethod.unknown,
};

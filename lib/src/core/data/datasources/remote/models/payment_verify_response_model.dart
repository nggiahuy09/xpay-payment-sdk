import 'package:json_annotation/json_annotation.dart';

import 'payment_verification_recipient_model.dart';

part 'payment_verify_response_model.g.dart';

/// Response model for `POST /merchant/payments/{auth_id}/verify` and `POST /merchant/payments/{auth_id}/resend-verification`.
///
/// Both endpoints return the same authorization envelope, so one model covers them; resend simply always carries a `verification` block, since a fresh code was just issued.
@JsonSerializable(createToJson: false)
final class PaymentVerifyResponseModel {
  const PaymentVerifyResponseModel({
    this.verification,
    this.attribution,
    this.authId,
    this.status,
    this.captureId,
    this.declineReason,
    this.cardId,
    this.corporateId,
    this.bookingRef,
    this.externalRef,
    this.policyCheck,
    this.amount,
    this.currency,
    this.holdExpiresAt,
    this.createdAt,
  });

  factory PaymentVerifyResponseModel.fromJson(Map<String, dynamic> json) => _$PaymentVerifyResponseModelFromJson(json);

  final PaymentVerifyVerificationRemoteModel? verification;
  final PaymentVerifyAttributionRemoteModel? attribution;
  @JsonKey(name: 'auth_id')
  final String? authId;
  final String? status;
  @JsonKey(name: 'capture_id')
  final String? captureId;
  @JsonKey(name: 'decline_reason')
  final String? declineReason;
  @JsonKey(name: 'card_id')
  final String? cardId;
  @JsonKey(name: 'corporate_id')
  final String? corporateId;
  @JsonKey(name: 'booking_ref')
  final String? bookingRef;
  @JsonKey(name: 'external_ref')
  final String? externalRef;
  @JsonKey(name: 'policy_check')
  final String? policyCheck;
  final String? amount;
  final String? currency;
  @JsonKey(name: 'hold_expires_at')
  final String? holdExpiresAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
}

@JsonSerializable(createToJson: false)
final class PaymentVerifyVerificationRemoteModel {
  const PaymentVerifyVerificationRemoteModel({
    this.recipients,
    this.method,
    this.expiresAt,
    this.verificationDeadline,
    this.canResendAt,
    this.attemptsRemaining,
    this.resendsRemaining,
    this.phoneMasked,
    this.recipientRequired,
  });

  factory PaymentVerifyVerificationRemoteModel.fromJson(Map<String, dynamic> json) => _$PaymentVerifyVerificationRemoteModelFromJson(json);

  final List<PaymentVerificationRecipientModel>? recipients;
  final String? method;
  @JsonKey(name: 'expires_at')
  final String? expiresAt;
  @JsonKey(name: 'verification_deadline')
  final String? verificationDeadline;
  @JsonKey(name: 'can_resend_at')
  final String? canResendAt;
  @JsonKey(name: 'attempts_remaining')
  final int? attemptsRemaining;
  @JsonKey(name: 'resends_remaining')
  final int? resendsRemaining;
  @JsonKey(name: 'phone_masked')
  final String? phoneMasked;
  @JsonKey(name: 'recipient_required')
  final bool? recipientRequired;
}

@JsonSerializable(createToJson: false)
final class PaymentVerifyAttributionRemoteModel {
  const PaymentVerifyAttributionRemoteModel({this.userId, this.corporateId, this.costCenterId, this.department, this.tripId, this.tripMatch});

  factory PaymentVerifyAttributionRemoteModel.fromJson(Map<String, dynamic> json) => _$PaymentVerifyAttributionRemoteModelFromJson(json);

  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'corporate_id')
  final String? corporateId;
  @JsonKey(name: 'cost_center_id')
  final String? costCenterId;
  final String? department;
  @JsonKey(name: 'trip_id')
  final String? tripId;
  @JsonKey(name: 'trip_match')
  final String? tripMatch;
}

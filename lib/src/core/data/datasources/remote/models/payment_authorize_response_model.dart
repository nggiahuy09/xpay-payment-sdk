import 'package:json_annotation/json_annotation.dart';

import 'payment_verification_recipient_model.dart';

part 'payment_authorize_response_model.g.dart';

/// Response model for `POST /merchant/payments/authorize`.
@JsonSerializable(createToJson: false)
final class PaymentAuthorizeResponseModel {
  const PaymentAuthorizeResponseModel({
    this.authId,
    this.status,
    this.captureId,
    this.declineReason,
    this.amount,
    this.currency,
    this.externalRef,
    this.holdExpiresAt,
    this.createdAt,
    this.verification,
  });

  factory PaymentAuthorizeResponseModel.fromJson(Map<String, dynamic> json) => _$PaymentAuthorizeResponseModelFromJson(json);

  final PaymentAuthorizeVerificationRemoteModel? verification;
  @JsonKey(name: 'auth_id')
  final String? authId;
  final String? status;
  @JsonKey(name: 'capture_id')
  final String? captureId;
  @JsonKey(name: 'decline_reason')
  final String? declineReason;
  final String? amount;
  final String? currency;
  @JsonKey(name: 'external_ref')
  final String? externalRef;
  @JsonKey(name: 'hold_expires_at')
  final String? holdExpiresAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
}

@JsonSerializable(createToJson: false)
final class PaymentAuthorizeVerificationRemoteModel {
  const PaymentAuthorizeVerificationRemoteModel({
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

  factory PaymentAuthorizeVerificationRemoteModel.fromJson(Map<String, dynamic> json) => _$PaymentAuthorizeVerificationRemoteModelFromJson(json);

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

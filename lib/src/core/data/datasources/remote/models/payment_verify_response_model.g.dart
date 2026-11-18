// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_verify_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentVerifyResponseModel _$PaymentVerifyResponseModelFromJson(
  Map<String, dynamic> json,
) => PaymentVerifyResponseModel(
  verification: json['verification'] == null
      ? null
      : PaymentVerifyVerificationRemoteModel.fromJson(
          json['verification'] as Map<String, dynamic>,
        ),
  attribution: json['attribution'] == null
      ? null
      : PaymentVerifyAttributionRemoteModel.fromJson(
          json['attribution'] as Map<String, dynamic>,
        ),
  authId: json['auth_id'] as String?,
  status: json['status'] as String?,
  captureId: json['capture_id'] as String?,
  declineReason: json['decline_reason'] as String?,
  cardId: json['card_id'] as String?,
  corporateId: json['corporate_id'] as String?,
  bookingRef: json['booking_ref'] as String?,
  externalRef: json['external_ref'] as String?,
  policyCheck: json['policy_check'] as String?,
  amount: json['amount'] as String?,
  currency: json['currency'] as String?,
  holdExpiresAt: json['hold_expires_at'] as String?,
  createdAt: json['created_at'] as String?,
);

PaymentVerifyVerificationRemoteModel
_$PaymentVerifyVerificationRemoteModelFromJson(Map<String, dynamic> json) =>
    PaymentVerifyVerificationRemoteModel(
      recipients: (json['recipients'] as List<dynamic>?)
          ?.map(
            (e) => PaymentVerificationRecipientModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      method: json['method'] as String?,
      expiresAt: json['expires_at'] as String?,
      verificationDeadline: json['verification_deadline'] as String?,
      canResendAt: json['can_resend_at'] as String?,
      attemptsRemaining: (json['attempts_remaining'] as num?)?.toInt(),
      resendsRemaining: (json['resends_remaining'] as num?)?.toInt(),
      phoneMasked: json['phone_masked'] as String?,
      recipientRequired: json['recipient_required'] as bool?,
    );

PaymentVerifyAttributionRemoteModel
_$PaymentVerifyAttributionRemoteModelFromJson(Map<String, dynamic> json) =>
    PaymentVerifyAttributionRemoteModel(
      userId: json['user_id'] as String?,
      corporateId: json['corporate_id'] as String?,
      costCenterId: json['cost_center_id'] as String?,
      department: json['department'] as String?,
      tripId: json['trip_id'] as String?,
      tripMatch: json['trip_match'] as String?,
    );

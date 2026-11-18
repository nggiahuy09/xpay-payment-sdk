// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_authorize_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentAuthorizeResponseModel _$PaymentAuthorizeResponseModelFromJson(
  Map<String, dynamic> json,
) => PaymentAuthorizeResponseModel(
  authId: json['auth_id'] as String?,
  status: json['status'] as String?,
  captureId: json['capture_id'] as String?,
  declineReason: json['decline_reason'] as String?,
  amount: json['amount'] as String?,
  currency: json['currency'] as String?,
  externalRef: json['external_ref'] as String?,
  holdExpiresAt: json['hold_expires_at'] as String?,
  createdAt: json['created_at'] as String?,
  verification: json['verification'] == null
      ? null
      : PaymentAuthorizeVerificationRemoteModel.fromJson(
          json['verification'] as Map<String, dynamic>,
        ),
);

PaymentAuthorizeVerificationRemoteModel
_$PaymentAuthorizeVerificationRemoteModelFromJson(Map<String, dynamic> json) =>
    PaymentAuthorizeVerificationRemoteModel(
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

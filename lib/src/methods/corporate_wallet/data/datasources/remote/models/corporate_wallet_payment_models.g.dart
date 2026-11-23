// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corporate_wallet_payment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CorporateWalletChallengeModel _$CorporateWalletChallengeModelFromJson(
  Map<String, dynamic> json,
) => CorporateWalletChallengeModel(
  verification: json['verification'] == null
      ? null
      : CorporateWalletVerificationModel.fromJson(
          json['verification'] as Map<String, dynamic>,
        ),
  walletPaymentId: json['wallet_payment_id'] as String?,
);

CorporateWalletVerificationModel _$CorporateWalletVerificationModelFromJson(
  Map<String, dynamic> json,
) => CorporateWalletVerificationModel(
  destinationMasked: json['destination_masked'] as String?,
  expiresAt: json['expires_at'] as String?,
  method: json['method'] as String?,
  recipientId: json['recipient_id'] as String?,
  attemptsRemaining: (json['attempts_remaining'] as num?)?.toInt(),
);

CorporateWalletPaymentResponseModel
_$CorporateWalletPaymentResponseModelFromJson(Map<String, dynamic> json) =>
    CorporateWalletPaymentResponseModel(
      amount: json['amount'] as String?,
      currency: json['currency'] as String?,
      externalRef: json['external_ref'] as String?,
      status: json['status'] as String?,
      walletPaymentId: json['wallet_payment_id'] as String?,
    );

CorporateWalletOtpErrorDetailsModel
_$CorporateWalletOtpErrorDetailsModelFromJson(Map<String, dynamic> json) =>
    CorporateWalletOtpErrorDetailsModel(
      attemptsRemaining: (json['attempts_remaining'] as num?)?.toInt(),
    );

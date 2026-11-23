import 'package:json_annotation/json_annotation.dart';

part 'corporate_wallet_payment_models.g.dart';

@JsonSerializable(createToJson: false)
final class CorporateWalletChallengeModel {
  const CorporateWalletChallengeModel({this.verification, this.walletPaymentId});

  factory CorporateWalletChallengeModel.fromJson(Map<String, dynamic> json) => _$CorporateWalletChallengeModelFromJson(json);

  final CorporateWalletVerificationModel? verification;
  @JsonKey(name: 'wallet_payment_id')
  final String? walletPaymentId;
}

@JsonSerializable(createToJson: false)
final class CorporateWalletVerificationModel {
  const CorporateWalletVerificationModel({this.destinationMasked, this.expiresAt, this.method, this.recipientId, this.attemptsRemaining});

  factory CorporateWalletVerificationModel.fromJson(Map<String, dynamic> json) => _$CorporateWalletVerificationModelFromJson(json);

  @JsonKey(name: 'destination_masked')
  final String? destinationMasked;
  @JsonKey(name: 'expires_at')
  final String? expiresAt;
  final String? method;
  @JsonKey(name: 'recipient_id')
  final String? recipientId;
  @JsonKey(name: 'attempts_remaining')
  final int? attemptsRemaining;
}

@JsonSerializable(createToJson: false)
final class CorporateWalletPaymentResponseModel {
  const CorporateWalletPaymentResponseModel({this.amount, this.currency, this.externalRef, this.status, this.walletPaymentId});

  factory CorporateWalletPaymentResponseModel.fromJson(Map<String, dynamic> json) => _$CorporateWalletPaymentResponseModelFromJson(json);

  final String? amount;
  final String? currency;
  @JsonKey(name: 'external_ref')
  final String? externalRef;
  final String? status;
  @JsonKey(name: 'wallet_payment_id')
  final String? walletPaymentId;
}

@JsonSerializable(createToJson: false)
final class CorporateWalletOtpErrorDetailsModel {
  const CorporateWalletOtpErrorDetailsModel({this.attemptsRemaining});

  factory CorporateWalletOtpErrorDetailsModel.fromJson(Map<String, dynamic> json) => _$CorporateWalletOtpErrorDetailsModelFromJson(json);

  @JsonKey(name: 'attempts_remaining')
  final int? attemptsRemaining;
}

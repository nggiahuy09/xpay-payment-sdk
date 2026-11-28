import 'package:json_annotation/json_annotation.dart';

part 'merchant_payment_response_model.g.dart';

@JsonSerializable(createToJson: false)
final class MerchantPaymentResponseModel {
  const MerchantPaymentResponseModel({
    this.captures,
    this.amount,
    this.authId,
    this.bookingRef,
    this.createdAt,
    this.currency,
    this.declineReason,
    this.externalRef,
    this.status,
  });

  factory MerchantPaymentResponseModel.fromJson(Map<String, dynamic> json) => _$MerchantPaymentResponseModelFromJson(json);

  final List<MerchantPaymentCaptureModel>? captures;
  final String? amount;
  @JsonKey(name: 'auth_id')
  final String? authId;
  @JsonKey(name: 'booking_ref')
  final String? bookingRef;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final String? currency;
  @JsonKey(name: 'decline_reason')
  final String? declineReason;
  @JsonKey(name: 'external_ref')
  final String? externalRef;
  final String? status;
}

@JsonSerializable(createToJson: false)
final class MerchantPaymentCaptureModel {
  const MerchantPaymentCaptureModel({this.captureId});

  factory MerchantPaymentCaptureModel.fromJson(Map<String, dynamic> json) => _$MerchantPaymentCaptureModelFromJson(json);

  @JsonKey(name: 'capture_id')
  final String? captureId;
}

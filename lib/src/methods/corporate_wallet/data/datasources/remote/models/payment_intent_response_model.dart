import 'package:json_annotation/json_annotation.dart';

part 'payment_intent_response_model.g.dart';

@JsonSerializable(createToJson: false)
final class PaymentIntentResponseModel {
  const PaymentIntentResponseModel({this.amount, this.authId, this.createdAt, this.currency, this.externalRef, this.intentId, this.paymentMethod, this.qrPayload, this.status});

  factory PaymentIntentResponseModel.fromJson(Map<String, dynamic> json) => _$PaymentIntentResponseModelFromJson(json);

  final String? amount;
  @JsonKey(name: 'auth_id')
  final String? authId;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final String? currency;
  @JsonKey(name: 'external_ref')
  final String? externalRef;
  @JsonKey(name: 'intent_id')
  final String? intentId;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'qr_payload')
  final String? qrPayload;
  final String? status;
}

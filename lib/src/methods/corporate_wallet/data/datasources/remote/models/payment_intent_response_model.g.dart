// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_intent_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentIntentResponseModel _$PaymentIntentResponseModelFromJson(
  Map<String, dynamic> json,
) => PaymentIntentResponseModel(
  amount: json['amount'] as String?,
  authId: json['auth_id'] as String?,
  createdAt: json['created_at'] as String?,
  currency: json['currency'] as String?,
  externalRef: json['external_ref'] as String?,
  intentId: json['intent_id'] as String?,
  paymentMethod: json['payment_method'] as String?,
  qrPayload: json['qr_payload'] as String?,
  status: json['status'] as String?,
);

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_payment_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MerchantPaymentResponseModel _$MerchantPaymentResponseModelFromJson(
  Map<String, dynamic> json,
) => MerchantPaymentResponseModel(
  captures: (json['captures'] as List<dynamic>?)
      ?.map(
        (e) => MerchantPaymentCaptureModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  amount: json['amount'] as String?,
  authId: json['auth_id'] as String?,
  bookingRef: json['booking_ref'] as String?,
  createdAt: json['created_at'] as String?,
  currency: json['currency'] as String?,
  declineReason: json['decline_reason'] as String?,
  externalRef: json['external_ref'] as String?,
  status: json['status'] as String?,
);

MerchantPaymentCaptureModel _$MerchantPaymentCaptureModelFromJson(
  Map<String, dynamic> json,
) => MerchantPaymentCaptureModel(captureId: json['capture_id'] as String?);

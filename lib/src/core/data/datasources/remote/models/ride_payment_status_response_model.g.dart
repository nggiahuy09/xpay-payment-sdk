// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_payment_status_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RidePaymentStatusResponseModel _$RidePaymentStatusResponseModelFromJson(
  Map<String, dynamic> json,
) => RidePaymentStatusResponseModel(
  payment: json['payment'] == null
      ? null
      : RidePaymentStatusPaymentModel.fromJson(
          json['payment'] as Map<String, dynamic>,
        ),
  externalRef: json['external_ref'] as String?,
  orderId: json['order_id'] as String?,
  rideStatus: json['ride_status'] as String?,
);

RidePaymentStatusPaymentModel _$RidePaymentStatusPaymentModelFromJson(
  Map<String, dynamic> json,
) => RidePaymentStatusPaymentModel(
  amount: json['amount'] as String?,
  authId: json['auth_id'] as String?,
  paidBy: json['paid_by'] as String?,
  paymentMethod: json['payment_method'] as String?,
);

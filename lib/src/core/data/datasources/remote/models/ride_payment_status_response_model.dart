import 'package:json_annotation/json_annotation.dart';

part 'ride_payment_status_response_model.g.dart';

@JsonSerializable(createToJson: false)
final class RidePaymentStatusResponseModel {
  const RidePaymentStatusResponseModel({this.payment, this.externalRef, this.orderId, this.rideStatus});

  factory RidePaymentStatusResponseModel.fromJson(Map<String, dynamic> json) => _$RidePaymentStatusResponseModelFromJson(json);

  final RidePaymentStatusPaymentModel? payment;
  @JsonKey(name: 'external_ref')
  final String? externalRef;
  @JsonKey(name: 'order_id')
  final String? orderId;
  @JsonKey(name: 'ride_status')
  final String? rideStatus;
}

@JsonSerializable(createToJson: false)
final class RidePaymentStatusPaymentModel {
  const RidePaymentStatusPaymentModel({this.amount, this.authId, this.paidBy, this.paymentMethod});

  factory RidePaymentStatusPaymentModel.fromJson(Map<String, dynamic> json) => _$RidePaymentStatusPaymentModelFromJson(json);

  final String? amount;
  @JsonKey(name: 'auth_id')
  final String? authId;
  @JsonKey(name: 'paid_by')
  final String? paidBy;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
}

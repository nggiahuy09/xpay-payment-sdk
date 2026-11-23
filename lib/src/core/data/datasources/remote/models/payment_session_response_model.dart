import 'package:json_annotation/json_annotation.dart';

part 'payment_session_response_model.g.dart';

@JsonSerializable(createToJson: false)
final class PaymentSessionResponseModel {
  const PaymentSessionResponseModel({this.entryModes, this.paymentTemplate, this.rideCard, this.amount, this.externalRef, this.orderId, this.paymentMethod, this.sessionToken});

  factory PaymentSessionResponseModel.fromJson(Map<String, dynamic> json) => _$PaymentSessionResponseModelFromJson(json);

  @JsonKey(name: 'entry_modes')
  final List<String>? entryModes;
  @JsonKey(name: 'payment_template')
  final PaymentSessionTemplateModel? paymentTemplate;
  @JsonKey(name: 'ride_card')
  final PaymentSessionRideCardModel? rideCard;
  final String? amount;
  @JsonKey(name: 'external_ref')
  final String? externalRef;
  @JsonKey(name: 'order_id')
  final String? orderId;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'session_token')
  final String? sessionToken;
}

@JsonSerializable(createToJson: false)
final class PaymentSessionTemplateModel {
  const PaymentSessionTemplateModel({this.enhancedData, this.currency, this.externalRef, this.productType});

  factory PaymentSessionTemplateModel.fromJson(Map<String, dynamic> json) => _$PaymentSessionTemplateModelFromJson(json);

  @JsonKey(name: 'enhanced_data')
  final PaymentSessionEnhancedDataModel? enhancedData;
  final String? currency;
  @JsonKey(name: 'external_ref')
  final String? externalRef;
  @JsonKey(name: 'product_type')
  final String? productType;
}

@JsonSerializable(createToJson: false)
final class PaymentSessionEnhancedDataModel {
  const PaymentSessionEnhancedDataModel({this.destination, this.pickupLocation, this.plateNumber});

  factory PaymentSessionEnhancedDataModel.fromJson(Map<String, dynamic> json) => _$PaymentSessionEnhancedDataModelFromJson(json);

  final String? destination;
  @JsonKey(name: 'pickup_location')
  final String? pickupLocation;
  @JsonKey(name: 'plate_number')
  final String? plateNumber;
}

@JsonSerializable(createToJson: false)
final class PaymentSessionRideCardModel {
  const PaymentSessionRideCardModel({this.cardLast4, this.cardName});

  factory PaymentSessionRideCardModel.fromJson(Map<String, dynamic> json) => _$PaymentSessionRideCardModelFromJson(json);

  @JsonKey(name: 'card_last4')
  final String? cardLast4;
  @JsonKey(name: 'card_name')
  final String? cardName;
}

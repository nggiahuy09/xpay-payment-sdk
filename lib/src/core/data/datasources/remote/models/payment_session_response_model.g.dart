// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_session_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentSessionResponseModel _$PaymentSessionResponseModelFromJson(
  Map<String, dynamic> json,
) => PaymentSessionResponseModel(
  entryModes: (json['entry_modes'] as List<dynamic>?)?.map((e) => e as String).toList(),
  paymentTemplate: json['payment_template'] == null
      ? null
      : PaymentSessionTemplateModel.fromJson(
          json['payment_template'] as Map<String, dynamic>,
        ),
  rideCard: json['ride_card'] == null
      ? null
      : PaymentSessionRideCardModel.fromJson(
          json['ride_card'] as Map<String, dynamic>,
        ),
  amount: json['amount'] as String?,
  externalRef: json['external_ref'] as String?,
  orderId: json['order_id'] as String?,
  paymentMethod: json['payment_method'] as String?,
  sessionToken: json['session_token'] as String?,
);

PaymentSessionTemplateModel _$PaymentSessionTemplateModelFromJson(
  Map<String, dynamic> json,
) => PaymentSessionTemplateModel(
  enhancedData: json['enhanced_data'] == null
      ? null
      : PaymentSessionEnhancedDataModel.fromJson(
          json['enhanced_data'] as Map<String, dynamic>,
        ),
  currency: json['currency'] as String?,
  externalRef: json['external_ref'] as String?,
  productType: json['product_type'] as String?,
);

PaymentSessionEnhancedDataModel _$PaymentSessionEnhancedDataModelFromJson(
  Map<String, dynamic> json,
) => PaymentSessionEnhancedDataModel(
  destination: json['destination'] as String?,
  pickupLocation: json['pickup_location'] as String?,
  plateNumber: json['plate_number'] as String?,
);

PaymentSessionRideCardModel _$PaymentSessionRideCardModelFromJson(
  Map<String, dynamic> json,
) => PaymentSessionRideCardModel(
  cardLast4: json['card_last4'] as String?,
  cardName: json['card_name'] as String?,
);

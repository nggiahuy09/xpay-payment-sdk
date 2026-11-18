import 'package:json_annotation/json_annotation.dart';

part 'payment_verification_recipient_model.g.dart';

@JsonSerializable(createToJson: false)
final class PaymentVerificationRecipientModel {
  const PaymentVerificationRecipientModel({this.recipientId, this.phoneMasked});

  factory PaymentVerificationRecipientModel.fromJson(Map<String, dynamic> json) => _$PaymentVerificationRecipientModelFromJson(json);

  @JsonKey(name: 'recipient_id')
  final String? recipientId;
  @JsonKey(name: 'phone_masked')
  final String? phoneMasked;
}

import 'package:json_annotation/json_annotation.dart';

part 'corporate_wallet_recipient_model.g.dart';

@JsonSerializable(createToJson: false)
final class CorporateWalletRecipientModel {
  const CorporateWalletRecipientModel({this.emailMasked, this.name, this.phoneMasked, this.recipientId});

  factory CorporateWalletRecipientModel.fromJson(Map<String, dynamic> json) => _$CorporateWalletRecipientModelFromJson(json);

  @JsonKey(name: 'email_masked')
  final String? emailMasked;
  final String? name;
  @JsonKey(name: 'phone_masked')
  final String? phoneMasked;
  @JsonKey(name: 'recipient_id')
  final String? recipientId;
}

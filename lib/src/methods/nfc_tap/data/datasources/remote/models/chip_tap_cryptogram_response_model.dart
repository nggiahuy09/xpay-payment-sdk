import 'package:json_annotation/json_annotation.dart';

part 'chip_tap_cryptogram_response_model.g.dart';

/// Response model for `POST /merchant/chip/tap/cryptogram`.
@JsonSerializable(createToJson: false)
final class ChipTapCryptogramResponseModel {
  const ChipTapCryptogramResponseModel({this.nonce, this.cryptogram, this.cardToken, this.keyVersion, this.counter});

  factory ChipTapCryptogramResponseModel.fromJson(Map<String, dynamic> json) => _$ChipTapCryptogramResponseModelFromJson(json);

  final String? nonce;
  final String? cryptogram;
  @JsonKey(name: 'card_token')
  final String? cardToken;
  @JsonKey(name: 'key_version')
  final int? keyVersion;
  final int? counter;
}

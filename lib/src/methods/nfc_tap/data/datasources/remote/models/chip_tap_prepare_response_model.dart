import 'package:json_annotation/json_annotation.dart';

part 'chip_tap_prepare_response_model.g.dart';

/// Response model for `POST /merchant/chip/tap/prepare`.
@JsonSerializable(createToJson: false)
final class ChipTapPrepareResponseModel {
  const ChipTapPrepareResponseModel({this.layout, this.chipUid, this.cardToken, this.issuerBlock, this.expectedMac, this.tokenKeyA, this.counterKeyB, this.keyVersion});

  factory ChipTapPrepareResponseModel.fromJson(Map<String, dynamic> json) => _$ChipTapPrepareResponseModelFromJson(json);

  final ChipTapLayoutRemoteModel? layout;
  @JsonKey(name: 'chip_uid')
  final String? chipUid;
  @JsonKey(name: 'card_token')
  final String? cardToken;
  @JsonKey(name: 'issuer_block')
  final String? issuerBlock;
  @JsonKey(name: 'expected_mac')
  final String? expectedMac;
  @JsonKey(name: 'token_key_a')
  final String? tokenKeyA;
  @JsonKey(name: 'counter_key_b')
  final String? counterKeyB;
  @JsonKey(name: 'key_version')
  final int? keyVersion;
}

/// Block/sector addresses the tap sequence must use, rather than hardcoding the personalization layout.
@JsonSerializable(createToJson: false)
final class ChipTapLayoutRemoteModel {
  const ChipTapLayoutRemoteModel({this.tokenSector, this.tokenBlock, this.issuerBlock, this.macBlock, this.counterSector, this.counterBlock});

  factory ChipTapLayoutRemoteModel.fromJson(Map<String, dynamic> json) => _$ChipTapLayoutRemoteModelFromJson(json);

  @JsonKey(name: 'token_sector')
  final int? tokenSector;
  @JsonKey(name: 'token_block')
  final int? tokenBlock;
  @JsonKey(name: 'issuer_block')
  final int? issuerBlock;
  @JsonKey(name: 'mac_block')
  final int? macBlock;
  @JsonKey(name: 'counter_sector')
  final int? counterSector;
  @JsonKey(name: 'counter_block')
  final int? counterBlock;
}

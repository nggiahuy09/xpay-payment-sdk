// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chip_tap_prepare_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChipTapPrepareResponseModel _$ChipTapPrepareResponseModelFromJson(
  Map<String, dynamic> json,
) => ChipTapPrepareResponseModel(
  layout: json['layout'] == null
      ? null
      : ChipTapLayoutRemoteModel.fromJson(
          json['layout'] as Map<String, dynamic>,
        ),
  chipUid: json['chip_uid'] as String?,
  cardToken: json['card_token'] as String?,
  issuerBlock: json['issuer_block'] as String?,
  expectedMac: json['expected_mac'] as String?,
  tokenKeyA: json['token_key_a'] as String?,
  counterKeyB: json['counter_key_b'] as String?,
  keyVersion: (json['key_version'] as num?)?.toInt(),
);

ChipTapLayoutRemoteModel _$ChipTapLayoutRemoteModelFromJson(
  Map<String, dynamic> json,
) => ChipTapLayoutRemoteModel(
  tokenSector: (json['token_sector'] as num?)?.toInt(),
  tokenBlock: (json['token_block'] as num?)?.toInt(),
  issuerBlock: (json['issuer_block'] as num?)?.toInt(),
  macBlock: (json['mac_block'] as num?)?.toInt(),
  counterSector: (json['counter_sector'] as num?)?.toInt(),
  counterBlock: (json['counter_block'] as num?)?.toInt(),
);

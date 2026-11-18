// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chip_tap_cryptogram_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChipTapCryptogramResponseModel _$ChipTapCryptogramResponseModelFromJson(
  Map<String, dynamic> json,
) => ChipTapCryptogramResponseModel(
  nonce: json['nonce'] as String?,
  cryptogram: json['cryptogram'] as String?,
  cardToken: json['card_token'] as String?,
  keyVersion: (json['key_version'] as num?)?.toInt(),
  counter: (json['counter'] as num?)?.toInt(),
);

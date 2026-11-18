import '../../domain/entities/chip_tap_cryptogram_entity.dart';
import '../../domain/entities/chip_tap_prepare_entity.dart';
import '../datasources/remote/models/chip_tap_cryptogram_response_model.dart';
import '../datasources/remote/models/chip_tap_prepare_response_model.dart';

extension ChipTapCryptogramResponseModelMapper on ChipTapCryptogramResponseModel {
  ChipTapCryptogramEntity toEntity() => ChipTapCryptogramEntity(nonce: nonce, cryptogram: cryptogram, cardToken: cardToken, keyVersion: keyVersion, counter: counter);
}

extension ChipTapPrepareResponseModelMapper on ChipTapPrepareResponseModel {
  ChipTapPrepareEntity toEntity() => ChipTapPrepareEntity(
    layout: layout?.toEntity(),
    chipUid: chipUid,
    cardToken: cardToken,
    issuerBlock: issuerBlock,
    expectedMac: expectedMac,
    tokenKeyA: tokenKeyA,
    counterKeyB: counterKeyB,
    keyVersion: keyVersion,
  );
}

extension ChipTapLayoutRemoteModelMapper on ChipTapLayoutRemoteModel {
  ChipTapLayoutEntity toEntity() =>
      ChipTapLayoutEntity(tokenSector: tokenSector, tokenBlock: tokenBlock, issuerBlock: issuerBlock, macBlock: macBlock, counterSector: counterSector, counterBlock: counterBlock);
}

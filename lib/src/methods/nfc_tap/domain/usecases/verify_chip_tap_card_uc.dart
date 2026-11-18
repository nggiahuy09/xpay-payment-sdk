import 'package:nfc_manager/nfc_manager.dart';

import '../../../../shared/helpers/helper_nfc.dart';
import '../entities/chip_tap_prepare_entity.dart';
import '../entities/chip_tap_verification_enum.dart';

/// Reads the chip's token sector and compares it against the issuer's record from `/merchant/chip/tap/prepare`.
///
/// Read-only, so every failure here leaves the card exactly as it was. The counter is only advanced once this has matched — writing first and verifying after would risk leaving a genuine card with a counter the server never learns about.
///
/// Deliberately does NOT implement [XPUseCase]: the mixin returns `Either<XPException, T>`, and none of the outcomes here are exceptions. A refused sector authentication, a tag pulled out of range, and a card whose MAC does not match are all ordinary verdicts about the card, already modelled by [ChipTapVerification]. Wrapping them in `Left` would leave the bloc unwrapping two failure representations to emit one state, and would force an [XPException] to be invented for conditions the server was never asked about.
///
/// Touches [XPHelperNfc] rather than a repository because the subject is the physical chip, not a remote resource — there is no datasource to reach through.
final class VerifyChipTapCardUseCase {
  const VerifyChipTapCardUseCase();

  Future<ChipTapVerification> execute(VerifyChipTapCardInput input) async {
    final prepare = input.prepare;
    final layout = prepare.layout;
    final keyA = XPHelperNfc.hexToBytes(prepare.tokenKeyA);
    if (prepare.isTapReady == false || layout == null || keyA == null) return ChipTapVerification.incompleteLayout;

    // Non-null by way of `isComplete`, which `isTapReady` already required — read into locals so the reads below are not littered with assertions.
    final tokenSector = layout.tokenSector;
    final tokenBlock = layout.tokenBlock;
    final issuerBlock = layout.issuerBlock;
    final macBlock = layout.macBlock;
    if (tokenSector == null || tokenBlock == null || issuerBlock == null || macBlock == null) return ChipTapVerification.incompleteLayout;

    XPNfcTokenSectorRead? read;
    try {
      read = await XPHelperNfc.readTokenSector(tag: input.tag, keyA: keyA, sector: tokenSector, tokenBlock: tokenBlock, issuerBlock: issuerBlock, macBlock: macBlock);
    } catch (e) {
      // A tag moved out of range mid-read throws rather than returning null, and is the common case here — the operator can simply tap again.
      // XPLogger.error(error: e, message: 'Failed to read chip token sector');
    }

    return ChipTapVerification.resolve(
      expectedMac: prepare.expectedMac,
      actualMac: read?.mac,
      expectedCardToken: prepare.cardToken,
      actualCardToken: read?.cardToken,
    );
  }
}

final class VerifyChipTapCardInput {
  const VerifyChipTapCardInput({required this.tag, required this.prepare});

  final NfcTag tag;
  final ChipTapPrepareEntity prepare;
}

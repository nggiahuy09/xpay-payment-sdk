import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';

import '../../base/define/logging/logger.dart';

final class XPHelperNfc {
  const XPHelperNfc._();

  /// Parses a hex string into bytes, or null when it is not valid hex of even length.
  ///
  /// Crypto1 keys arrive from the broker as uppercase hex; every other hex field is compared as a string rather than parsed, so this exists mainly for keys.
  static Uint8List? hexToBytes(String? value) {
    if (value == null || value.isEmpty || value.length.isOdd) return null;

    final bytes = Uint8List(value.length ~/ 2);
    for (var index = 0; index < bytes.length; index++) {
      final byte = int.tryParse(value.substring(index * 2, index * 2 + 2), radix: 16);
      if (byte == null) return null;

      bytes[index] = byte;
    }

    return bytes;
  }

  /// Formats bytes as lowercase hex, matching the casing the chip endpoints expect.
  static String bytesToHex(Uint8List bytes) => bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

  static Future<bool> isSupported() async {
    return switch (await NfcManager.instance.checkAvailability()) {
      NfcAvailability.unsupported => false,
      _ => true,
    };
  }

  static Future<bool> isEnabled() async {
    return switch (await NfcManager.instance.checkAvailability()) {
      NfcAvailability.enabled => true,
      _ => false,
    };
  }

  /// Reads the tag UID as lowercase hex, or null when the tag exposes no identifier on this platform.
  ///
  /// Lowercase because that is the casing the chip endpoints expect for `chip_uid`, and hex comparisons against the server's records are done on the raw string.
  ///
  /// On Android every discovered tag carries an id regardless of its technology. On iOS there is no equivalent generic accessor, so the ISO 14443 tag classes
  /// are tried in turn.
  static String? readUid(NfcTag? tag) {
    if (tag == null) return null;

    final identifier = switch (defaultTargetPlatform) {
      TargetPlatform.android => NfcTagAndroid.from(tag)?.id,
      TargetPlatform.iOS => MiFareIos.from(tag)?.identifier ?? Iso7816Ios.from(tag)?.identifier,
      _ => null,
    };
    if (identifier == null || identifier.isEmpty) return null;

    return identifier.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Whether this tag can be driven with Crypto1 sector authentication on this handset.
  ///
  /// MIFARE Classic is not part of the NFC Forum standards — it needs an NXP controller to implement Crypto1, so a handset that reads the tag's UID perfectly
  /// well may still be unable to authenticate a sector. Returns false on iOS unconditionally: CoreNFC exposes no Crypto1 primitive at all.
  static bool isMifareClassic(NfcTag? tag) {
    if (tag == null || defaultTargetPlatform != TargetPlatform.android) return false;

    return MifareClassicAndroid.from(tag) != null;
  }

  /// Authenticates the token sector with Key A and reads the card token, issuer, and MAC blocks.
  ///
  /// Read-only: nothing here writes to the chip, so a failure at any point leaves the card exactly as it was and the tap can simply be abandoned.
  ///
  /// [sector] comes from the broker's layout rather than being derived from [tokenBlock]. Crypto1 authenticates per sector, not per block, and deriving the
  /// sector locally would mean reimplementing MIFARE's non-uniform 1K/4K block-to-sector mapping for a value the server already states.
  ///
  /// Returns null when the tag is not MIFARE Classic on this handset or the sector authentication is refused — a wrong key and a non-NXP controller are
  /// indistinguishable here, and neither can be recovered from by retrying.
  static Future<XPNfcTokenSectorRead?> readTokenSector({
    required NfcTag tag,
    required Uint8List keyA,
    required int sector,
    required int tokenBlock,
    required int issuerBlock,
    required int macBlock,
  }) async {
    final mifare = MifareClassicAndroid.from(tag);
    if (mifare == null) return null;

    if (await mifare.authenticateSectorWithKeyA(sectorIndex: sector, key: keyA) == false) return null;

    return XPNfcTokenSectorRead(
      cardToken: bytesToHex(await mifare.readBlock(blockIndex: tokenBlock)),
      issuerBlock: bytesToHex(await mifare.readBlock(blockIndex: issuerBlock)),
      mac: bytesToHex(await mifare.readBlock(blockIndex: macBlock)),
    );
  }

  /// Parses a MIFARE value block, validating the redundant copies the chip itself enforces.
  ///
  /// The on-card format is `value(4 LE) ‖ ~value(4 LE) ‖ value(4 LE) ‖ addr ‖ ~addr ‖ addr ‖ ~addr`. Returns null when the copies disagree: that means the block
  /// is not a value block, and treating arbitrary bytes as a counter would present a number the card never held.
  ///
  /// Read and compared as unsigned 32-bit throughout. Dart's `~` is a 64-bit operation, so complementing a value read as *signed* produces a number outside the
  /// int32 range and the inverted-copy check would reject blocks the chip considers valid.
  static int? parseValueBlock(Uint8List bytes) {
    if (bytes.length < 12) return null;

    final data = ByteData.sublistView(bytes);
    final value = data.getUint32(0, Endian.little);
    if (value != data.getUint32(8, Endian.little) || data.getUint32(4, Endian.little) != (~value & 0xffffffff)) return null;

    return value;
  }

  /// Builds the on-card representation of [value] for [blockIndex], for the `writeBlock` fallback path.
  ///
  /// Written as unsigned 32-bit to match [parseValueBlock], and masked because Dart's `~` is a 64-bit operation whose result would otherwise be out of range for
  /// `setUint32`.
  static Uint8List buildValueBlock(int value, int blockIndex) {
    final bytes = Uint8List(16);
    final data = ByteData.sublistView(bytes);
    data.setUint32(0, value & 0xffffffff, Endian.little);
    data.setUint32(4, ~value & 0xffffffff, Endian.little);
    data.setUint32(8, value & 0xffffffff, Endian.little);

    final address = blockIndex & 0xff;
    bytes[12] = address;
    bytes[13] = ~address & 0xff;
    bytes[14] = address;
    bytes[15] = ~address & 0xff;

    return bytes;
  }

  /// Authenticates the counter sector with Key B, advances the counter by one, and reads it back.
  ///
  /// This is the only write in the tap. The read-back is mandatory rather than defensive: the value presented to the server must be the value actually sitting on
  /// the card. Drift upwards (card ahead of server) is harmless because the next tap still presents a higher number, but presenting a counter the card never took
  /// is what the server reads as a replay.
  ///
  /// Falls back to writing a hand-assembled value block when the controller refuses `increment`/`transfer`, which some do. Writing uses the same Key B that was
  /// already authenticated.
  ///
  /// Returns null when the sector cannot be authenticated, the block is not a valid value block, or the counter did not advance by exactly one.
  static Future<int?> incrementCounter({required NfcTag tag, required Uint8List keyB, required int sector, required int block}) async {
    final mifare = MifareClassicAndroid.from(tag);
    if (mifare == null) return null;

    if (await mifare.authenticateSectorWithKeyB(sectorIndex: sector, key: keyB) == false) return null;

    final before = parseValueBlock(await mifare.readBlock(blockIndex: block));
    // A counter already at the 32-bit ceiling cannot advance without wrapping to zero, which the server would read as a replay. Refuse before writing rather than
    // relying on the read-back check below to catch it after the fact.
    if (before == null || before >= 0xffffffff) return null;

    try {
      await mifare.increment(blockIndex: block, value: 1);
      await mifare.transfer(blockIndex: block);
    } catch (e) {
      XPLogger.error(error: e, message: 'increment/transfer refused on block $block, falling back to writeBlock');
      await mifare.writeBlock(blockIndex: block, data: buildValueBlock(before + 1, block));
    }

    final after = parseValueBlock(await mifare.readBlock(blockIndex: block));
    if (after != before + 1) return null;

    return after;
  }

  /// Starts a polling session and hands the discovered tag to [onDetected].
  ///
  /// The session is deliberately left open: closing it invalidates the tag, and a MIFARE Classic tap has to keep reading and writing after discovery. The
  /// caller owns the session from here and must call [stop] once it is done with the tag — including on every failure path.
  static Future<void> start({
    required Future<void> Function(NfcTag tag) onDetected,
    void Function(Object? error)? onError,
    void Function(String code, String message)? onIosError,
  }) async {
    try {
      await NfcManager.instance.startSession(
        pollingOptions: const {NfcPollingOption.iso14443},
        invalidateAfterFirstReadIos: false,
        onDiscovered: (tag) async {
          try {
            await onDetected.call(tag);
          } catch (e) {
            onError?.call(e);
          }
        },
        onSessionErrorIos: (error) => onIosError?.call(error.code.name, error.message),
      );
    } catch (e) {
      onError?.call(e);
    }
  }

  static Future<void> stop({String? alertMessageIos, String? errorMessageIos}) async {
    try {
      await NfcManager.instance.stopSession(alertMessageIos: alertMessageIos, errorMessageIos: errorMessageIos);
    } catch (_) {
      // Stopping an already-invalidated session is not an error worth surfacing — the tag is gone either way.
    }
  }
}

/// The three token-sector blocks as read off the chip, in lowercase hex.
///
/// Raw chip data — comparing it against the issuer's record is the caller's job, and must be done case-insensitively since the broker returns key material
/// uppercase while `card_token` is lowercase.
@immutable
final class XPNfcTokenSectorRead {
  const XPNfcTokenSectorRead({required this.cardToken, required this.issuerBlock, required this.mac});

  final String cardToken;
  final String issuerBlock;
  final String mac;
}

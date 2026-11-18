import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// What the broker hands the terminal for one tap: the issuer's record of the card, plus the two Crypto1 keys needed to read the token sector and advance the
/// counter.
///
/// Deliberately narrower than the admin key bundle — it carries no `auth_key`, so the terminal cannot mint cryptograms offline. Hold an instance for the
/// duration of a single tap, never write it to disk, and never log the key fields.
@immutable
final class ChipTapPrepareEntity with Equatable {
  const ChipTapPrepareEntity({this.layout, this.chipUid, this.cardToken, this.issuerBlock, this.expectedMac, this.tokenKeyA, this.counterKeyB, this.keyVersion});

  final ChipTapLayoutEntity? layout;
  final String? chipUid;
  final String? cardToken;
  final String? issuerBlock;
  final String? expectedMac;
  final String? tokenKeyA;
  final String? counterKeyB;
  final int? keyVersion;

  /// Whether everything the tap sequence needs is present: a complete layout, both sector keys, and the issuer's record to compare the chip against.
  bool get isTapReady =>
      (layout?.isComplete ?? false) &&
      (cardToken?.isNotEmpty ?? false) &&
      (expectedMac?.isNotEmpty ?? false) &&
      (tokenKeyA?.isNotEmpty ?? false) &&
      (counterKeyB?.isNotEmpty ?? false);

  @override
  List<Object?> get props => [layout, chipUid, cardToken, issuerBlock, expectedMac, tokenKeyA, counterKeyB, keyVersion];
}

/// Where the personalized data sits on the chip. Read from the response rather than hardcoded, so relocating a block is a backend change instead of an app release.
@immutable
final class ChipTapLayoutEntity with Equatable {
  const ChipTapLayoutEntity({this.tokenSector, this.tokenBlock, this.issuerBlock, this.macBlock, this.counterSector, this.counterBlock});

  final int? tokenSector;
  final int? tokenBlock;
  final int? issuerBlock;
  final int? macBlock;
  final int? counterSector;
  final int? counterBlock;

  /// Whether every address the tap sequence touches is present. A partial layout cannot be defaulted — guessing a block would read or write the wrong one.
  bool get isComplete => tokenSector != null && tokenBlock != null && issuerBlock != null && macBlock != null && counterSector != null && counterBlock != null;

  @override
  List<Object?> get props => [tokenSector, tokenBlock, issuerBlock, macBlock, counterSector, counterBlock];
}

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// The broker's signature over one tap, ready to be presented to `/merchant/payments/authorize`.
///
/// The signing key never leaves the server, so this is the only form in which a tap can be authorized. The nonce is single-use: one of these authorizes exactly
/// one payment, and reusing it is rejected.
@immutable
final class ChipTapCryptogramEntity with Equatable {
  const ChipTapCryptogramEntity({this.nonce, this.cryptogram, this.cardToken, this.keyVersion, this.counter});

  final String? nonce;
  final String? cryptogram;
  final String? cardToken;
  final int? keyVersion;
  final int? counter;

  /// Whether every field `authorize` requires for a chip tap is present.
  ///
  /// [keyVersion] is included even though the endpoint treats it as optional: omitting it makes the server fall back to the credential's stored version, which is
  /// correct today but silently wrong the moment a card is re-personalized at a new version.
  bool get isAuthorizable => (nonce?.isNotEmpty ?? false) && (cryptogram?.isNotEmpty ?? false) && (cardToken?.isNotEmpty ?? false) && counter != null && keyVersion != null;

  @override
  List<Object?> get props => [nonce, cryptogram, cardToken, keyVersion, counter];
}

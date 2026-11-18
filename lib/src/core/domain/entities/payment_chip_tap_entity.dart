import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// The chip-tap evidence `authorize` requires alongside the card token, produced by `/merchant/chip/tap/cryptogram`.
///
/// Grouped rather than passed as four loose parameters because they are only ever valid together: the cryptogram signs this exact counter under this exact nonce,
/// so mixing values from different taps produces a signature the server rejects.
@immutable
final class PaymentChipTapEntity with Equatable {
  const PaymentChipTapEntity({required this.cryptogram, required this.nonce, required this.counter, this.keyVersion});

  final String cryptogram;
  final String nonce;
  final int counter;

  /// Optional to the endpoint, but always sent when the broker supplies it: omitting it makes the server fall back to the credential's stored version, which is
  /// correct today and silently wrong once a card is re-personalized at a new version.
  final int? keyVersion;

  /// Fingerprint of the evidence this tap flattens into the authorize body.
  String get idempotencySignature => jsonEncode([cryptogram, nonce, counter, keyVersion]);

  @override
  List<Object?> get props => [cryptogram, nonce, counter, keyVersion];
}

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'corporate_wallet_otp_method_enum.dart';

@immutable
final class CorporateWalletChallengeEntity with Equatable {
  const CorporateWalletChallengeEntity({
    required this.method,
    this.expiresAt,
    required this.destinationMasked,
    required this.recipientId,
    required this.walletPaymentId,
    this.attemptsRemaining,
  });

  final CorporateWalletOtpMethod method;
  final DateTime? expiresAt;
  final String destinationMasked;
  final String recipientId;
  final String walletPaymentId;
  final int? attemptsRemaining;

  bool get isCodeExpired => expiresAt?.isAfter(DateTime.now()) == false;

  @override
  List<Object?> get props => [method, expiresAt, destinationMasked, recipientId, walletPaymentId, attemptsRemaining];
}

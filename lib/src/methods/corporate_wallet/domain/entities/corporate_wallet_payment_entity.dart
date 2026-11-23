import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class CorporateWalletPaymentEntity with Equatable {
  const CorporateWalletPaymentEntity({this.currency, this.externalRef, this.walletPaymentId, this.amount});

  final String? currency;
  final String? externalRef;
  final String? walletPaymentId;
  final String? amount;

  @override
  List<Object?> get props => [currency, externalRef, walletPaymentId, amount];
}

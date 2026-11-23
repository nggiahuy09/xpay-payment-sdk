import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'payment_intent_status_enum.dart';

@immutable
final class PaymentIntentEntity with Equatable {
  const PaymentIntentEntity({required this.status, this.createdAt, this.authId, this.currency, this.externalRef, required this.intentId, this.qrPayload, this.amount});

  final PaymentIntentStatus status;
  final DateTime? createdAt;
  final String? authId;
  final String? currency;
  final String? externalRef;
  final String intentId;
  final String? qrPayload;
  final String? amount;

  @override
  List<Object?> get props => [status, createdAt, authId, currency, externalRef, intentId, qrPayload, amount];
}

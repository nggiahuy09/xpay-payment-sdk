import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'payment_verify_entity.dart';

/// Result handed back when the verification flow pops.
///
/// Carries the [outcome] so the caller can branch without re-deriving it from
/// the entity, plus the [verify] payload the success screen renders.
@immutable
final class PaymentVerifyResultEntity with Equatable {
  const PaymentVerifyResultEntity({required this.verify, required this.outcome});

  final PaymentVerifyEntity verify;
  final PaymentVerifyOutcome outcome;

  @override
  List<Object?> get props => [verify, outcome];
}

/// Terminal outcome of a verification round-trip.
///
/// A declined verification still ends the flow the same way an approved one
/// does — the server accepted the request (200/201) and recorded a transaction,
/// so the caller returns to home either way and only the copy differs.
enum PaymentVerifyOutcome {
  approved,
  declined;

  bool get isApproved => this == PaymentVerifyOutcome.approved;

  bool get isDeclined => this == PaymentVerifyOutcome.declined;
}

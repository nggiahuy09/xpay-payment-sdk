import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'payment_failure_entity.dart';
import 'ride_payment_status_entity.dart';

@immutable
sealed class PaymentCheckoutResultEntity with Equatable {
  const PaymentCheckoutResultEntity();

  @override
  List<Object?> get props => [];
}

final class PaymentCheckoutPaidResultEntity extends PaymentCheckoutResultEntity {
  const PaymentCheckoutPaidResultEntity(this.payment);

  final PaymentCheckoutPaymentEntity payment;

  @override
  List<Object?> get props => [payment];
}

final class PaymentCheckoutRetryInPartnerResultEntity extends PaymentCheckoutResultEntity {
  const PaymentCheckoutRetryInPartnerResultEntity(this.failure);

  final PaymentFailureEntity failure;

  @override
  List<Object?> get props => [failure];
}

final class PaymentCheckoutOtherMethodResultEntity extends PaymentCheckoutResultEntity {
  const PaymentCheckoutOtherMethodResultEntity(this.failure);

  final PaymentFailureEntity failure;

  @override
  List<Object?> get props => [failure];
}

final class PaymentCheckoutHotlinePendingResultEntity extends PaymentCheckoutResultEntity {
  const PaymentCheckoutHotlinePendingResultEntity(this.failure);

  final PaymentFailureEntity failure;

  @override
  List<Object?> get props => [failure];
}

final class PaymentCheckoutRideClosedResultEntity extends PaymentCheckoutResultEntity {
  const PaymentCheckoutRideClosedResultEntity(this.settlement);

  final RideSettlement settlement;

  @override
  List<Object?> get props => [settlement];
}

final class PaymentCheckoutCancelledResultEntity extends PaymentCheckoutResultEntity {
  const PaymentCheckoutCancelledResultEntity([this.pendingAuthId]);

  final String? pendingAuthId;

  @override
  List<Object?> get props => [pendingAuthId];
}

final class PaymentCheckoutUnavailableResultEntity extends PaymentCheckoutResultEntity {
  const PaymentCheckoutUnavailableResultEntity(this.errorCode);

  final String errorCode;

  @override
  List<Object?> get props => [errorCode];
}

@immutable
final class PaymentCheckoutPaymentEntity with Equatable {
  const PaymentCheckoutPaymentEntity({required this.paidBy, this.createdAt, this.authId, this.captureId, this.currency, this.externalRef, this.amount});

  final RidePaymentPayer paidBy;
  final DateTime? createdAt;
  final String? authId;
  final String? captureId;
  final String? currency;
  final String? externalRef;
  final String? amount;

  @override
  List<Object?> get props => [paidBy, createdAt, authId, captureId, currency, externalRef, amount];
}

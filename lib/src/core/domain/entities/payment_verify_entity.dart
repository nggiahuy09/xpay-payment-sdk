import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'payment_authorize_entity.dart';
import 'payment_decline_entity.dart';

@immutable
final class PaymentVerifyEntity with Equatable {
  const PaymentVerifyEntity({
    required this.status,
    this.verification,
    this.attribution,
    this.declineReason,
    this.holdExpiresAt,
    this.createdAt,
    this.authId,
    this.captureId,
    this.cardId,
    this.corporateId,
    this.bookingRef,
    this.externalRef,
    this.policyCheck,
    this.amount,
    this.currency,
  });

  final PaymentAuthorizeVerificationEntity? verification;
  final PaymentVerifyAttributionEntity? attribution;
  final PaymentAuthorizeStatus status;
  final PaymentDeclineEntity? declineReason;
  final DateTime? holdExpiresAt;
  final DateTime? createdAt;
  final String? authId;
  final String? captureId;
  final String? cardId;
  final String? corporateId;
  final String? bookingRef;
  final String? externalRef;
  final String? policyCheck;
  final String? amount;
  final String? currency;

  bool get isCaptured => status == PaymentAuthorizeStatus.captured && declineReason == null;

  bool get isApproved => status == PaymentAuthorizeStatus.approved && declineReason == null;

  bool get isDeclined => status == PaymentAuthorizeStatus.declined || declineReason != null;

  /// A present decline reason disqualifies the pending state the same way it does [isApproved] and [isCaptured]: the payment service rejected the payment outright, so
  /// there is nothing left to verify and the caller must route to the decline sheet rather than prompt for another code.
  bool get requiresVerification => status == PaymentAuthorizeStatus.pendingVerification && verification != null && declineReason == null;

  @override
  List<Object?> get props => [
    verification,
    attribution,
    status,
    declineReason,
    holdExpiresAt,
    createdAt,
    authId,
    captureId,
    cardId,
    corporateId,
    bookingRef,
    externalRef,
    policyCheck,
    amount,
    currency,
  ];
}

@immutable
final class PaymentVerifyAttributionEntity with Equatable {
  const PaymentVerifyAttributionEntity({this.userId, this.corporateId, this.costCenterId, this.department, this.tripId, this.tripMatch});

  final String? userId;
  final String? corporateId;
  final String? costCenterId;
  final String? department;
  final String? tripId;
  final String? tripMatch;

  @override
  List<Object?> get props => [userId, corporateId, costCenterId, department, tripId, tripMatch];
}

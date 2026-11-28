import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'payment_authorize_entity.dart';
import 'payment_verify_entity.dart';
import 'payment_verify_result_entity.dart';

@immutable
sealed class PaymentFlowOutcomeEntity with Equatable {
  const PaymentFlowOutcomeEntity();

  @override
  List<Object?> get props => [];
}

final class PaymentFlowAuthorizedOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowAuthorizedOutcomeEntity(this.authorize);

  final PaymentAuthorizeEntity authorize;

  @override
  List<Object?> get props => [authorize];
}

final class PaymentFlowVerifiedOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowVerifiedOutcomeEntity({required this.result, required this.authId});

  final PaymentVerifyResultEntity result;
  final String authId;

  PaymentVerifyEntity get verify => result.verify;

  @override
  List<Object?> get props => [result, authId];
}

final class PaymentFlowWalletCapturedOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowWalletCapturedOutcomeEntity({this.createdAt, this.authId, this.currency, this.externalRef, this.amount});

  final DateTime? createdAt;
  final String? authId;
  final String? currency;
  final String? externalRef;
  final String? amount;

  @override
  List<Object?> get props => [createdAt, authId, currency, externalRef, amount];
}

final class PaymentFlowWalletDeclinedOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowWalletDeclinedOutcomeEntity();
}

final class PaymentFlowWalletInterruptedOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowWalletInterruptedOutcomeEntity([this.errorCode]);

  final String? errorCode;

  @override
  List<Object?> get props => [errorCode];
}

final class PaymentFlowQrExpiredOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowQrExpiredOutcomeEntity();
}

final class PaymentFlowExpiredOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowExpiredOutcomeEntity();
}

final class PaymentFlowCancelledOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowCancelledOutcomeEntity([this.authId]);

  final String? authId;

  @override
  List<Object?> get props => [authId];
}

final class PaymentFlowConflictOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowConflictOutcomeEntity({this.errorCode, this.pendingAuthId});

  final String? errorCode;
  final String? pendingAuthId;

  @override
  List<Object?> get props => [errorCode, pendingAuthId];
}

final class PaymentFlowFailedOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowFailedOutcomeEntity({this.errorCode, this.pendingAuthId});

  final String? errorCode;
  final String? pendingAuthId;

  @override
  List<Object?> get props => [errorCode, pendingAuthId];
}

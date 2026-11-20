import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'create_payment_authorize_failure_reason_enum.dart';
import 'payment_authorize_entity.dart';
import 'payment_entry_mode_enum.dart';
import 'payment_verify_entity.dart';
import 'payment_verify_result_entity.dart';

@immutable
sealed class PaymentFlowOutcomeEntity with Equatable {
  const PaymentFlowOutcomeEntity();

  @override
  List<Object?> get props => [];
}

final class PaymentFlowAuthorizedOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowAuthorizedOutcomeEntity({required this.authorize, required this.entryMode});

  final PaymentAuthorizeEntity authorize;
  final PaymentEntryMode entryMode;

  @override
  List<Object?> get props => [authorize, entryMode];
}

final class PaymentFlowVerifiedOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowVerifiedOutcomeEntity({required this.result, required this.entryMode, required this.authId});

  final PaymentVerifyResultEntity result;
  final PaymentEntryMode entryMode;
  final String authId;

  PaymentVerifyEntity get verify => result.verify;

  @override
  List<Object?> get props => [result, entryMode, authId];
}

final class PaymentFlowExpiredOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowExpiredOutcomeEntity(this.authId);

  final String authId;

  @override
  List<Object?> get props => [authId];
}

final class PaymentFlowCancelledOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowCancelledOutcomeEntity([this.authId]);

  final String? authId;

  @override
  List<Object?> get props => [authId];
}

final class PaymentFlowConflictOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowConflictOutcomeEntity();
}

final class PaymentFlowFailedOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowFailedOutcomeEntity({this.authId, this.displayMessage, this.errorCode});

  final String? authId;
  final String? displayMessage;
  final String? errorCode;

  @override
  List<Object?> get props => [authId, displayMessage, errorCode];
}

final class PaymentFlowAuthorizeFailedOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowAuthorizeFailedOutcomeEntity({required this.entryMode, required this.reason, this.displayMessage, this.errorCode});

  final PaymentEntryMode entryMode;
  final CreatePaymentAuthorizeFailureReason reason;
  final String? displayMessage;
  final String? errorCode;

  @override
  List<Object?> get props => [entryMode, reason, displayMessage, errorCode];
}

final class PaymentFlowUnsupportedOutcomeEntity extends PaymentFlowOutcomeEntity {
  const PaymentFlowUnsupportedOutcomeEntity();
}

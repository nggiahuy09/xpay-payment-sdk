import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../base/localization/localization.dart';
import 'payment_authorize_entity.dart';
import 'payment_decline_entity.dart';

/// A rejected verification code the merchant can still correct, carried as data so it outlives the state that produced it.
///
/// The view empties the input after a rejection, which dispatches a code-change event; holding the message here lets that change preserve it instead of dropping it
/// along with the state it belonged to.
@immutable
final class VerificationRejectionEntity with Equatable {
  const VerificationRejectionEntity({required this.method, this.declineReason, required this.remainingAttempts});

  final PaymentAuthorizeVerificationMethod method;
  final PaymentDeclineEntity? declineReason;
  final int remainingAttempts;

  String getMessageTitle(XPLocaleBase locale) {
    final viewLocale = locale.payment.verification;
    return switch (method) {
      PaymentAuthorizeVerificationMethod.smsOtp => viewLocale.otpInvalidTitle,
      PaymentAuthorizeVerificationMethod.staticCode => viewLocale.pinInvalidTitle,
      PaymentAuthorizeVerificationMethod.tokenPin => viewLocale.pinInvalidTitle,
      PaymentAuthorizeVerificationMethod.unknown => viewLocale.invalidCodeTitle,
    };
  }

  String getMessageBody(XPLocaleBase locale) {
    final viewLocale = locale.payment.verification;
    return declineReason?.getMessage(locale) ??
        switch (method) {
          PaymentAuthorizeVerificationMethod.smsOtp => viewLocale.otpInvalidBody,
          PaymentAuthorizeVerificationMethod.staticCode => viewLocale.pinInvalidBody,
          PaymentAuthorizeVerificationMethod.tokenPin => viewLocale.pinInvalidBody,
          PaymentAuthorizeVerificationMethod.unknown => viewLocale.invalidCodeBody,
        };
  }

  @override
  List<Object?> get props => [method, declineReason, remainingAttempts];
}

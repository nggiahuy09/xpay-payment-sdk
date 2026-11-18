import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../base/extensions/extensions.dart';
import '../../../base/localization/localization.dart';
import 'payment_decline_entity.dart';
import 'payment_verification_recipient_entity.dart';

@immutable
final class PaymentAuthorizeEntity with Equatable {
  const PaymentAuthorizeEntity({
    required this.status,
    this.verification,
    this.declineReason,
    this.holdExpiresAt,
    this.createdAt,
    this.authId,
    this.captureId,
    this.externalRef,
    this.amount,
    this.currency,
  });

  final PaymentAuthorizeVerificationEntity? verification;
  final PaymentAuthorizeStatus status;
  final PaymentDeclineEntity? declineReason;
  final DateTime? holdExpiresAt;
  final DateTime? createdAt;
  final String? authId;
  final String? captureId;
  final String? externalRef;
  final String? amount;
  final String? currency;

  bool get isApproved => status == PaymentAuthorizeStatus.approved && declineReason == null;

  bool get isCaptured => status == PaymentAuthorizeStatus.captured && declineReason == null;

  bool get isDeclined => status == PaymentAuthorizeStatus.declined || declineReason != null;

  /// A present decline reason disqualifies the pending state the same way it does [isApproved] and [isCaptured]: the payment service rejected the payment outright, so
  /// there is nothing left to verify and the caller must route to the decline sheet rather than prompt for another code.
  bool get requiresVerification => status == PaymentAuthorizeStatus.pendingVerification && verification != null && declineReason == null;

  bool get canPresentVerification => requiresVerification && (verification?.method.isSupported ?? false);

  @override
  List<Object?> get props => [verification, status, holdExpiresAt, createdAt, authId, captureId, declineReason, externalRef, amount, currency];
}

@immutable
final class PaymentAuthorizeVerificationEntity with Equatable {
  const PaymentAuthorizeVerificationEntity({
    List<PaymentVerificationRecipientEntity> recipients = const [],
    required this.method,
    this.expiresAt,
    this.verificationDeadline,
    this.canResendAt,
    this.attemptsRemaining,
    this.resendsRemaining,
    this.phoneMasked,
    this.isRecipientRequired = false,
  }) : _recipients = recipients;

  static const Duration resendCooldownFallback = Duration(seconds: 40);

  final List<PaymentVerificationRecipientEntity> _recipients;
  final PaymentAuthorizeVerificationMethod method;
  final DateTime? expiresAt;
  final DateTime? verificationDeadline;
  final DateTime? canResendAt;
  final int? attemptsRemaining;
  final int? resendsRemaining;
  final String? phoneMasked;
  final bool isRecipientRequired;

  List<PaymentVerificationRecipientEntity> get recipients => List.unmodifiable(_recipients);

  bool get isResendSupported => method == PaymentAuthorizeVerificationMethod.smsOtp;

  bool get hasResendsRemaining => (resendsRemaining ?? 1) > 0;

  bool get hasRecipients => isResendSupported && _recipients.isNotEmpty;

  bool get isAwaitingRecipient => isResendSupported && isRecipientRequired;

  String? get phoneLastDigits {
    final phone = phoneMasked;
    return phone == null ? null : PaymentVerificationRecipientEntity.lastDigitsOf(phone);
  }

  String? get currentRecipientId {
    final phone = phoneMasked;
    if (isAwaitingRecipient || phone == null) return null;

    return _recipients.firstWhereOrNull((recipient) => recipient.phoneMasked == phone)?.recipientId;
  }

  bool get isDeadlinePassed {
    final deadline = verificationDeadline;
    return deadline != null && !deadline.isAfter(DateTime.now());
  }

  bool get isCodeExpiredWithinSession {
    final expiry = expiresAt;
    return !isAwaitingRecipient && !isDeadlinePassed && expiry != null && !expiry.isAfter(DateTime.now());
  }

  @override
  List<Object?> get props => [_recipients, method, expiresAt, verificationDeadline, canResendAt, attemptsRemaining, resendsRemaining, phoneMasked, isRecipientRequired];

  bool isRecipientAvailable(String recipientId) => _recipients.any((recipient) => recipient.recipientId == recipientId);
}

enum PaymentAuthorizeStatus {
  pendingVerification,
  approved,
  declined,
  captured,
  partiallyCaptured,
  voided,
  expired,
  unknown;

  String getTitle(XPLocaleBase locale) {
    final statusLocale = locale.payment.xpay.status;
    return switch (this) {
      PaymentAuthorizeStatus.pendingVerification => statusLocale.pendingVerification,
      PaymentAuthorizeStatus.approved => statusLocale.approved,
      PaymentAuthorizeStatus.declined => statusLocale.declined,
      PaymentAuthorizeStatus.captured => statusLocale.captured,
      PaymentAuthorizeStatus.partiallyCaptured => statusLocale.partiallyCaptured,
      PaymentAuthorizeStatus.voided => statusLocale.voided,
      PaymentAuthorizeStatus.expired => statusLocale.expired,
      PaymentAuthorizeStatus.unknown => statusLocale.unknown,
    };
  }
}

enum PaymentAuthorizeVerificationMethod {
  smsOtp,
  staticCode,
  tokenPin,
  unknown;

  bool get isSupported => this != PaymentAuthorizeVerificationMethod.unknown;
}

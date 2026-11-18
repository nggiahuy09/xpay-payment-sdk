part of 'verification_bloc.dart';

@immutable
sealed class VerificationState with Equatable {
  const VerificationState({
    required this.verification,
    required this.amount,
    this.rejection,
    this.resendFailureReason,
    this.resendCooldownUntil,
    this.code = '',
    this.isSessionOver = false,
  });

  static const int otpLength = 6;
  static const int minStaticCodeLength = 4;
  static const int maxStaticCodeLength = 6;
  static const int tokenPinLength = 6;

  final PaymentAuthorizeVerificationEntity verification;
  final VerificationRejectionEntity? rejection;
  final PaymentResendVerificationFailureReason? resendFailureReason;

  /// When the resend action becomes available again, or null when there is no cooldown running.
  ///
  /// Resolved by the bloc from the server's `can_resend_at`, falling back to a fixed client cooldown, so the view renders one deadline without knowing which
  /// source produced it.
  final DateTime? resendCooldownUntil;
  final double amount;
  final String code;

  /// Whether the flow has ended, so no code can be submitted or requested any more.
  ///
  /// Set only by [VerificationSessionExpiredState] — that is, by the session's hard deadline, never by the current code merely expiring. A code that expires inside a
  /// still-open session leaves this false, which is what keeps the resend path reachable.
  final bool isSessionOver;

  DateTime? get countdownDeadline {
    final codeExpiresAt = verification.expiresAt, sessionDeadline = verification.verificationDeadline;
    if (codeExpiresAt == null || sessionDeadline == null) return sessionDeadline ?? codeExpiresAt;
    return verification.isResendSupported || sessionDeadline.isBefore(codeExpiresAt) ? sessionDeadline : codeExpiresAt;
  }

  bool get canSubmit => !isSessionOver && !verification.isAwaitingRecipient && _isCodeComplete;

  /// Whether the resend action should be offered at all.
  ///
  /// Hidden outright for a printed code, once the per-sale cap is spent, and after a settled refusal — in each case no amount of waiting makes the action work, so
  /// leaving it on screen would only invite a guaranteed failure.
  ///
  /// Note what is deliberately *not* a condition: an expired code. That is the very situation a resend exists to recover from, so the action must stay available
  /// then. Only [isSessionOver] — the session's hard deadline — closes the action off.
  bool get canOfferResend =>
      verification.isResendSupported && !verification.isAwaitingRecipient && verification.hasResendsRemaining && !isSessionOver && !(resendFailureReason?.isFinal ?? false);

  /// Whether the resend cooldown is still running, which is what keeps the action disabled between sends.
  bool get isResendOnCooldown => resendCooldownUntil?.isAfter(DateTime.now()) ?? false;

  bool get isAwaitingRecipient => verification.isAwaitingRecipient && !isSessionOver;

  bool get canChangeRecipient => verification.hasRecipients && canOfferResend;

  bool get canSelectRecipient => verification.hasRecipients && !isSessionOver && (verification.isAwaitingRecipient || (canOfferResend && !isResendOnCooldown));

  bool get _isCodeComplete => switch (verification.method) {
    PaymentAuthorizeVerificationMethod.smsOtp => code.length == otpLength,
    PaymentAuthorizeVerificationMethod.staticCode => code.length >= minStaticCodeLength && code.length <= maxStaticCodeLength,
    PaymentAuthorizeVerificationMethod.tokenPin => code.length == tokenPinLength,
    PaymentAuthorizeVerificationMethod.unknown => false,
  };

  @override
  List<Object?> get props => [verification, rejection, resendFailureReason, resendCooldownUntil, amount, code, isSessionOver];
}

final class VerificationInitState extends VerificationState {
  const VerificationInitState({required super.verification, required super.amount, super.resendCooldownUntil});
}

final class VerificationCodeChangedState extends VerificationState {
  const VerificationCodeChangedState({
    required super.verification,
    required super.amount,
    super.rejection,
    super.resendFailureReason,
    super.resendCooldownUntil,
    required super.code,
    required super.isSessionOver,
  });
}

final class VerificationSubmitLoadingState extends VerificationState {
  const VerificationSubmitLoadingState({
    required super.verification,
    required super.amount,
    super.resendFailureReason,
    super.resendCooldownUntil,
    required super.code,
    required this.attempt,
  });

  final int attempt;

  @override
  List<Object?> get props => [...super.props, attempt];
}

final class VerificationApprovedState extends VerificationState {
  const VerificationApprovedState({required this.result, required super.verification, required super.amount, required super.code});

  final PaymentVerifyEntity result;

  @override
  List<Object?> get props => [...super.props, result];
}

final class VerificationRejectedState extends VerificationState {
  const VerificationRejectedState({
    required super.verification,
    required super.amount,
    required super.rejection,
    super.resendFailureReason,
    super.resendCooldownUntil,
    required super.code,
  });
}

final class VerificationResendCooldownEndedState extends VerificationState {
  const VerificationResendCooldownEndedState({
    required super.verification,
    required super.amount,
    super.rejection,
    super.resendFailureReason,
    required super.code,
    required super.isSessionOver,
  });
}

final class VerificationCodeExpiredState extends VerificationState {
  const VerificationCodeExpiredState({required super.verification, required super.amount, super.resendFailureReason, super.resendCooldownUntil}) : super(code: '');
}

final class VerificationResendLoadingState extends VerificationState {
  const VerificationResendLoadingState({
    required super.verification,
    required super.amount,
    super.rejection,
    super.resendCooldownUntil,
    required super.code,
    this.recipientId,
    required this.attempt,
  });

  final String? recipientId;
  final int attempt;

  bool get isSwitchingRecipient => recipientId != null;

  @override
  List<Object?> get props => [...super.props, recipientId, attempt];
}

final class VerificationRecipientPromptState extends VerificationState {
  const VerificationRecipientPromptState({required super.verification, required super.amount}) : super(code: '');
}

final class VerificationSendLoadingState extends VerificationState {
  const VerificationSendLoadingState({required super.verification, required super.amount, required this.attempt});

  final int attempt;

  @override
  List<Object?> get props => [...super.props, attempt];
}

final class VerificationCodeSentState extends VerificationState {
  const VerificationCodeSentState({required super.verification, required super.amount, super.resendCooldownUntil, required this.attempt}) : super(code: '');

  final int attempt;

  @override
  List<Object?> get props => [...super.props, attempt];
}

final class VerificationResendSentState extends VerificationState {
  const VerificationResendSentState({required super.verification, required super.amount, super.resendCooldownUntil, required this.attempt}) : super(code: '');

  final int attempt;

  @override
  List<Object?> get props => [...super.props, attempt];
}

final class VerificationResendErrorState extends VerificationState {
  const VerificationResendErrorState({
    required super.verification,
    required super.amount,
    super.rejection,
    required super.resendFailureReason,
    super.resendCooldownUntil,
    required super.code,
    this.failure,
    required this.attempt,
  });

  final XPException? failure;
  final int attempt;

  /// Non-null by construction — [VerificationState.resendFailureReason] is required on this state, so the view reads the refusal without a null check.
  PaymentResendVerificationFailureReason get reason => resendFailureReason!;

  @override
  List<Object?> get props => [...super.props, failure, attempt];
}

final class VerificationDeclinedState extends VerificationState {
  const VerificationDeclinedState({required this.result, required super.verification, required super.amount, required super.code});

  final PaymentVerifyEntity result;

  @override
  List<Object?> get props => [...super.props, result];
}

final class VerificationSessionExpiredState extends VerificationState {
  const VerificationSessionExpiredState({required super.verification, required super.amount, required super.code}) : super(isSessionOver: true);
}

final class VerificationErrorState extends VerificationState {
  const VerificationErrorState({
    required super.verification,
    required super.amount,
    super.resendFailureReason,
    super.resendCooldownUntil,
    required super.code,
    this.failure,
    required this.attempt,
  });

  final XPException? failure;
  final int attempt;

  @override
  List<Object?> get props => [...super.props, failure, attempt];
}

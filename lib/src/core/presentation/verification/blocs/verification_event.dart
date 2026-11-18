part of 'verification_bloc.dart';

@immutable
sealed class VerificationEvent {
  const VerificationEvent();
}

final class VerificationChangeCodeEvent extends VerificationEvent {
  const VerificationChangeCodeEvent(this.code);

  final String code;
}

final class VerificationSubmitEvent extends VerificationEvent {
  const VerificationSubmitEvent();
}

/// The code in the customer's hands stopped working.
///
/// Not the end of the flow: while the session deadline is still ahead the sale survives its code, so this only retires the current code and opens the resend path.
/// The bloc decides which of the two outcomes applies.
final class VerificationCodeExpiredEvent extends VerificationEvent {
  const VerificationCodeExpiredEvent();
}

/// The verification session's hard cutoff passed, which the sale does not survive.
final class VerificationDeadlinePassedEvent extends VerificationEvent {
  const VerificationDeadlinePassedEvent();
}

final class VerificationResendCodeEvent extends VerificationEvent {
  const VerificationResendCodeEvent();
}

final class VerificationSelectRecipientEvent extends VerificationEvent {
  const VerificationSelectRecipientEvent(this.recipientId);

  final String recipientId;
}

final class _VerificationPromptRecipientEvent extends VerificationEvent {
  const _VerificationPromptRecipientEvent();
}

/// Fired by the cooldown countdown when the resend action becomes available again, so the button re-enables without the view holding that timing itself.
final class VerificationResendCooldownEndedEvent extends VerificationEvent {
  const VerificationResendCooldownEndedEvent();
}

final class VerificationAbandonEvent extends VerificationEvent {
  const VerificationAbandonEvent();
}

part of 'payment_intent_bloc.dart';

@immutable
sealed class PaymentIntentEvent {
  const PaymentIntentEvent();
}

final class PaymentIntentCreateEvent extends PaymentIntentEvent {
  const PaymentIntentCreateEvent();
}

final class PaymentIntentCancelEvent extends PaymentIntentEvent {
  const PaymentIntentCancelEvent();
}

final class _PaymentIntentPollEvent extends PaymentIntentEvent {
  const _PaymentIntentPollEvent(this.intentId);

  final String intentId;
}

part of 'payment_checkout_bloc.dart';

@immutable
sealed class PaymentCheckoutEvent {
  const PaymentCheckoutEvent();
}

final class _CheckRideEvent extends PaymentCheckoutEvent {
  const _CheckRideEvent();
}

final class _PollHotlineEvent extends PaymentCheckoutEvent {
  const _PollHotlineEvent();
}

final class _HotlineTimedOutEvent extends PaymentCheckoutEvent {
  const _HotlineTimedOutEvent();
}

final class PaymentCheckoutOutcomeReportedEvent extends PaymentCheckoutEvent {
  const PaymentCheckoutOutcomeReportedEvent(this.outcome, [this.isHostCancelled = false]);

  final PaymentFlowOutcomeEntity outcome;
  final bool isHostCancelled;
}

final class PaymentCheckoutRetryPressedEvent extends PaymentCheckoutEvent {
  const PaymentCheckoutRetryPressedEvent();
}

final class PaymentCheckoutBackToPartnerPressedEvent extends PaymentCheckoutEvent {
  const PaymentCheckoutBackToPartnerPressedEvent();
}

final class PaymentCheckoutHotlineConfirmedEvent extends PaymentCheckoutEvent {
  const PaymentCheckoutHotlineConfirmedEvent();
}

final class PaymentCheckoutRetryXpayPressedEvent extends PaymentCheckoutEvent {
  const PaymentCheckoutRetryXpayPressedEvent();
}

final class PaymentCheckoutOtherMethodPressedEvent extends PaymentCheckoutEvent {
  const PaymentCheckoutOtherMethodPressedEvent();
}

final class PaymentCheckoutHotlinePayPressedEvent extends PaymentCheckoutEvent {
  const PaymentCheckoutHotlinePayPressedEvent();
}

final class PaymentCheckoutHotlineWaitLeftEvent extends PaymentCheckoutEvent {
  const PaymentCheckoutHotlineWaitLeftEvent();
}

final class PaymentCheckoutPaidDismissedEvent extends PaymentCheckoutEvent {
  const PaymentCheckoutPaidDismissedEvent(this.payment);

  final PaymentCheckoutPaymentEntity payment;
}

final class PaymentCheckoutRideClosedDismissedEvent extends PaymentCheckoutEvent {
  const PaymentCheckoutRideClosedDismissedEvent(this.settlement);

  final RideSettlement settlement;
}

final class PaymentCheckoutCancelledEvent extends PaymentCheckoutEvent {
  const PaymentCheckoutCancelledEvent([this.pendingAuthId]);

  final String? pendingAuthId;
}

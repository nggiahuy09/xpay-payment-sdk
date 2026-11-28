part of 'payment_checkout_bloc.dart';

@immutable
sealed class PaymentCheckoutState with Equatable {
  const PaymentCheckoutState({required this.method, required this.attempt});

  final PaymentMethod method;
  final int attempt;

  @override
  List<Object?> get props => [method, attempt];
}

final class PaymentCheckoutCheckingState extends PaymentCheckoutState {
  const PaymentCheckoutCheckingState(PaymentMethod method) : super(method: method, attempt: 0);
}

final class PaymentCheckoutCollectingState extends PaymentCheckoutState {
  const PaymentCheckoutCollectingState({required super.method, required super.attempt});
}

final class PaymentCheckoutSettlingState extends PaymentCheckoutState {
  const PaymentCheckoutSettlingState({required super.method, required super.attempt});
}

final class PaymentCheckoutFailedState extends PaymentCheckoutState {
  const PaymentCheckoutFailedState({required super.method, required super.attempt, required this.failure});

  final PaymentFailureEntity failure;

  @override
  List<Object?> get props => [...super.props, failure];
}

final class PaymentCheckoutOptionsState extends PaymentCheckoutState {
  const PaymentCheckoutOptionsState({required super.method, required super.attempt, required this.keepsMethod});

  final bool keepsMethod;

  @override
  List<Object?> get props => [...super.props, keepsMethod];
}

final class PaymentCheckoutHotlineWaitingState extends PaymentCheckoutState {
  const PaymentCheckoutHotlineWaitingState({required super.method, required super.attempt, required this.deadline, required this.keepsMethod});

  final DateTime deadline;
  final bool keepsMethod;

  @override
  List<Object?> get props => [...super.props, deadline, keepsMethod];
}

final class PaymentCheckoutPaidState extends PaymentCheckoutState {
  const PaymentCheckoutPaidState({required super.method, required super.attempt, required this.payment});

  final PaymentCheckoutPaymentEntity payment;

  @override
  List<Object?> get props => [...super.props, payment];
}

final class PaymentCheckoutRideClosedState extends PaymentCheckoutState {
  const PaymentCheckoutRideClosedState({required super.method, required super.attempt, required this.settlement});

  final RideSettlement settlement;

  @override
  List<Object?> get props => [...super.props, settlement];
}

final class PaymentCheckoutClosedState extends PaymentCheckoutState {
  const PaymentCheckoutClosedState({required super.method, required super.attempt, required this.result});

  final PaymentCheckoutResultEntity result;

  @override
  List<Object?> get props => [...super.props, result];
}

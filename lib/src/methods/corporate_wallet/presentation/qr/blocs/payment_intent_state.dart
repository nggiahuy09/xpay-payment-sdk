part of 'payment_intent_bloc.dart';

@immutable
sealed class PaymentIntentState with Equatable {
  const PaymentIntentState();

  bool get isCancelling => false;

  bool get isOpen => false;

  @override
  List<Object?> get props => [];
}

final class PaymentIntentInitState extends PaymentIntentState {
  const PaymentIntentInitState();
}

final class PaymentIntentCreateLoadingState extends PaymentIntentState {
  const PaymentIntentCreateLoadingState();

  @override
  bool get isOpen => true;
}

final class PaymentIntentCreateErrorState extends PaymentIntentState {
  const PaymentIntentCreateErrorState({this.errorCode, this.errorMessage});

  final String? errorCode;
  final String? errorMessage;

  @override
  List<Object?> get props => [errorCode, errorMessage];
}

final class PaymentIntentPendingState extends PaymentIntentState {
  const PaymentIntentPendingState(this.intent);

  final PaymentIntentEntity intent;

  @override
  bool get isOpen => true;

  @override
  List<Object?> get props => [intent];
}

final class PaymentIntentCapturedState extends PaymentIntentState {
  const PaymentIntentCapturedState(this.intent);

  final PaymentIntentEntity intent;

  @override
  List<Object?> get props => [intent];
}

final class PaymentIntentEndedState extends PaymentIntentState {
  const PaymentIntentEndedState(this.intent);

  final PaymentIntentEntity intent;

  @override
  List<Object?> get props => [intent];
}

final class PaymentIntentCancelLoadingState extends PaymentIntentState {
  const PaymentIntentCancelLoadingState();

  @override
  bool get isCancelling => true;
}

final class PaymentIntentCancelledState extends PaymentIntentState {
  const PaymentIntentCancelledState();
}

final class PaymentIntentCancelErrorState extends PaymentIntentState {
  const PaymentIntentCancelErrorState({this.intent, this.errorCode, this.errorMessage});

  final PaymentIntentEntity? intent;
  final String? errorCode;
  final String? errorMessage;

  @override
  bool get isOpen => true;

  @override
  List<Object?> get props => [intent, errorCode, errorMessage];
}

final class PaymentIntentFailedState extends PaymentIntentState {
  const PaymentIntentFailedState([this.errorCode]);

  final String? errorCode;

  @override
  List<Object?> get props => [errorCode];
}

part of 'xpay_payment_bloc.dart';

@immutable
sealed class XPayPaymentState with Equatable {
  const XPayPaymentState();

  @override
  List<Object?> get props => [];
}

final class XPayPaymentInitState extends XPayPaymentState {
  const XPayPaymentInitState();
}

final class XPayPaymentInvalidQrState extends XPayPaymentState {
  const XPayPaymentInvalidQrState();
}

final class XPayPaymentAuthorizingState extends XPayPaymentState {
  const XPayPaymentAuthorizingState(this.attempt);

  final int attempt;

  @override
  List<Object?> get props => [attempt];
}

final class XPayPaymentAuthorizeDoneState extends XPayPaymentState {
  const XPayPaymentAuthorizeDoneState({required this.authorize, required this.entryMode});

  final PaymentAuthorizeEntity authorize;
  final PaymentEntryMode entryMode;

  @override
  List<Object?> get props => [authorize, entryMode];
}

final class XPayPaymentAuthorizeConflictState extends XPayPaymentState {
  const XPayPaymentAuthorizeConflictState(this.attempt);

  final int attempt;

  @override
  List<Object?> get props => [attempt];
}

final class XPayPaymentAuthorizeErrorState extends XPayPaymentState {
  XPayPaymentAuthorizeErrorState({required this.entryMode, this.displayMessage, this.errorCode, required this.attempt})
    : reason = CreatePaymentAuthorizeFailureReason.fromErrorCode(errorCode);

  final PaymentEntryMode entryMode;
  final CreatePaymentAuthorizeFailureReason reason;
  final String? displayMessage;
  final String? errorCode;
  final int attempt;

  @override
  List<Object?> get props => [entryMode, reason, displayMessage, errorCode, attempt];
}

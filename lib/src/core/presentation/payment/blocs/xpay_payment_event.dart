part of 'xpay_payment_bloc.dart';

@immutable
sealed class XPayPaymentEvent {
  const XPayPaymentEvent();
}

final class XPayQrScannedEvent extends XPayPaymentEvent {
  const XPayQrScannedEvent({required this.prefix, required this.rawValue});

  final XpayQrPrefix prefix;
  final String rawValue;
}

final class XPayPanEnteredEvent extends XPayPaymentEvent {
  const XPayPanEnteredEvent(this.pan);

  final String pan;
}

final class XPayCardTappedEvent extends XPayPaymentEvent {
  const XPayCardTappedEvent({required this.chipTap, required this.cardToken});

  final PaymentChipTapEntity chipTap;
  final String cardToken;
}

final class XPayRideCardChargedEvent extends XPayPaymentEvent {
  const XPayRideCardChargedEvent(this.cardToken);

  final String cardToken;
}

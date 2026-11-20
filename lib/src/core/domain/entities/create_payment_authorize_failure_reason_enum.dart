import '../../../base/localization/localization.dart';
import 'payment_entry_mode_enum.dart';

enum CreatePaymentAuthorizeFailureReason {
  notFound,
  noRegisteredPhone,
  staticCodeUnavailable,
  otpDeliveryFailed,
  rideCardNotFound,
  rideAlreadyPaid,
  unknown;

  static CreatePaymentAuthorizeFailureReason fromErrorCode(String? value) => switch (value) {
    'not_found' => CreatePaymentAuthorizeFailureReason.notFound,
    'no_registered_phone' => CreatePaymentAuthorizeFailureReason.noRegisteredPhone,
    'static_code_unavailable' => CreatePaymentAuthorizeFailureReason.staticCodeUnavailable,
    'otp_delivery_failed' => CreatePaymentAuthorizeFailureReason.otpDeliveryFailed,
    'ride_card_not_found' => CreatePaymentAuthorizeFailureReason.rideCardNotFound,
    'ride_already_paid' => CreatePaymentAuthorizeFailureReason.rideAlreadyPaid,
    _ => CreatePaymentAuthorizeFailureReason.unknown,
  };

  String getBody(XPLocaleBase locale, PaymentEntryMode entryMode, String Function() onFallback) {
    final viewLocale = locale.payment.xpay;
    return switch (this) {
      CreatePaymentAuthorizeFailureReason.notFound => switch (entryMode) {
        PaymentEntryMode.token => viewLocale.paymentTokenNotFoundBody,
        PaymentEntryMode.manualPan => viewLocale.paymentManualPanNotFoundBody,
        PaymentEntryMode.cardQr => viewLocale.paymentCardQrNotFoundBody,
        PaymentEntryMode.chipTap => viewLocale.paymentChipTapNotFoundBody,
        PaymentEntryMode.rideCard => viewLocale.paymentRideCardNotFoundBody,
      },
      CreatePaymentAuthorizeFailureReason.noRegisteredPhone => viewLocale.paymentNoRegisteredPhoneBody,
      CreatePaymentAuthorizeFailureReason.staticCodeUnavailable => viewLocale.paymentStaticCodeUnavailableBody,
      CreatePaymentAuthorizeFailureReason.otpDeliveryFailed => viewLocale.paymentOtpDeliveryFailedBody,
      CreatePaymentAuthorizeFailureReason.rideCardNotFound => viewLocale.paymentRideCardNotFoundBody,
      CreatePaymentAuthorizeFailureReason.rideAlreadyPaid => viewLocale.paymentRideAlreadyPaidBody,
      CreatePaymentAuthorizeFailureReason.unknown => onFallback.call(),
    };
  }
}

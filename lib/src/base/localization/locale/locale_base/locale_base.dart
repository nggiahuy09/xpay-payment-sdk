part 'locale_base_payment/locale_base_payment.dart';
part 'locale_base_payment/locale_base_payment_create.dart';
part 'locale_base_payment/locale_base_payment_verification.dart';
part 'locale_base_payment/locale_base_payment_xpay.dart';
part 'locale_base_payment/locale_base_payment_xpay_decline.dart';
part 'locale_base_payment/locale_base_payment_xpay_status.dart';

part 'locale_base_shared/locale_base_shared.dart';

abstract class XPLocaleBase {
  $XPLocaleBasePayment get payment;
  $XPLocaleBaseShared get shared;
}

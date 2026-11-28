import '../../../extensions/extensions.dart';
import '../locale_base/locale_base.dart';

part 'locale_en_payment/locale_en_payment.dart';
part 'locale_en_payment/locale_en_payment_create.dart';
part 'locale_en_payment/locale_en_payment_outcome.dart';
part 'locale_en_payment/locale_en_payment_verification.dart';
part 'locale_en_payment/locale_en_payment_wallet.dart';
part 'locale_en_payment/locale_en_payment_xpay.dart';
part 'locale_en_payment/locale_en_payment_xpay_decline.dart';
part 'locale_en_payment/locale_en_payment_xpay_status.dart';

part 'locale_en_shared/locale_en_shared.dart';

final class XPLocaleEN implements XPLocaleBase {
  const XPLocaleEN();

  @override
  $XPLocaleBasePayment get payment => const $XPLocaleENPayment();

  @override
  $XPLocaleBaseShared get shared => const $XPLocaleENShared();
}

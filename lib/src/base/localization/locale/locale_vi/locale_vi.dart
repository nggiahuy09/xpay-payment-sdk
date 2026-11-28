import '../../../extensions/extensions.dart';
import '../locale_base/locale_base.dart';

part 'locale_vi_payment/locale_vi_payment.dart';
part 'locale_vi_payment/locale_vi_payment_create.dart';
part 'locale_vi_payment/locale_vi_payment_outcome.dart';
part 'locale_vi_payment/locale_vi_payment_verification.dart';
part 'locale_vi_payment/locale_vi_payment_wallet.dart';
part 'locale_vi_payment/locale_vi_payment_xpay.dart';
part 'locale_vi_payment/locale_vi_payment_xpay_decline.dart';
part 'locale_vi_payment/locale_vi_payment_xpay_status.dart';

part 'locale_vi_shared/locale_vi_shared.dart';

final class XPLocaleVI implements XPLocaleBase {
  const XPLocaleVI();

  @override
  $XPLocaleBasePayment get payment => const $XPLocaleVIPayment();

  @override
  $XPLocaleBaseShared get shared => const $XPLocaleVIShared();
}

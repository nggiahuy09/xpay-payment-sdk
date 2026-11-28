import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../payment/widgets/xpay_payment_method_tile_widget.dart';
import '../widgets/payment_checkout_scaffold_widget.dart';

final class PaymentCheckoutOptionsView extends StatelessWidget {
  const PaymentCheckoutOptionsView({
    super.key,
    required this.onBackPressed,
    required this.onHotlinePayPressed,
    required this.onOtherMethodPressed,
    required this.onRetryXpayPressed,
  });

  final void Function() onBackPressed;
  final void Function() onHotlinePayPressed;
  final void Function() onOtherMethodPressed;
  final void Function() onRetryXpayPressed;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.outcome;

    return PaymentCheckoutScaffoldWidget(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            XPTextHighlightWidget.large(viewLocale.optionsTitle),
            const SizedBox(height: 6.0),
            XPTextBodyWidget.small(viewLocale.optionsBody, color: XPColorText.subtle),
            const SizedBox(height: 24.0),
            Column(
              spacing: 12.0,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                XPayPaymentMethodTileWidget(icon: Remix.restart_line, subtitle: viewLocale.retryXpayBody, title: viewLocale.retryXpayTitle, onTap: onRetryXpayPressed),
                XPayPaymentMethodTileWidget(icon: Remix.exchange_line, subtitle: viewLocale.otherMethodBody, title: viewLocale.otherMethodTitle, onTap: onOtherMethodPressed),
                XPayPaymentMethodTileWidget(
                  icon: Remix.customer_service_2_line,
                  subtitle: viewLocale.hotlinePayBody,
                  title: viewLocale.hotlinePayTitle,
                  onTap: onHotlinePayPressed,
                ),
              ],
            ),
          ],
        ),
      ),
      onBackPressed: onBackPressed,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/helpers/helpers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/payment_order_entity.dart';
import '../widgets/payment_checkout_scaffold_widget.dart';

final class PaymentCheckoutHotlineWaitView extends StatelessWidget {
  const PaymentCheckoutHotlineWaitView({super.key, required this.order, required this.deadline, required this.onBackPressed});

  final PaymentOrderEntity order;
  final DateTime deadline;
  final void Function() onBackPressed;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.outcome;

    return PaymentCheckoutScaffoldWidget(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox.square(dimension: 52.0, child: CircularProgressIndicator(color: XPColorAction.primary, strokeWidth: 4.0)),
              const SizedBox(height: 22.0),
              XPTextHighlightWidget.medium(viewLocale.hotlineWaitTitle, textAlign: TextAlign.center),
              const SizedBox(height: 6.0),
              XPTextBodyWidget.small(viewLocale.hotlineWaitBody, color: XPColorText.subtle, textAlign: TextAlign.center),
              const SizedBox(height: 22.0),
              _PaymentCheckoutHotlineWaitRowWidget(
                label: viewLocale.hotlineWaitTimeLeftLabel,
                leading: const Icon(Remix.time_line, size: 17.0, color: XPColorIcon.primary),
                value: XPCountdownWidget(format: XPDurationFormat.minuteSecond, color: XPColorText.primary, deadline: deadline, style: XPTextStyle.highlightSmall),
              ),
              const SizedBox(height: 12.0),
              _PaymentCheckoutHotlineWaitRowWidget(
                label: locale.payment.xpay.amountToCollectLabel,
                value: XPTextHighlightWidget.small(XPHelperCurrencyFormat.format(order.amount, currency: order.currency)),
              ),
            ],
          ),
        ),
      ),
      onBackPressed: onBackPressed,
    );
  }
}

final class _PaymentCheckoutHotlineWaitRowWidget extends StatelessWidget {
  const _PaymentCheckoutHotlineWaitRowWidget({this.leading, required this.value, required this.label});

  final Widget? leading;
  final Widget value;
  final String label;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 300.0),
    child: DecoratedBox(
      decoration: const BoxDecoration(color: XPColorSurface.secondary, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded12))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
        child: Row(
          spacing: 8.0,
          children: [
            ?leading,
            Expanded(child: XPTextBodyWidget.small(label, color: XPColorText.subtle)),
            value,
          ],
        ),
      ),
    ),
  );
}

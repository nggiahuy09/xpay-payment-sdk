import 'package:flutter/material.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/payment_checkout_scaffold_widget.dart';

final class PaymentCheckoutStatusCheckView extends StatelessWidget {
  const PaymentCheckoutStatusCheckView({super.key, required this.onBackPressed});

  final void Function() onBackPressed;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.outcome;

    return PaymentCheckoutScaffoldWidget(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            spacing: 8.0,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox.square(dimension: 52.0, child: CircularProgressIndicator(color: XPColorAction.primary, strokeWidth: 4.0)),
              const SizedBox(height: 14.0),
              XPTextHighlightWidget.medium(viewLocale.statusCheckTitle, textAlign: TextAlign.center),
              XPTextBodyWidget.small(viewLocale.statusCheckBody, color: XPColorText.subtle, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      onBackPressed: onBackPressed,
    );
  }
}

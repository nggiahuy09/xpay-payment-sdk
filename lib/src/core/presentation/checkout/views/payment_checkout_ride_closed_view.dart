import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/helpers/helpers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/payment_session_entity.dart';
import '../../../domain/entities/ride_payment_status_entity.dart';
import '../widgets/payment_checkout_detail_rows_widget.dart';
import '../widgets/payment_checkout_result_header_widget.dart';
import '../widgets/payment_checkout_scaffold_widget.dart';

final class PaymentCheckoutRideClosedView extends StatelessWidget {
  const PaymentCheckoutRideClosedView({super.key, required this.session, required this.settlement, required this.onDismissed});

  final PaymentSessionEntity session;
  final RideSettlement settlement;
  final void Function() onDismissed;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.outcome;

    final order = session.order;
    final statusLabel = settlement.getLabel(locale);
    final rows = [
      PaymentCheckoutDetailRow(label: locale.payment.xpay.entryRideRefLabel, value: order.externalRef),
      if (statusLabel != null) PaymentCheckoutDetailRow(label: viewLocale.rideStatusLabel, value: statusLabel),
      PaymentCheckoutDetailRow(
        label: viewLocale.amountCollectedLabel,
        value: XPHelperCurrencyFormat.format(0, currency: order.currency),
      ),
    ];

    return PaymentCheckoutScaffoldWidget(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32.0),
            PaymentCheckoutResultHeaderWidget(
              backgroundColor: settlement.backgroundColor ?? XPColorSurface.info,
              iconColor: settlement.iconColor ?? XPColorIcon.info,
              icon: settlement.icon ?? Remix.information_line,
              body: settlement.getBody(locale),
              title: settlement.getTitle(locale) ?? viewLocale.rideCompletedTitle,
            ),
            const SizedBox(height: 24.0),
            PaymentCheckoutDetailRowsWidget(rows: rows),
          ],
        ),
      ),
      footer: XPButtonFilled.medium(label: viewLocale.backLabel, onPressed: onDismissed),
      onBackPressed: onDismissed,
    );
  }
}

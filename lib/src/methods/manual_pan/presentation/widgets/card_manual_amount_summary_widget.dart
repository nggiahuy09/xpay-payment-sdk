import 'package:flutter/material.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/helpers/helpers.dart';
import '../../../../shared/widgets/widgets.dart';

final class CardManualAmountSummaryWidget extends StatelessWidget {
  const CardManualAmountSummaryWidget({super.key, required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.create;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: XPColorSurface.secondary,
        borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          spacing: 16.0,
          children: [
            Expanded(child: XPTextBodyWidget.medium(viewLocale.manualEntryAmountLabel, color: XPColorText.subtle)),
            XPTextHeadingWidget.large(XPHelperCurrencyFormat.format(amount)),
          ],
        ),
      ),
    );
  }
}

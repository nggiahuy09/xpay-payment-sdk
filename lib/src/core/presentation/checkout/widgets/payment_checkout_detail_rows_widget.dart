import 'package:flutter/material.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../shared/widgets/widgets.dart';

final class PaymentCheckoutDetailRowsWidget extends StatelessWidget {
  const PaymentCheckoutDetailRowsWidget({super.key, required this.rows});

  final List<PaymentCheckoutDetailRow> rows;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(XPBorderRadius.rounded16)),
      border: Border.all(color: XPColorBorder.secondary),
    ),
    child: Column(
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) const XPDividerWidget.horizontal(color: XPColorBorder.secondary),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              spacing: 12.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 80.0),
                  child: XPTextBodyWidget.small(row.label, color: XPColorText.subtle),
                ),
                Expanded(child: XPTextHighlightWidget.small(row.value, textAlign: TextAlign.end)),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

@immutable
final class PaymentCheckoutDetailRow {
  const PaymentCheckoutDetailRow({required this.label, required this.value});

  final String label;
  final String value;
}

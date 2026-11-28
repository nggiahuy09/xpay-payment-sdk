import 'package:flutter/material.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../shared/widgets/widgets.dart';

final class PaymentCheckoutResultHeaderWidget extends StatelessWidget {
  const PaymentCheckoutResultHeaderWidget({super.key, required this.backgroundColor, required this.iconColor, required this.icon, this.body, required this.title});

  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final String? body;
  final String title;

  @override
  Widget build(BuildContext context) {
    final body = this.body;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          child: DecoratedBox(
            decoration: BoxDecoration(color: backgroundColor, borderRadius: const BorderRadius.all(Radius.circular(XPBorderRadius.pill))),
            child: SizedBox.square(dimension: 100.0, child: Icon(icon, size: 40.0, color: iconColor)),
          ),
        ),
        const SizedBox(height: 48.0),
        XPTextHeadingWidget.large(title, textAlign: TextAlign.center),
        if (body != null) ...[
          const SizedBox(height: 16.0),
          XPTextBodyWidget.small(body, color: XPColorText.subtle, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}

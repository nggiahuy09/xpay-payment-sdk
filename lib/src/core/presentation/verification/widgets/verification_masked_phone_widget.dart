import 'package:flutter/material.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../shared/widgets/widgets.dart';

final class VerificationMaskedPhoneWidget extends StatelessWidget {
  const VerificationMaskedPhoneWidget({super.key, required this.lastDigits});

  static const String _maskedPrefix = '•••• •••';

  final String lastDigits;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 8.0,
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      const XPTextHighlightWidget.medium(_maskedPrefix, color: XPColorText.subtle, letterSpacing: 2.0),
      XPTextHeadingWidget.large(lastDigits, letterSpacing: 1.0),
    ],
  );
}

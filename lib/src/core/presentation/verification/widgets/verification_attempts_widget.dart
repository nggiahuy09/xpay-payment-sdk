import 'package:flutter/material.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';

final class VerificationAttemptsWidget extends StatelessWidget {
  const VerificationAttemptsWidget({super.key, this.attemptsRemaining});

  final int? attemptsRemaining;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    final count = attemptsRemaining;
    if (count == null || count <= 0) return const SizedBox.shrink();
    return XPTextBodyWidget.small(viewLocale.attemptsRemaining(count), color: XPColorText.subtle);
  }
}

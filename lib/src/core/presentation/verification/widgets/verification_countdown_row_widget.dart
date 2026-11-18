import 'package:flutter/material.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';

final class VerificationCountdownRowWidget extends StatelessWidget {
  const VerificationCountdownRowWidget({super.key, this.deadline, required this.onExpired});

  final DateTime? deadline;
  final void Function() onExpired;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;
    final activeDeadline = deadline;

    if (activeDeadline == null || activeDeadline.isBefore(DateTime.now())) return XPTextBodyWidget.small(viewLocale.expired, color: XPColorText.danger);

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.0,
      children: [
        XPTextBodyWidget.small(viewLocale.expiresIn, color: XPColorText.subtle),
        XPCountdownWidget(deadline: activeDeadline, format: XPDurationFormat.minuteSecond, color: XPColorText.positive, style: XPTextStyle.highlightSmall, onFinished: onExpired),
      ],
    );
  }
}

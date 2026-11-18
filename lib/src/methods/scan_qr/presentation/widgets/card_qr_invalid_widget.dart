import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';

final class CardQrInvalidWidget extends StatelessWidget {
  const CardQrInvalidWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.xpay;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48.0),
        const Align(
          child: DecoratedBox(
            decoration: BoxDecoration(color: XPColorSurface.danger, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.pill))),
            child: SizedBox.square(dimension: 100.0, child: Icon(Remix.close_line, size: 40.0, color: XPColorIcon.negative)),
          ),
        ),
        const SizedBox(height: 48.0),
        XPTextHeadingWidget.large(viewLocale.invalidQrCodeTitle, textAlign: TextAlign.center),
        const SizedBox(height: 16.0),
        XPTextBodyWidget.small(viewLocale.invalidQrCodeBody, color: XPColorText.subtle, textAlign: TextAlign.center),
        const SizedBox(height: 32.0),
        XPButtonFilled.medium(
          backgroundColor: XPColorSurface.secondary,
          labelColor: XPColorText.defaultColor,
          label: viewLocale.gotIt,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

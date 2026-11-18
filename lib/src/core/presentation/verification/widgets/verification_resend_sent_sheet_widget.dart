import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';

final class VerificationResendSentSheetWidget extends StatelessWidget {
  const VerificationResendSentSheetWidget({super.key, required this.phoneMasked});

  final String phoneMasked;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    return Material(
      color: XPColorSurface.defaultColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 48.0, bottom: 24.0),
            child: DecoratedBox(
              decoration: BoxDecoration(color: XPColorSurface.info, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.pill))),
              child: SizedBox.square(dimension: 100.0, child: Icon(Remix.refresh_line, size: 40.0, color: XPColorIcon.info)),
            ),
          ),
          const SizedBox(height: 24.0),
          XPTextHeadingWidget.large(viewLocale.resendSentTitle, textAlign: TextAlign.center),
          const SizedBox(height: 16.0),
          XPTextBodyWidget.small(viewLocale.resendSentBody(phoneMasked), color: XPColorText.subtle, textAlign: TextAlign.center),
          const SizedBox(height: 32.0),
          XPButtonFilled.medium(label: viewLocale.resendSentButton, onPressed: () => Navigator.of(context).pop()),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

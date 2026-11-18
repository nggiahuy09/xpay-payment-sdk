import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';

final class CardNfcNotEnabledWidget extends StatelessWidget {
  const CardNfcNotEnabledWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.xpay;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32.0),
        const DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: XPColorSurface.danger),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Icon(Remix.close_line, size: 40.0, color: XPColorIcon.negative),
          ),
        ),
        const SizedBox(height: 32.0),
        XPTextHighlightWidget.large(viewLocale.nfcNotEnabledTitle, color: XPColorText.inversed, textAlign: TextAlign.center),
        const SizedBox(height: 8.0),
        XPTextBodyWidget.small(viewLocale.nfcNotEnabledBody, color: XPColorText.inversed, textAlign: TextAlign.center),
        if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) ...[
          const SizedBox(height: 24.0),
          XPButtonFilled.medium(
            backgroundColor: XPColorSurface.secondary,
            labelColor: XPColorText.defaultColor,
            label: viewLocale.openSettings,
            onPressed: () {
              if (defaultTargetPlatform == TargetPlatform.android) {
                AppSettings.openAppSettings(type: AppSettingsType.nfc, asAnotherTask: true);
              } else {
                AppSettings.openAppSettings(type: AppSettingsType.settings, asAnotherTask: true);
              }
            },
          ),
        ],
      ],
    );
  }
}

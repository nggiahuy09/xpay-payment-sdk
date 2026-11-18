import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';

final class CameraPermissionBlockedWidget extends StatelessWidget {
  const CameraPermissionBlockedWidget({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.xpay;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24.0,
        children: [
          const Icon(Remix.camera_off_line, size: 44.0, color: XPColorIcon.inversed),
          Column(
            spacing: 8.0,
            children: [
              XPTextHeadingWidget.large(viewLocale.cameraPermissionRequiredTitle, color: XPColorText.inversed, textAlign: TextAlign.center),
              XPTextBodyWidget.medium(viewLocale.cameraPermissionRequiredBody, color: XPColorText.inversed, textAlign: TextAlign.center),
            ],
          ),
          XPButtonFilled.medium(
            backgroundColor: XPColorSurface.secondary,
            labelColor: XPColorText.defaultColor,
            label: viewLocale.openSettings,
            onPressed: () => onOpenSettings.call(),
          ),
        ],
      ),
    );
  }
}

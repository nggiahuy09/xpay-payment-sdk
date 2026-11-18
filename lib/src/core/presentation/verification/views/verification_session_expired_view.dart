import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/views/views.dart';
import '../../../../shared/widgets/widgets.dart';

final class VerificationSessionExpiredView extends StatelessWidget {
  const VerificationSessionExpiredView({super.key, this.exitLabel, required this.onExit});

  final String? exitLabel;
  final void Function() onExit;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        onExit.call();
      },
      child: Scaffold(
        backgroundColor: XPColorSurface.defaultColor,
        body: XPPlatformSafeAreaView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: XPColorSurface.danger, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.pill))),
                    child: SizedBox.square(dimension: 100.0, child: Icon(Remix.time_line, size: 40.0, color: XPColorIcon.negative)),
                  ),
                ),
                const SizedBox(height: 48.0),
                XPTextHeadingWidget.large(viewLocale.sessionExpiredTitle, textAlign: TextAlign.center),
                const SizedBox(height: 16.0),
                XPTextBodyWidget.small(viewLocale.sessionExpiredBody, color: XPColorText.subtle, textAlign: TextAlign.center),
                const SizedBox(height: 32.0),
                XPButtonFilled.medium(
                  leadingIcon: const Icon(Remix.arrow_left_line, size: 20.0, color: XPColorIcon.inversed),
                  label: exitLabel ?? viewLocale.backToHomeButton,
                  onPressed: onExit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

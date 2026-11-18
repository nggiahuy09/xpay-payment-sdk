import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';

/// Warns that backing out of the code screen leaves the payment uncollected, before the pop is allowed through.
///
/// Shown because leaving is silently lossy: the authorization is already booked, so the payment parks in `pending_verification` with no money taken and
/// nothing on screen to say so. The copy names that outcome and points at the details screen, where the session can be picked back up.
///
/// [onLeave] fires after this sheet has dismissed itself, so the caller performs the pop it was blocking without reaching across this route.
final class VerificationAbandonSheetWidget extends StatelessWidget {
  const VerificationAbandonSheetWidget({super.key, required this.onLeave});

  final void Function() onLeave;

  void _handleLeave(BuildContext context) {
    Navigator.of(context).pop();
    onLeave.call();
  }

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48.0),
        const Align(
          child: DecoratedBox(
            decoration: BoxDecoration(color: XPColorSurface.warning, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.pill))),
            child: SizedBox.square(dimension: 100.0, child: Icon(Remix.error_warning_line, size: 40.0, color: XPColorIcon.warning)),
          ),
        ),
        const SizedBox(height: 48.0),
        XPTextHeadingWidget.large(viewLocale.abandonSheetTitle, textAlign: TextAlign.center),
        const SizedBox(height: 16.0),
        XPTextBodyWidget.small(viewLocale.abandonSheetBody, color: XPColorText.subtle, textAlign: TextAlign.center),
        const SizedBox(height: 32.0),
        Column(
          spacing: 12.0,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            XPButtonFilled.medium(label: viewLocale.abandonStayButton, onPressed: Navigator.of(context).pop),
            XPButtonFilled.medium(
              backgroundColor: XPColorSurface.secondary,
              labelColor: XPColorText.defaultColor,
              label: viewLocale.abandonLeaveButton,
              onPressed: () => _handleLeave(context),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}

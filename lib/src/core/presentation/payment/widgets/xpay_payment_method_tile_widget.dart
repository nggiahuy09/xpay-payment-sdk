import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../shared/widgets/widgets.dart';

final class XPayPaymentMethodTileWidget extends StatelessWidget {
  const XPayPaymentMethodTileWidget({super.key, required this.icon, this.subtitle, required this.title, required this.onTap});

  final IconData icon;
  final String? subtitle;
  final String title;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) => XPListItemWidget.general(
    leading: DecoratedBox(
      decoration: const BoxDecoration(color: XPColorAction.primary, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded12))),
      child: SizedBox.square(dimension: 48.0, child: Icon(icon, size: 24.0, color: XPColorIcon.inversed)),
    ),
    trailing: const Icon(Remix.arrow_right_s_line, size: 24.0, color: XPColorIcon.primary),
    borderColor: XPColorBorder.secondary,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    titleStyle: XPTextStyle.highlightMedium,
    subtitle: subtitle,
    title: title,
    borderRadius: XPBorderRadius.rounded16,
    borderWidth: 1.0,
    contentGap: 0.0,
    leadingGap: 12.0,
    subtitleMaxLines: 2,
    onTap: onTap,
  );
}

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../base/define/constant/constant.dart';

final class XPInlineMessageWidget extends StatelessWidget {
  const XPInlineMessageWidget.neutral({
    super.key,
    this.icon,
    this.trailingIcon,
    this.titleStyle,
    this.bodyStyle,
    required this.title,
    this.body,
    this.borderRadius = XPBorderRadius.rounded10,
    this.matchingBorder = true,
    this.matchingTextColor = true,
  }) : level = XPInlineMessageLevel.neutral;

  const XPInlineMessageWidget.positive({
    super.key,
    this.icon,
    this.trailingIcon,
    this.titleStyle,
    this.bodyStyle,
    required this.title,
    this.body,
    this.borderRadius = XPBorderRadius.rounded10,
    this.matchingBorder = true,
    this.matchingTextColor = true,
  }) : level = XPInlineMessageLevel.positive;

  const XPInlineMessageWidget.warning({
    super.key,
    this.icon,
    this.trailingIcon,
    this.titleStyle,
    this.bodyStyle,
    required this.title,
    this.body,
    this.borderRadius = XPBorderRadius.rounded10,
    this.matchingBorder = true,
    this.matchingTextColor = true,
  }) : level = XPInlineMessageLevel.warning;

  const XPInlineMessageWidget.danger({
    super.key,
    this.icon,
    this.trailingIcon,
    this.titleStyle,
    this.bodyStyle,
    required this.title,
    this.body,
    this.borderRadius = XPBorderRadius.rounded10,
    this.matchingBorder = true,
    this.matchingTextColor = true,
  }) : level = XPInlineMessageLevel.danger;

  const XPInlineMessageWidget.info({
    super.key,
    this.icon,
    this.trailingIcon,
    this.titleStyle,
    this.bodyStyle,
    required this.title,
    this.body,
    this.borderRadius = XPBorderRadius.rounded10,
    this.matchingBorder = true,
    this.matchingTextColor = true,
  }) : level = XPInlineMessageLevel.info;

  const XPInlineMessageWidget.safe({
    super.key,
    this.icon,
    this.trailingIcon,
    this.titleStyle,
    this.bodyStyle,
    required this.title,
    this.body,
    this.borderRadius = XPBorderRadius.rounded10,
    this.matchingBorder = true,
    this.matchingTextColor = true,
  }) : level = XPInlineMessageLevel.safe;

  final XPInlineMessageLevel level;
  final IconData? icon;
  final Widget? trailingIcon;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;
  final String title;
  final String? body;
  final double borderRadius;
  final bool matchingBorder;
  final bool matchingTextColor;

  @override
  Widget build(BuildContext context) {
    final textColor = matchingTextColor ? level.textColor : XPColorText.defaultColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: level.backgroundColor,
        border: matchingBorder ? Border.all(color: level.borderColor) : null,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          spacing: 12.0,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Icon(icon ?? level.icon, color: level.iconColor, size: 20.0),
            Expanded(
              child: Column(
                spacing: 4.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: (titleStyle ?? XPTextStyle.highlightSmall).copyWith(color: textColor)),
                  if (body != null) Text(body!, style: (bodyStyle ?? XPTextStyle.bodyExtraSmall).copyWith(color: textColor)),
                ],
              ),
            ),
            ?trailingIcon,
          ],
        ),
      ),
    );
  }
}

enum XPInlineMessageLevel {
  neutral(XPColorSurface.secondary, XPColorBorder.defaultColor, XPColorIcon.defaultColor, XPColorText.defaultColor, Remix.information_line),
  positive(XPColorSurface.success, XPColorBorder.positive, XPColorIcon.success, XPColorText.positive, Remix.check_line),
  warning(XPColorSurface.warning, XPColorBorder.warning, XPColorIcon.warning, XPColorText.warning, Remix.alert_line),
  danger(XPColorSurface.danger, XPColorBorder.negative, XPColorIcon.negative, XPColorText.negative, Remix.error_warning_line),
  info(XPColorSurface.info, XPColorBorder.info, XPColorIcon.info, XPColorText.info, Remix.information_line),
  safe(XPColorSurface.secondary, XPColorBorder.defaultColor, XPColorIcon.primary, XPColorText.defaultColor, Remix.shield_keyhole_line);

  const XPInlineMessageLevel(this.backgroundColor, this.borderColor, this.iconColor, this.textColor, this.icon);

  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
}

import 'package:flutter/material.dart';

import '../../../base/define/constant/constant.dart';

class XPButtonIcon extends StatelessWidget {
  /// Named constructor for outlined button icon
  const XPButtonIcon.outlined({
    super.key,
    this.shadow,
    this.backgroundColor = XPColorSurface.defaultColor,
    this.borderColor = XPColorBorder.defaultColor,
    required this.icon,
    this.iconColor = XPColorIcon.subtle,
    this.borderRadius = XPBorderRadius.pill,
    this.height = 48.0,
    this.iconSize,
    this.width = 48.0,
    this.onPressed,
  }) : borderWidth = 1.0;

  /// Named constructor for non-outlined button icon.
  /// [wrapIcon] - if set to true, button size will match icon size, unless unspecified.
  const XPButtonIcon.noOutline({
    super.key,
    this.shadow,
    this.backgroundColor = Colors.transparent,
    required this.icon,
    this.iconColor = XPColorIcon.subtle,
    this.borderRadius = XPBorderRadius.pill,
    double height = 48.0,
    this.iconSize,
    double width = 48.0,
    bool wrapIcon = true,
    this.onPressed,
  }) : width = wrapIcon ? iconSize ?? width : width,
       height = wrapIcon ? iconSize ?? height : height,
       borderWidth = 0,
       borderColor = Colors.transparent;

  final List<BoxShadow>? shadow;
  final Color? backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color? iconColor;
  final double borderRadius;
  final double borderWidth;
  final double? height;
  final double? iconSize;
  final double? width;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          border: Border.all(width: borderWidth, color: borderColor),
          boxShadow: shadow ?? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), offset: const Offset(0, 2), blurRadius: 40.0)],
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}

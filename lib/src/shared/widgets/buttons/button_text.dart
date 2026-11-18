import 'package:flutter/material.dart';

import '../../../base/define/constant/constant.dart';
import '../widgets.dart';

class XPTextButton extends StatelessWidget {
  /// Named constructor for large button (height: 52).
  const XPTextButton.large({
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.labelColor,
    this.overlayColor,
    required this.label,
    this.borderRadius = XPBorderRadius.rounded16,
    this.iconGap = 8.0,
    this.expanded = true,
    this.loading = false,
    this.onPressed,
  }) : _preset = _XPTextButtonPreset.large,
       minimumSize = expanded ? const Size.fromHeight(52) : const Size(double.minPositive, 52);

  /// Named constructor for medium button (height: 44).
  const XPTextButton.medium({
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.labelColor,
    this.overlayColor,
    required this.label,
    this.borderRadius = XPBorderRadius.rounded16,
    this.iconGap = 8.0,
    this.expanded = true,
    this.loading = false,
    this.onPressed,
  }) : _preset = _XPTextButtonPreset.medium,
       minimumSize = expanded ? const Size.fromHeight(40) : const Size(double.minPositive, 40);

  /// Named constructor for small button (height: 32).
  const XPTextButton.small({
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.labelColor,
    this.overlayColor,
    required this.label,
    this.borderRadius = XPBorderRadius.rounded16,
    this.iconGap = 8.0,
    this.expanded = true,
    this.loading = false,
    this.onPressed,
  }) : _preset = _XPTextButtonPreset.small,
       minimumSize = expanded ? const Size.fromHeight(32) : const Size(double.minPositive, 32);

  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final _XPTextButtonPreset _preset;
  final EdgeInsetsGeometry? contentPadding;
  final Color? labelColor;
  final Size minimumSize;
  final Color? overlayColor;
  final String label;
  final double borderRadius;
  final double iconGap;

  /// Expand this button to fill the width of the parent.
  /// Set to false to avoid overflow when using in a Row widget, without wrapping inside a [Flexible] widget.
  final bool expanded;
  final bool loading;
  final void Function()? onPressed;

  Widget _labelWidget(Color textColor) {
    return switch (_preset) {
      _XPTextButtonPreset.small => XPTextHighlightWidget.small(label, color: textColor),
      _XPTextButtonPreset.medium => XPTextHighlightWidget.medium(label, color: textColor),
      _XPTextButtonPreset.large => XPTextHighlightWidget.medium(label, color: textColor),
    };
  }

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget;
    final textColor = loading ? XPColorText.disabled : (labelColor ?? XPColorText.primary);

    if (loading == true) {
      loadingWidget = const CircularProgressIndicator(
        color: XPColorIcon.subtle,
        strokeWidth: 3,
        constraints: BoxConstraints(minWidth: 18, minHeight: 18),
      );
    } else {
      loadingWidget = const SizedBox.shrink();
    }

    return TextButton(
      onPressed: loading == true ? null : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: XPColorAction.primary,
        disabledBackgroundColor: Colors.transparent,
        shadowColor: XPColorShadow.reversedTheme20,
        overlayColor: overlayColor ?? XPColorAction.primary,
        minimumSize: minimumSize,
        padding: contentPadding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // To avoid unwanted margin if button height is below 48.0
      ),
      child: Row(
        spacing: iconGap,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading == true) loadingWidget,
          ?leadingIcon,
          _labelWidget(textColor),
          ?trailingIcon,
        ],
      ),
    );
  }
}

enum _XPTextButtonPreset { large, medium, small }

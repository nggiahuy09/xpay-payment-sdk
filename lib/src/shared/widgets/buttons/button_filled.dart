import 'package:flutter/material.dart';

import '../../../base/define/constant/constant.dart';
import '../text/text_widgets.dart';

class XPButtonFilled extends StatelessWidget {
  /// Large button (height: 48)
  const XPButtonFilled.large({
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.labelColor,
    this.labelTextStyle,
    this.overlayColor,
    required this.label,
    this.borderRadius = XPBorderRadius.rounded10,
    this.iconGap = 8,
    this.labelMaxLines = 1,
    this.enabled = true,
    this.expanded = true,
    this.loading = false,
    this.onPressed,
  }) : _preset = _XPButtonFilledPreset.large,
       minimumSize = expanded ? const Size.fromHeight(48) : const Size(double.minPositive, 48);

  /// Medium button (height: 40)
  const XPButtonFilled.medium({
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.labelColor,
    this.labelTextStyle,
    this.overlayColor,
    required this.label,
    this.borderRadius = XPBorderRadius.rounded10,
    this.iconGap = 8,
    this.labelMaxLines = 1,
    this.enabled = true,
    this.expanded = true,
    this.loading = false,
    this.onPressed,
  }) : _preset = _XPButtonFilledPreset.medium,
       minimumSize = expanded ? const Size.fromHeight(40) : const Size(double.minPositive, 40);

  /// Small button (height: 32)
  const XPButtonFilled.small({
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.labelColor,
    this.labelTextStyle,
    this.overlayColor,
    required this.label,
    this.borderRadius = XPBorderRadius.rounded10,
    this.iconGap = 8,
    this.labelMaxLines = 1,
    this.enabled = true,
    this.expanded = true,
    this.loading = false,
    this.onPressed,
  }) : _preset = _XPButtonFilledPreset.small,
       minimumSize = expanded ? const Size.fromHeight(32) : const Size(double.minPositive, 32);

  /// Tiny button (height: 24)
  const XPButtonFilled.tiny({
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.labelColor,
    this.labelTextStyle,
    this.overlayColor,
    required this.label,
    this.borderRadius = XPBorderRadius.rounded10,
    this.iconGap = 8,
    this.labelMaxLines = 1,
    this.enabled = true,
    this.expanded = false,
    this.loading = false,
    this.onPressed,
  }) : minimumSize = expanded ? const Size.fromHeight(24) : const Size(double.minPositive, 24),
       _preset = _XPButtonFilledPreset.tiny;

  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final _XPButtonFilledPreset _preset;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? contentPadding;
  final Color? labelColor;
  final TextStyle? labelTextStyle;
  final Size minimumSize;
  final Color? overlayColor;
  final String label;
  final double borderRadius;
  final double iconGap;
  final int labelMaxLines;
  final bool enabled;
  final bool expanded;
  final bool loading;
  final void Function()? onPressed;

  Widget _labelWidget(Color textColor) {
    return switch (_preset) {
      _XPButtonFilledPreset.tiny => XPTextHighlightWidget.extraSmall(label, color: textColor, maxLines: labelMaxLines),
      _XPButtonFilledPreset.small => XPTextHighlightWidget.extraSmall(label, color: textColor, maxLines: labelMaxLines),
      _XPButtonFilledPreset.medium => XPTextHighlightWidget.small(label, color: textColor, maxLines: labelMaxLines),
      _XPButtonFilledPreset.large => XPTextHighlightWidget.medium(label, color: textColor, maxLines: labelMaxLines),
    };
  }

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget;
    final disabled = loading || !enabled;

    final textColor = disabled ? XPColorText.disabled : (labelColor ?? XPColorText.inversed);

    if (loading == true) {
      loadingWidget = const CircularProgressIndicator(color: XPColorIcon.subtle, strokeWidth: 3, constraints: BoxConstraints(minWidth: 18, minHeight: 18));
    } else {
      loadingWidget = const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0.0,
        backgroundColor: backgroundColor ?? XPColorAction.primary,
        disabledBackgroundColor: XPColorSurface.disabled,
        shadowColor: XPColorShadow.reversedTheme20,
        minimumSize: minimumSize,
        padding: contentPadding,
        overlayColor: overlayColor ?? XPColorAction.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // To avoid unwanted margin if button height is below 48.0
      ),
      child: Row(
        spacing: iconGap,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading == true) loadingWidget else ?leadingIcon,
          Flexible(
            child: labelTextStyle != null
                ? Text(
                    label,
                    style: labelTextStyle!.copyWith(color: textColor),
                    maxLines: labelMaxLines,
                  )
                : _labelWidget(textColor),
          ),
          ?trailingIcon,
        ],
      ),
    );
  }
}

enum _XPButtonFilledPreset { large, medium, small, tiny }

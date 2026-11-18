part of 'list_item_widget.dart';

final class _XPListItemSelectableRadioWidget extends XPListItemWidget {
  const _XPListItemSelectableRadioWidget({
    super.key,
    this.activeBorderColor,
    this.activeRadioColor,
    this.backgroundColor,
    this.bottomContent,
    required this.content,
    this.inactiveBorderColor,
    this.overlayColor,
    super.padding = const EdgeInsets.all(16.0),
    this.borderRadius,
    this.borderWidth,
    this.bottomContentGap,
    this.borderless = false,
    this.centerRadio = false,
    super.expandContent = false,
    required this.selected,
    required void Function() super.onTap,
  });

  final Color? activeBorderColor;
  final Color? activeRadioColor;
  final Color? backgroundColor;
  final Widget? bottomContent;
  final Widget content;
  final Color? inactiveBorderColor;
  final Color? overlayColor;
  final double? borderRadius;
  final double? borderWidth;
  final double? bottomContentGap;
  final bool borderless;
  final bool centerRadio;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    Widget contentView = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centerRadio ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        expandContent ? Expanded(child: content) : Flexible(child: content),
        XPRadioIconWidget(isSelected: selected, selectedColor: activeRadioColor ?? XPColorIcon.primary),
      ],
    );
    if (bottomContent != null) {
      contentView = Column(
        spacing: bottomContentGap ?? 0.0,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [contentView, bottomContent!],
      );
    }
    return Material(
      color: backgroundColor ?? XPColorSurface.defaultColor,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? XPBorderRadius.rounded10)),
        side: borderless
            ? const BorderSide(color: Colors.transparent, width: 0.0)
            : BorderSide(
                color: selected ? activeBorderColor ?? XPColorBorder.primary : inactiveBorderColor ?? XPColorBorder.defaultColor,
                width: borderWidth ?? 1.0,
              ),
      ),
      child: InkWell(
        overlayColor: WidgetStatePropertyAll<Color?>(overlayColor ?? XPColorOverlay.reverseTheme03),
        onTap: onTap,
        child: Padding(padding: padding, child: contentView),
      ),
    );
  }
}

part of 'list_item_widget.dart';

final class _XPListItemGeneralWidget extends XPListItemWidget {
  const _XPListItemGeneralWidget({
    super.key,
    this.shadow,
    this.backgroundColor,
    this.borderColor,
    this.leading,
    this.subtitleColor = XPColorText.subtle,
    this.subtitleStyle,
    this.titleColor = XPColorText.defaultColor,
    this.titleStyle,
    this.trailing,
    this.contentVerticalAlignment = CrossAxisAlignment.center,
    this.textBaseline,
    super.padding = EdgeInsets.zero,
    this.subtitle,
    required this.title,
    this.borderRadius = XPBorderRadius.square,
    this.borderWidth,
    this.contentGap = 4.0,
    this.leadingGap = 8.0,
    this.trailingGap = 8.0,
    this.subtitleMaxLines,
    this.titleMaxLines,
    super.expandContent = true,
    super.onTap,
  });

  final List<BoxShadow>? shadow;
  final Color? backgroundColor;
  final Color? borderColor;
  final Widget? leading;
  final Color subtitleColor;
  final TextStyle? subtitleStyle;
  final Color titleColor;
  final TextStyle? titleStyle;
  final Widget? trailing;
  final CrossAxisAlignment contentVerticalAlignment;
  final TextBaseline? textBaseline;
  final String? subtitle;
  final String title;
  final double borderRadius;
  final double? borderWidth;
  final double contentGap;
  final double leadingGap;
  final double trailingGap;
  final int? subtitleMaxLines;
  final int? titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final mergedTitleStyle = (titleStyle ?? XPTextStyle.bodySmall).copyWith(color: titleColor);
    final mergedSubtitleStyle = (subtitleStyle ?? XPTextStyle.bodyExtraSmall).copyWith(color: subtitleColor);

    Widget contentView = Text(title, style: mergedTitleStyle, maxLines: titleMaxLines ?? 1, overflow: TextOverflow.ellipsis);
    if (subtitle != null) {
      contentView = Column(
        spacing: contentGap,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          contentView,
          Text(subtitle!, style: mergedSubtitleStyle, maxLines: subtitleMaxLines ?? 1, overflow: TextOverflow.ellipsis),
        ],
      );
    }
    contentView = expandContent ? Expanded(child: contentView) : Flexible(child: contentView);

    Widget layoutContent = Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: expandContent ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        crossAxisAlignment: contentVerticalAlignment,
        textBaseline: textBaseline,
        children: [
          if (leading != null) ...[leading!, SizedBox(width: leadingGap)],
          contentView,
          if (trailing != null) ...[SizedBox(width: trailingGap), trailing!],
        ],
      ),
    );

    if (onTap != null) {
      layoutContent = Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          overlayColor: const WidgetStatePropertyAll<Color?>(XPColorOverlay.reverseTheme03),
          onTap: onTap,
          child: layoutContent,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        border: Border.all(color: borderColor ?? Colors.transparent, width: borderWidth ?? 0.0),
        boxShadow: shadow,
      ),
      child: layoutContent,
    );
  }
}

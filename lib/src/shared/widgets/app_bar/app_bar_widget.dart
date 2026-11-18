import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../base/define/constant/constant.dart';
import '../text/text_widgets.dart';

class XPAppBarWidget extends StatelessWidget {
  const XPAppBarWidget({
    super.key,
    this.actions,
    this.leading,
    this.titleWidget,
    this.actionPadding,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.surfaceTintColor,
    this.titleLabel = '',
    this.centerTitle = false,
    this.showBackButton = true,
    this.onBackPressed,
  });

  final List<Widget>? actions;
  final Widget? leading;
  final Widget? titleWidget;
  final EdgeInsets? actionPadding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;

  /// This is the color of the app bar if the scaffold body is scroll.
  final Color? surfaceTintColor;
  final String titleLabel;
  final bool centerTitle;

  /// If true, the back button will be shown. Default is true.
  final bool showBackButton;
  final void Function()? onBackPressed;

  Widget get _defaultTitleWidget => Padding(
    padding: showBackButton ? EdgeInsets.zero : const EdgeInsets.only(left: 8.0),
    child: XPTextHeadingWidget.large(titleLabel),
  );

  Widget _defaultLeadingWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBackPressed ?? () => Navigator.of(context).pop(),
          child: const Padding(
            padding: EdgeInsets.all(6.0),
            child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded12)), color: XPColorSurface.state),
              child: SizedBox.square(dimension: 36.0, child: Icon(Remix.arrow_left_line, size: 24.0, color: XPColorIcon.defaultColor)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleWidget = this.titleWidget ?? _defaultTitleWidget;
    final leadingWidget = leading ?? (showBackButton ? _defaultLeadingWidget(context) : null);

    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor ?? XPColorSurface.defaultColor, boxShadow: null),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: AppBar(
          title: titleWidget,
          leading: leadingWidget,
          actions: actions,
          centerTitle: centerTitle,
          backgroundColor: backgroundColor ?? XPColorSurface.defaultColor,
          surfaceTintColor: surfaceTintColor ?? XPColorSurface.defaultColor,
          foregroundColor: foregroundColor,
          elevation: 0.0,
          titleSpacing: 12.0,
          leadingWidth: 64.0,
          automaticallyImplyLeading: showBackButton,
          actionsPadding: actionPadding,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../base/define/constant/constant.dart';
import '../radio_button/radio_icon_widget.dart';

part 'list_item_general_widget.dart';

part 'list_item_selectable_radio_widget.dart';

/// Abstract base class for list item widgets following OOP pattern.
///
/// This is a widget family exposing multiple variants via factory constructors:
/// - [XPListItemWidget.basic] shows a basic list item with title, subtitle, leading and trailing widgets.
/// - [XPListItemWidget.selectableRadio] shows a selectable list item with radio button and optional bottom content.
abstract base class XPListItemWidget extends StatelessWidget {
  const XPListItemWidget({super.key, this.padding = EdgeInsets.zero, this.expandContent = false, this.onTap});

  /// Basic list item with leading and trailing widgets.
  const factory XPListItemWidget.general({
    Key? key,
    List<BoxShadow>? shadow,
    Widget? leading,
    Widget? trailing,
    CrossAxisAlignment contentVerticalAlignment,
    TextBaseline? textBaseline,
    Color? backgroundColor,
    Color? borderColor,
    EdgeInsetsGeometry padding,
    Color subtitleColor,
    TextStyle? subtitleStyle,
    Color titleColor,
    TextStyle? titleStyle,
    String? subtitle,
    required String title,
    double borderRadius,
    double? borderWidth,
    double contentGap,
    double leadingGap,
    double trailingGap,
    int? subtitleMaxLines,
    int? titleMaxLines,
    bool expandContent,
    void Function()? onTap,
  }) = _XPListItemGeneralWidget;

  /// Selectable list item with radio button and optional bottom content.
  const factory XPListItemWidget.selectableRadio({
    Key? key,
    Widget? bottomContent,
    required Widget content,
    Color? activeBorderColor,
    Color? activeRadioColor,
    Color? backgroundColor,
    Color? inactiveBorderColor,
    Color? overlayColor,
    EdgeInsetsGeometry padding,
    double? borderRadius,
    double? borderWidth,
    double? bottomContentGap,
    bool borderless,
    bool centerRadio,
    bool expandContent,
    required bool selected,
    required void Function() onTap,
  }) = _XPListItemSelectableRadioWidget;

  /// Content padding.
  final EdgeInsetsGeometry padding;
  final bool expandContent;
  final void Function()? onTap;
}

import 'package:flutter/material.dart';

import '../../../base/define/constant/color/color_semantic.dart';

abstract base class XPDividerWidget extends StatelessWidget {
  const XPDividerWidget({super.key, this.color, this.leftMargin, this.rightMargin, this.topMargin, this.bottomMargin, this.height});

  const factory XPDividerWidget.horizontal({Key? key, Color? color, double? leftMargin, double? rightMargin, double? topMargin, double? bottomMargin, double? height}) =
      _XPHorizontalDividerWidget;

  const factory XPDividerWidget.vertical({
    Key? key,
    Color? color,
    double? leftMargin,
    double? rightMargin,
    double? topMargin,
    double? bottomMargin,
    double? height,
    double? width,
  }) = _XPVerticalDividerWidget;

  final Color? color;
  final double? leftMargin;
  final double? rightMargin;
  final double? topMargin;
  final double? bottomMargin;
  final double? height;
}

final class _XPHorizontalDividerWidget extends XPDividerWidget {
  const _XPHorizontalDividerWidget({super.key, super.color, super.leftMargin = 0.0, super.rightMargin = 0.0, super.topMargin = 0.0, super.bottomMargin = 0.0, super.height = 1.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftMargin ?? 0, right: rightMargin ?? 0, top: topMargin ?? 0, bottom: bottomMargin ?? 0),
      child: SizedBox(
        height: height,
        width: 99999,
        child: DecoratedBox(decoration: BoxDecoration(color: color ?? XPColorBorder.secondary)),
      ),
    );
  }
}

final class _XPVerticalDividerWidget extends XPDividerWidget {
  const _XPVerticalDividerWidget({
    super.key,
    super.color,
    super.leftMargin = 0.0,
    super.rightMargin = 0.0,
    super.topMargin = 0.0,
    super.bottomMargin = 0.0,
    super.height = 1.0,
    this.width = 1.0,
  });

  final double? width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftMargin ?? 0, right: rightMargin ?? 0, top: topMargin ?? 0, bottom: bottomMargin ?? 0),
      child: DecoratedBox(
        decoration: BoxDecoration(color: color ?? XPColorBorder.secondary),
        child: SizedBox(height: height, width: width ?? 1.0),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../base/define/constant/constant.dart';
import '../widgets/widgets.dart';

class XPModalHeaderSectionWidget extends StatelessWidget {
  const XPModalHeaderSectionWidget({super.key, this.content, required this.leadingIcon, this.padding, required this.label, this.gap = 0.0});

  final Widget? content;
  final IconData leadingIcon;
  final EdgeInsetsGeometry? padding;
  final String label;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: gap,
      children: [
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(leadingIcon, size: 24.0, color: XPColorAction.primary),
              const SizedBox(width: 8.0),
              Flexible(child: XPTextHighlightWidget.medium(label, color: XPColorText.primary)),
            ],
          ),
        ),
        content ?? const SizedBox.shrink(),
      ],
    );
  }
}

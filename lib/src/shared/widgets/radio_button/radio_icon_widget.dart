import 'package:flutter/material.dart';

import '../../../base/define/constant/constant.dart';

class XPRadioIconWidget extends StatelessWidget {
  const XPRadioIconWidget({super.key, this.selectedColor, this.isEnabled = true, required this.isSelected});

  final Color? selectedColor;
  final bool isEnabled;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isEnabled ? selectedColor ?? XPColorAction.primary : XPColorBorder.defaultColor;

    return SizedBox(
      width: 20.0,
      height: 20.0,
      child: isSelected
          ? DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: effectiveColor),
              child: const Icon(Icons.check, size: 14.0, color: Colors.white),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: XPColorBorder.defaultColor, width: 2.0),
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../base/define/constant/constant.dart';

final class VerificationIconWidget extends StatelessWidget {
  const VerificationIconWidget({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: XPColorSurface.success,
      borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded16)),
    ),
    child: SizedBox.square(dimension: 56.0, child: Icon(icon, size: 28.0, color: XPColorIcon.success)),
  );
}

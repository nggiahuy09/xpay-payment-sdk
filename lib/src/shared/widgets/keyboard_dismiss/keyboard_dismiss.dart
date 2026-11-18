import 'package:flutter/material.dart';

class XPKeyboardDismissOnTap extends StatelessWidget {
  const XPKeyboardDismissOnTap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        // Use this because the old method focuses back when back from a navigation route.
        FocusManager.instance.primaryFocus?.unfocus();
        // Lấy widget hiện đang focus
        // final currentFocus = FocusScope.of(context);
        // if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        //   // Unfocus khi tap ra vùng trống
        //   currentFocus.unfocus();
        // }
      },
      child: child,
    );
  }
}

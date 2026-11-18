import 'package:flutter/painting.dart';

import '../color/color_semantic.dart';

final class XPBoxShadow {
  const XPBoxShadow._();

  static List<BoxShadow> glow(Color color) => [BoxShadow(offset: const Offset(0.0, 12.0), blurRadius: 24.0, spreadRadius: -8.0, color: color.withValues(alpha: 0.4))];

  /// Used for: surface container, card.
  static const List<BoxShadow> surfaceContainerCard = [
    BoxShadow(offset: Offset(0, 0), blurRadius: 1, spreadRadius: 0, color: XPColorShadow.reversedTheme15),
    BoxShadow(offset: Offset(0, 1), blurRadius: 4, spreadRadius: 0, color: XPColorShadow.reversedTheme15),
  ];

  /// Used for: dropdown, menu, tooltip.
  static const List<BoxShadow> menuDropdownTooltip = [
    BoxShadow(offset: Offset(0, 0), blurRadius: 4, spreadRadius: 0, color: XPColorShadow.reversedTheme08),
    BoxShadow(offset: Offset(0, 8), blurRadius: 32, spreadRadius: -12, color: XPColorShadow.reversedTheme15),
  ];

  /// Used for: modal, dialog, popover.
  static const List<BoxShadow> modalDialogPopover = [
    BoxShadow(offset: Offset(0, 4), blurRadius: 12, spreadRadius: -6, color: XPColorShadow.reversedTheme10),
    BoxShadow(offset: Offset(0, 20), blurRadius: 80, spreadRadius: 6, color: XPColorShadow.reversedTheme10),
  ];

  /// Used for: app bar, navigation bar.
  static const List<BoxShadow> appBarNavBar = [
    BoxShadow(offset: Offset(0, 0), blurRadius: 2, spreadRadius: 0, color: XPColorShadow.reversedTheme05),
    BoxShadow(offset: Offset(0, 1), blurRadius: 16, spreadRadius: 0, color: XPColorShadow.reversedTheme10),
  ];

  /// Used for: buttons.
  static const List<BoxShadow> floating = [
    BoxShadow(offset: Offset(0, 1), blurRadius: 24, spreadRadius: 0, color: XPColorShadow.reversedTheme05),
    BoxShadow(offset: Offset(0, 2), blurRadius: 40, spreadRadius: 0, color: XPColorShadow.reversedTheme08),
  ];
}

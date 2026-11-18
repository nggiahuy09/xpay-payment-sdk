import 'dart:ui' show Color;

/// This file contains semantic color definitions that should be
/// used directly in views and widgets. All colors in this file
/// **must** be defined using [_XPColorBase], not [_XPColorGlobal].
///
/// Example usage:
///   Text(
///     'Hello World',
///     style: TextStyle(color: XPColorText.defaultColor),
///   )
///
/// Do NOT use either [_XPColorBase] nor [_XPColorGlobal]
/// directly in views or widgets.

part 'color_base.dart';
part 'color_global.dart';

final class XPColorText {
  const XPColorText._();

  static const Color defaultColor = _XPColorBase.neutral700;
  static const Color subtle = _XPColorBase.neutral500;
  static const Color disabled = _XPColorBase.blackOverlay40;
  static const Color inversed = _XPColorBase.white;
  static const Color primary = _XPColorBase.primary400;
  static const Color accent = _XPColorBase.accent400;
  static const Color negative = _XPColorBase.negative400;
  static const Color danger = _XPColorBase.negative400;
  static const Color warning = _XPColorBase.warning400;
  static const Color positive = _XPColorBase.positive400;
  static const Color success = _XPColorBase.positive400;
  static const Color info = _XPColorBase.info400;
}

final class XPColorSurface {
  const XPColorSurface._();

  static const Color defaultColor = _XPColorBase.white;
  static const Color hover = _XPColorBase.blackOverlay05;
  static const Color state = _XPColorBase.neutral100;
  static const Color secondary = _XPColorBase.neutral50;
  static const Color tertiary = _XPColorBase.neutral100;
  static const Color reverse = _XPColorBase.neutral700;
  static const Color disabled = _XPColorBase.blackOverlay05;
  static const Color emphasis = _XPColorBase.neutral200;
  static const Color primary = _XPColorBase.primary50;
  static const Color accent = _XPColorBase.accent50;
  static const Color shampoo = _XPColorBase.pink50;
  static const Color negative = _XPColorBase.negative50;
  static const Color danger = _XPColorBase.negative50;
  static const Color warning = _XPColorBase.warning50;
  static const Color positive = _XPColorBase.positive50;
  static const Color success = _XPColorBase.positive50;
  static const Color info = _XPColorBase.info50;
}

final class XPColorAction {
  const XPColorAction._();

  static const Color primary = _XPColorBase.primary400;
  static const Color primaryHovered = _XPColorBase.primary500;
  static const Color primaryActived = _XPColorBase.primary600;

  static const Color secondary = _XPColorBase.primary50;
  static const Color secondaryHovered = _XPColorBase.primary100;
  static const Color secondaryActived = _XPColorBase.primary200;

  static const Color accent = _XPColorBase.accent400;
  static const Color accentHovered = _XPColorBase.accent500;
  static const Color accentActived = _XPColorBase.accent600;

  static const Color black = _XPColorBase.neutral700;
  static const Color blackHovered = _XPColorBase.neutral600;
  static const Color blackActived = _XPColorBase.neutral500;
  static const Color blackSecondary = _XPColorBase.neutral100;
  static const Color blackSecondaryHovered = _XPColorBase.neutral200;
  static const Color blackSecondaryActived = _XPColorBase.neutral300;

  static const Color white = _XPColorBase.white;
  static const Color whiteHovered = _XPColorBase.neutral100;
  static const Color whiteActived = _XPColorBase.neutral200;
  static const Color whiteSecondary = _XPColorBase.neutral400;
  static const Color whiteSecondaryHovered = _XPColorBase.neutral500;
  static const Color whiteSecondaryActived = _XPColorBase.neutral600;

  static const Color disabled = _XPColorBase.blackOverlay10;

  static const Color negative = _XPColorBase.negative400;
  static const Color negativeHovered = _XPColorBase.negative500;
  static const Color negativeActived = _XPColorBase.negative600;

  static const Color positive = _XPColorBase.positive400;
  static const Color positiveHovered = _XPColorBase.positive500;
  static const Color positiveActived = _XPColorBase.positive600;

  static const Color warning = _XPColorBase.warning400;
  static const Color warningHovered = _XPColorBase.warning500;
  static const Color warningActived = _XPColorBase.warning600;

  static const Color info = _XPColorBase.info400;
  static const Color infoHovered = _XPColorBase.info500;
  static const Color infoActived = _XPColorBase.info600;

  static const Color shampoo = _XPColorBase.pink200;
  static const Color shampooHovered = _XPColorBase.pink300;
  static const Color shampooActived = _XPColorBase.pink400;
}

final class XPColorBorder {
  const XPColorBorder._();

  static const Color defaultColor = _XPColorBase.blackOverlay20;
  static const Color secondary = _XPColorBase.blackOverlay10;
  static const Color tertiary = _XPColorBase.blackOverlay05;
  static const Color focus = _XPColorBase.neutral700;
  static const Color primary = _XPColorBase.primary400;
  static const Color accent = _XPColorBase.accent400;
  static const Color negative = _XPColorBase.negative400;
  static const Color warning = _XPColorBase.warning400;
  static const Color positive = _XPColorBase.positive400;
  static const Color info = _XPColorBase.info400;
  static const Color inversed = _XPColorBase.white;
  static const Color disabled = _XPColorBase.blackOverlay05;
  static const Color reversed = _XPColorBase.white;
  static const Color success = _XPColorBase.positive400;
}

final class XPColorIcon {
  const XPColorIcon._();

  static const Color defaultColor = _XPColorBase.neutral500;
  static const Color subtle = _XPColorBase.neutral400;
  static const Color disabled = _XPColorBase.blackOverlay20;
  static const Color inversed = _XPColorBase.white;
  static const Color inversedDisabled = _XPColorBase.whiteOverlay20;
  static const Color reversed = _XPColorBase.neutral700;
  static const Color primary = _XPColorBase.primary400;
  static const Color accent = _XPColorBase.accent400;
  static const Color negative = _XPColorBase.negative400;
  static const Color warning = _XPColorBase.warning400;
  static const Color positive = _XPColorBase.positive400;
  static const Color success = _XPColorBase.positive400;
  static const Color info = _XPColorBase.info400;
  static const Color warningInversed = _XPColorBase.warning300;
  static const Color positiveInversed = _XPColorBase.positive300;
  static const Color infoInversed = _XPColorBase.info300;
  static const Color negativeInversed = _XPColorBase.negative300;
}

final class XPColorOverlay {
  const XPColorOverlay._();

  static const Color theme03 = _XPColorBase.whiteOverlay03;
  static const Color theme05 = _XPColorBase.whiteOverlay05;
  static const Color theme10 = _XPColorBase.whiteOverlay10;
  static const Color theme15 = _XPColorBase.whiteOverlay15;
  static const Color theme20 = _XPColorBase.whiteOverlay20;
  static const Color theme40 = _XPColorBase.whiteOverlay40;
  static const Color theme60 = _XPColorBase.whiteOverlay60;
  static const Color theme80 = _XPColorBase.whiteOverlay80;

  static const Color reverseTheme03 = _XPColorBase.blackOverlay03;
  static const Color reverseTheme05 = _XPColorBase.blackOverlay05;
  static const Color reverseTheme08 = _XPColorBase.blackOverlay08;
  static const Color reverseTheme10 = _XPColorBase.blackOverlay10;
  static const Color reverseTheme15 = _XPColorBase.blackOverlay15;
  static const Color reverseTheme20 = _XPColorBase.blackOverlay20;
  static const Color reverseTheme40 = _XPColorBase.blackOverlay40;
  static const Color reverseTheme60 = _XPColorBase.blackOverlay60;
  static const Color reverseTheme80 = _XPColorBase.blackOverlay80;
}

final class XPColorShadow {
  const XPColorShadow._();

  static const Color reversedTheme03 = _XPColorBase.blackOverlay03;
  static const Color reversedTheme05 = _XPColorBase.blackOverlay05;
  static const Color reversedTheme08 = _XPColorBase.blackOverlay08;
  static const Color reversedTheme10 = _XPColorBase.blackOverlay10;
  static const Color reversedTheme15 = _XPColorBase.blackOverlay15;
  static const Color reversedTheme20 = _XPColorBase.blackOverlay20;
}

final class XPColorCanvas {
  const XPColorCanvas._();

  static const Color defaultColor = _XPColorBase.white;
  static const Color secondary = _XPColorBase.neutral50;
}

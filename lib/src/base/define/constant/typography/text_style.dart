import 'package:flutter/material.dart';

part 'text_font_family.dart';
part 'text_font_size.dart';
part 'text_font_weight.dart';
part 'text_line_height.dart';

final class XPTextStyle {
  const XPTextStyle._();

  // DISPLAY
  static const TextStyle displayQuadrupleExtraLarge = TextStyle(
    fontSize: _XPTextFontSize.displayQuadrupleExtraLarge,
    fontWeight: _XPTextFontWeight.displayQuadrupleExtraLarge,
    fontFamily: _XPTextFontFamily.playfair,
    height: _XPTextLineHeight.displayQuadrupleExtraLarge / _XPTextFontSize.displayQuadrupleExtraLarge,
  );
  static const TextStyle displayTripleExtraLarge = TextStyle(
    fontSize: _XPTextFontSize.displayTripleExtraLarge,
    fontWeight: _XPTextFontWeight.displayTripleExtraLarge,
    fontFamily: _XPTextFontFamily.playfair,
    height: _XPTextLineHeight.displayTripleExtraLarge / _XPTextFontSize.displayTripleExtraLarge,
  );
  static const TextStyle displayDoubleExtraLarge = TextStyle(
    fontSize: _XPTextFontSize.displayDoubleExtraLarge,
    fontWeight: _XPTextFontWeight.displayDoubleExtraLarge,
    fontFamily: _XPTextFontFamily.playfair,
    height: _XPTextLineHeight.displayDoubleExtraLarge / _XPTextFontSize.displayDoubleExtraLarge,
  );
  static const TextStyle displayExtraLarge = TextStyle(
    fontSize: _XPTextFontSize.displayExtraLarge,
    fontWeight: _XPTextFontWeight.displayExtraLarge,
    fontFamily: _XPTextFontFamily.playfair,
    height: _XPTextLineHeight.displayExtraLarge / _XPTextFontSize.displayExtraLarge,
  );

  // HEADING
  static const TextStyle headingTripleExtraLarge = TextStyle(
    fontSize: _XPTextFontSize.headingTripleExtraLarge,
    fontWeight: _XPTextFontWeight.headingTripleExtraLarge,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.headingTripleExtraLarge / _XPTextFontSize.headingTripleExtraLarge,
  );
  static const TextStyle headingDoubleExtraLarge = TextStyle(
    fontSize: _XPTextFontSize.headingDoubleExtraLarge,
    fontWeight: _XPTextFontWeight.headingDoubleExtraLarge,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.headingDoubleExtraLarge / _XPTextFontSize.headingDoubleExtraLarge,
  );
  static const TextStyle headingExtraLarge = TextStyle(
    fontSize: _XPTextFontSize.headingExtraLarge,
    fontWeight: _XPTextFontWeight.headingExtraLarge,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.headingExtraLarge / _XPTextFontSize.headingExtraLarge,
  );
  static const TextStyle headingLarge = TextStyle(
    fontSize: _XPTextFontSize.headingLarge,
    fontWeight: _XPTextFontWeight.headingLarge,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.headingLarge / _XPTextFontSize.headingLarge,
  );

  // HIGHLIGHT
  static const TextStyle highlightExtraLarge = TextStyle(
    fontSize: _XPTextFontSize.highlightExtraLarge,
    fontWeight: _XPTextFontWeight.highlightExtraLarge,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.highlightExtraLarge / _XPTextFontSize.highlightExtraLarge,
  );
  static const TextStyle highlightLarge = TextStyle(
    fontSize: _XPTextFontSize.highlightLarge,
    fontWeight: _XPTextFontWeight.highlightLarge,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.highlightLarge / _XPTextFontSize.highlightLarge,
  );
  static const TextStyle highlightMedium = TextStyle(
    fontSize: _XPTextFontSize.highlightMedium,
    fontWeight: _XPTextFontWeight.highlightMedium,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.highlightMedium / _XPTextFontSize.highlightMedium,
  );
  static const TextStyle highlightSmall = TextStyle(
    fontSize: _XPTextFontSize.highlightSmall,
    fontWeight: _XPTextFontWeight.highlightSmall,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.highlightSmall / _XPTextFontSize.highlightSmall,
  );
  static const TextStyle highlightExtraSmall = TextStyle(
    fontSize: _XPTextFontSize.highlightExtraSmall,
    fontWeight: _XPTextFontWeight.highlightExtraSmall,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.highlightExtraSmall / _XPTextFontSize.highlightExtraSmall,
  );
  static const TextStyle highlightDoubleExtraSmall = TextStyle(
    fontSize: _XPTextFontSize.highlightDoubleExtraSmall,
    fontWeight: _XPTextFontWeight.highlightDoubleExtraSmall,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.highlightDoubleExtraSmall / _XPTextFontSize.highlightDoubleExtraSmall,
  );

  // BODY
  static const TextStyle bodyExtraLarge = TextStyle(
    fontSize: _XPTextFontSize.bodyExtraLarge,
    fontWeight: _XPTextFontWeight.bodyExtraLarge,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.bodyExtraLarge / _XPTextFontSize.bodyExtraLarge,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: _XPTextFontSize.bodyLarge,
    fontWeight: _XPTextFontWeight.bodyLarge,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.bodyLarge / _XPTextFontSize.bodyLarge,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: _XPTextFontSize.bodyMedium,
    fontWeight: _XPTextFontWeight.bodyMedium,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.bodyMedium / _XPTextFontSize.bodyMedium,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: _XPTextFontSize.bodySmall,
    fontWeight: _XPTextFontWeight.bodySmall,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.bodySmall / _XPTextFontSize.bodySmall,
  );
  static const TextStyle bodyExtraSmall = TextStyle(
    fontSize: _XPTextFontSize.bodyExtraSmall,
    fontWeight: _XPTextFontWeight.bodyExtraSmall,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.bodyExtraSmall / _XPTextFontSize.bodyExtraSmall,
  );
  static const TextStyle bodyDoubleExtraSmall = TextStyle(
    fontSize: _XPTextFontSize.bodyDoubleExtraSmall,
    fontWeight: _XPTextFontWeight.bodyDoubleExtraSmall,
    fontFamily: _XPTextFontFamily.inter,
    height: _XPTextLineHeight.bodyDoubleExtraSmall / _XPTextFontSize.bodyDoubleExtraSmall,
  );
}

/*base class _XPTextStyleBase<T> {
  const _XPTextStyleBase(this._large, this._medium, this._small, this._xSmall);

  final T _large;
  final T _medium;
  final T _small;
  final T _xSmall;

  T get large => _large;

  T get medium => _medium;

  T get small => _small;

  T get xSmall => _xSmall;
}

final class _XPTextStyleXLarge<T> extends _XPTextStyleBase<T> {
  const _XPTextStyleXLarge(this._xLarge, super.large, super.medium, super.small, super.xSmall);

  final T _xLarge;

  T get xLarge => _xLarge;
}

final class _XPTextStyle2xLarge<T> extends _XPTextStyleBase<T> {
  const _XPTextStyle2xLarge(this._doubleLarge, this._xLarge, super.large, super.medium, super.small, super.xSmall);

  final T _doubleLarge;
  final T _xLarge;

  T get doubleLarge => _doubleLarge;

  T get xLarge => _xLarge;
}*/

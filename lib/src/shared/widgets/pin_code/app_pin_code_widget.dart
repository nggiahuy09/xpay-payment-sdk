import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../../base/define/constant/border/border_radius.dart';
import '../../../base/define/constant/color/color_semantic.dart';
import '../../../base/define/constant/typography/text_style.dart' show XPTextStyle;

class XPPinCodeWidget extends StatelessWidget {
  const XPPinCodeWidget({
    super.key,
    this.controller,
    this.errorMsg,
    this.length = 6,
    this.enabled = true,
    this.hasError = false,
    this.obscureText = false,
    this.onChanged,
    this.onCompleted,
  });

  final TextEditingController? controller;
  final String? errorMsg;
  final int length;
  final bool enabled;
  final bool hasError;
  final bool obscureText;
  final void Function(String otp)? onChanged;
  final void Function(String otp)? onCompleted;

  PinTheme get _defaultPinTheme => PinTheme(
    width: 40,
    height: 40,
    textStyle: XPTextStyle.highlightLarge,
    margin: const EdgeInsets.symmetric(horizontal: 2.5),
    decoration: BoxDecoration(
      color: XPColorSurface.defaultColor,
      border: Border.all(color: XPColorBorder.defaultColor, width: 1.0),
      borderRadius: const BorderRadius.all(Radius.circular(XPBorderRadius.rounded08)),
    ),
  );

  @override
  Widget build(BuildContext context) => Pinput(
    controller: controller,
    length: length,
    enabled: enabled,
    obscureText: obscureText,
    forceErrorState: hasError || (errorMsg?.isNotEmpty ?? false),
    keyboardType: TextInputType.number,
    cursor: Container(width: 2, height: 24, color: XPColorText.primary),
    errorText: errorMsg,
    errorTextStyle: XPTextStyle.bodySmall.copyWith(color: XPColorText.danger),
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    defaultPinTheme: _defaultPinTheme,
    focusedPinTheme: _defaultPinTheme.copyDecorationWith(
      color: XPColorAction.whiteHovered.withValues(alpha: 0.5),
      border: Border.all(color: XPColorBorder.defaultColor, width: 1),
    ),
    errorPinTheme: _defaultPinTheme.copyDecorationWith(border: Border.all(color: XPColorBorder.negative, width: 1)),
    onChanged: onChanged,
    onCompleted: onCompleted,
  );
}

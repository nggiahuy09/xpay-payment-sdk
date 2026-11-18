import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';

import '../../../base/define/constant/constant.dart';
import '../widgets.dart';

/// use [readOnly] if you want to make this text field non-editable
///
/// use [obscureText] if you want to make this text field for password input
///
/// use [enabled] = [false] if you want to make this text field disabled (more blurred than readOnly)
class XPTextFieldOutlined extends StatefulWidget {
  const XPTextFieldOutlined({
    super.key,
    this.controller,
    this.focusNode,
    this.textInputType,
    this.inputFormatters,
    this.hintStyle,
    this.labelStyle,
    this.prefixSize,
    this.label,
    this.hintText,
    this.errorText,
    this.initValue,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.allBorder,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.errorMaxLines = 2,
    this.hintMaxLines,
    this.spacing,
    this.borderRadius = XPBorderRadius.rounded10,
    this.obscureText = false,
    this.autocorrect = false,
    this.enabled = true,
    this.readOnly = false,
    this.forceErrorBorder = false,
    this.showCounter = false,
    this.customLabel,
    this.onChanged,
    this.onSubmit,
    this.onEditComplete,
    this.onTap,
  }) : assert(!(obscureText && suffixIcon != null), 'Cannot have suffix icon along with show/hide button'),
       assert(initValue == null || controller == null, 'Cannot have initValue along with controller. Try supplying it through the controller.'),
       assert(!showCounter || maxLength != null, 'Cannot show the counter without maxLength. Try supplying maxLength to give the counter a limit to count towards.');

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final Size? prefixSize;
  final String? label;
  final String? hintText;
  final String? errorText;
  final String? initValue;
  final IconData? icon;
  final Widget? prefixIcon;
  final IconData? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? allBorder;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final int? errorMaxLines;
  final int? hintMaxLines;
  final double? spacing;
  final double borderRadius;
  final bool obscureText;
  final bool autocorrect;
  final bool enabled;
  final bool readOnly;
  final bool forceErrorBorder;

  /// Whether to render the `current/limit` character counter below the field. Requires [maxLength].
  ///
  /// The counter is hidden while [errorText] is showing, so the error message stays directly under the input instead of being pushed a line away by the counter.
  final bool showCounter;
  final Widget? customLabel;
  final void Function()? onEditComplete;
  final void Function(String value)? onChanged;

  /// Called when the user submits the text in the text field and automatically unfocus the current text field (dismiss the keyboard).
  ///
  /// If you want to keep focus or move to the next focus on the text field after submitting, pass [onEditComplete] instead.
  final void Function(String value)? onSubmit;

  /// Called when the text field is tapped. When this is not null, the text field becomes read-only and acts as a button.
  final void Function()? onTap;

  @override
  State<XPTextFieldOutlined> createState() => _XPTextFieldOutlinedState();
}

class _XPTextFieldOutlinedState extends State<XPTextFieldOutlined> {
  late bool _obscureText;

  /// Character count backing the counter. Seeded from whichever initial text source the caller supplied — the two are mutually exclusive by assert — and kept
  /// current in [_onChanged]. Tracked here rather than read from the controller so the counter also works for the `initValue` callers, which own no controller.
  late int _length;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _length = (widget.controller?.text ?? widget.initValue ?? '').characters.length;
  }

  /// Keeps the counter in step with the field while still forwarding to the caller. [setState] runs only when the counter is actually rendered, so fields without it
  /// keep their previous rebuild behaviour.
  void _onChanged(String value) {
    if (widget.showCounter) setState(() => _length = value.characters.length);

    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: widget.spacing ?? 4.0,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.customLabel != null) widget.customLabel!,
        TextFormField(
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          controller: widget.controller,
          obscureText: _obscureText,
          cursorColor: XPColorText.primary,
          keyboardType: widget.textInputType,
          initialValue: widget.initValue,
          inputFormatters: widget.inputFormatters,
          autocorrect: widget.autocorrect,
          onChanged: _onChanged,
          onFieldSubmitted: widget.onSubmit,
          onEditingComplete: widget.onEditComplete,
          onTap: widget.onTap,
          readOnly: widget.readOnly || widget.onTap != null,
          style: XPTextStyle.bodySmall.copyWith(color: widget.enabled ? XPColorText.defaultColor : XPColorText.disabled),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ?? XPTextStyle.bodySmall.copyWith(color: XPColorText.subtle),
            hintMaxLines: widget.hintMaxLines ?? 1,
            // Flutter renders an unstyled counter by default whenever [maxLength] is set, so it is always suppressed and re-rendered through [counter] instead —
            // styled to the design system, and only when asked for. While [errorText] shows, neither is rendered: the error text is a sibling below the field, so a
            // counter in between would push the message a line away from the input it describes.
            // hintMaxLines: 2,
            counterText: '',
            counter: widget.showCounter && (widget.errorText?.isNotEmpty ?? false) == false
                ? XPTextBodyWidget.extraSmall('$_length/${widget.maxLength}', color: XPColorText.subtle)
                : null,
            labelText: widget.label,
            labelStyle: (widget.labelStyle ?? XPTextStyle.bodyMedium).copyWith(color: widget.errorText == null ? XPColorText.subtle : XPColorText.danger),
            floatingLabelStyle: XPTextStyle.bodyMedium.copyWith(color: widget.errorText == null ? XPColorText.primary : XPColorText.danger),
            error: (widget.errorText?.isNotEmpty ?? false) || widget.forceErrorBorder ? const SizedBox.shrink() : null,
            icon: widget.icon == null ? null : Icon(widget.icon!, size: 24),
            iconColor: widget.icon == null ? null : XPColorText.subtle,
            prefixIcon: widget.prefixIcon,
            prefixIconColor: widget.prefixIcon == null ? null : XPColorText.subtle,
            prefixIconConstraints: widget.prefixSize != null ? BoxConstraints.tight(widget.prefixSize!) : null,
            suffixIcon: widget.obscureText
                ? GestureDetector(
                    onTap: () => setState(() => _obscureText = !_obscureText),
                    child: Icon(_obscureText ? Remix.eye_line : Remix.eye_off_line, size: 24, color: XPColorIcon.defaultColor),
                  )
                : widget.suffixIcon != null
                ? Icon(widget.suffixIcon!, size: 24.0, color: XPColorIcon.defaultColor)
                : null,
            suffixIconColor: widget.suffixIcon != null ? XPColorIcon.defaultColor : null,
            contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            filled: widget.enabled == false,
            fillColor: widget.enabled == false ? XPColorSurface.disabled : null,
            border: widget.allBorder,
            enabledBorder:
                widget.allBorder ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
                  borderSide: const BorderSide(color: XPColorBorder.defaultColor, width: 1.0),
                ),
            disabledBorder:
                widget.allBorder ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
                  borderSide: const BorderSide(color: XPColorBorder.defaultColor, width: 1.0),
                ),
            focusedBorder:
                widget.allBorder ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
                  borderSide: const BorderSide(color: XPColorBorder.defaultColor, width: 2.0),
                ),
            errorBorder:
                widget.allBorder ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
                  borderSide: const BorderSide(color: XPColorBorder.negative, width: 1.0),
                ),
            focusedErrorBorder:
                widget.allBorder ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
                  borderSide: const BorderSide(color: XPColorBorder.negative, width: 1.0),
                ),
          ),
        ),
        if (widget.errorText?.isNotEmpty ?? false)
          Text(
            widget.errorText!,
            maxLines: widget.errorMaxLines ?? 2,
            style: XPTextStyle.bodySmall.copyWith(color: XPColorText.danger),
          ),
      ],
    );
  }
}

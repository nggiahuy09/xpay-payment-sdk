import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/helpers/helpers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/payment_failure_entity.dart';
import 'payment_checkout_result_header_widget.dart';

final class PaymentFailureSheetWidget extends StatefulWidget {
  const PaymentFailureSheetWidget({super.key, required this.failure, required this.rideRef});

  final PaymentFailureEntity failure;
  final String rideRef;

  @override
  State<PaymentFailureSheetWidget> createState() => _PaymentFailureSheetWidgetState();
}

final class _PaymentFailureSheetWidgetState extends State<PaymentFailureSheetWidget> {
  bool _isHotlineConfirmed = false;
  bool _isHotlineCopied = false;

  void _pop(PaymentFailureSheetAction action) => Navigator.of(context).pop(action);

  Future<void> _callHotline() async {
    final isDialed = await XPHelperPhone.dialOrCopy(XPSupportConstant.hotline);
    if (mounted == false || isDialed) return;

    setState(() => _isHotlineCopied = true);
  }

  void _onHotlineConfirmChanged(bool isConfirmed) => setState(() => _isHotlineConfirmed = isConfirmed);

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.outcome;

    final failure = widget.failure;
    final kind = failure.kind;
    final reason = failure.reason;
    final detail = failure.detail;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48.0),
        PaymentCheckoutResultHeaderWidget(
          backgroundColor: reason.backgroundColor,
          iconColor: reason.iconColor,
          icon: reason.icon,
          body: kind.getBody(locale) ?? viewLocale.systemErrorBody,
          title: kind.getTitle(locale),
        ),
        if (detail != null) ...[
          const SizedBox(height: 8.0),
          XPTextBodyWidget.extraSmall(detail, color: XPColorText.subtle, textAlign: TextAlign.center),
        ],
        const SizedBox(height: 16.0),
        _PaymentFailureInfoRowWidget(label: locale.payment.xpay.entryRideRefLabel, value: widget.rideRef),
        ...switch (failure.route) {
          PaymentFailureRoute.retryInSdk => [
            const SizedBox(height: 32.0),
            XPButtonFilled.medium(
              leadingIcon: const Icon(Remix.restart_line, size: 18.0, color: XPColorIcon.inversed),
              label: locale.payment.xpay.retry,
              onPressed: () => _pop(PaymentFailureSheetAction.retry),
            ),
          ],
          PaymentFailureRoute.retryInPartner => [
            const SizedBox(height: 32.0),
            XPButtonFilled.medium(label: viewLocale.backToCheckout, onPressed: () => _pop(PaymentFailureSheetAction.backToCheckout)),
          ],
          PaymentFailureRoute.callHotline || PaymentFailureRoute.checkRide || PaymentFailureRoute.switchMethod => [
            const SizedBox(height: 24.0),
            XPTextHighlightWidget.small(viewLocale.hotlineCallBody, textAlign: TextAlign.center),
            const SizedBox(height: 12.0),
            _PaymentFailureInfoRowWidget(
              trailingIcon: Remix.phone_line,
              label: viewLocale.hotlineNumberLabel,
              value: XPSupportConstant.hotlineDisplay,
              onTap: _callHotline,
            ),
            if (_isHotlineCopied) ...[
              const SizedBox(height: 8.0),
              XPTextBodyWidget.extraSmall(viewLocale.hotlineCopiedLabel, color: XPColorText.positive, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24.0),
            _PaymentFailureHotlineConfirmWidget(isConfirmed: _isHotlineConfirmed, onChanged: _onHotlineConfirmChanged),
            const SizedBox(height: 16.0),
            XPButtonFilled.medium(label: viewLocale.continueLabel, enabled: _isHotlineConfirmed, onPressed: () => _pop(PaymentFailureSheetAction.hotlineConfirmed)),
          ],
        },
      ],
    );
  }
}

final class _PaymentFailureInfoRowWidget extends StatelessWidget {
  const _PaymentFailureInfoRowWidget({this.trailingIcon, required this.label, required this.value, this.onTap});

  final IconData? trailingIcon;
  final String label;
  final String value;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final trailingIcon = this.trailingIcon;

    return Material(
      color: XPColorSurface.secondary,
      borderRadius: const BorderRadius.all(Radius.circular(XPBorderRadius.rounded12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            spacing: 8.0,
            children: [
              Expanded(child: XPTextBodyWidget.small(label, color: XPColorText.subtle)),
              XPTextHighlightWidget.small(value, color: onTap == null ? null : XPColorText.primary),
              if (trailingIcon != null) Icon(trailingIcon, size: 18.0, color: XPColorIcon.primary),
            ],
          ),
        ),
      ),
    );
  }
}

final class _PaymentFailureHotlineConfirmWidget extends StatelessWidget {
  const _PaymentFailureHotlineConfirmWidget({required this.isConfirmed, required this.onChanged});

  final bool isConfirmed;
  final void Function(bool isConfirmed) onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.outcome;

    return Material(
      color: isConfirmed ? XPColorSurface.primary : XPColorSurface.defaultColor,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(XPBorderRadius.rounded12)),
        side: BorderSide(color: isConfirmed ? XPColorBorder.primary : XPColorBorder.secondary, width: isConfirmed ? 2.0 : 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onChanged.call(!isConfirmed),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            spacing: 8.0,
            children: [
              Checkbox(value: isConfirmed, activeColor: XPColorAction.primary, onChanged: (value) => onChanged.call(value ?? false)),
              Expanded(child: XPTextBodyWidget.small(viewLocale.hotlineConfirmLabel)),
            ],
          ),
        ),
      ),
    );
  }
}

enum PaymentFailureSheetAction { retry, backToCheckout, hotlineConfirmed }

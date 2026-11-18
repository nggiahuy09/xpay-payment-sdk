import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/payment_verification_recipient_entity.dart';
import 'verification_masked_phone_widget.dart';

final class VerificationRecipientTileWidget extends StatelessWidget {
  const VerificationRecipientTileWidget({super.key, required this.recipient, this.caption, this.subtitle, required this.selected, required this.onTap});

  final PaymentVerificationRecipientEntity recipient;
  final String? caption;
  final String? subtitle;
  final bool selected;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) => XPListItemWidget.selectableRadio(
    content: Row(
      spacing: 16.0,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? XPColorSurface.defaultColor : XPColorSurface.secondary,
            borderRadius: const BorderRadius.all(Radius.circular(XPBorderRadius.rounded12)),
          ),
          child: SizedBox.square(
            dimension: 40.0,
            child: Icon(Remix.smartphone_line, size: 20.0, color: selected ? XPColorIcon.primary : XPColorIcon.subtle),
          ),
        ),
        Expanded(
          child: Column(
            spacing: 2.0,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (caption case final String value) XPTextBodyWidget.extraSmall(value, color: XPColorText.subtle),
              VerificationMaskedPhoneWidget(lastDigits: recipient.phoneLastDigits),
              if (subtitle case final String value) XPTextBodyWidget.extraSmall(value, color: XPColorText.subtle),
            ],
          ),
        ),
      ],
    ),
    activeBorderColor: XPColorAction.primary,
    activeRadioColor: XPColorAction.primary,
    backgroundColor: selected ? XPColorSurface.primary : null,
    borderRadius: XPBorderRadius.rounded16,
    borderWidth: selected ? 2.0 : null,
    centerRadio: true,
    expandContent: true,
    selected: selected,
    onTap: onTap,
  );
}

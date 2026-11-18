import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/payment_verification_recipient_entity.dart';
import 'verification_recipient_tile_widget.dart';

final class VerificationRecipientPickerSheetWidget extends StatefulWidget {
  const VerificationRecipientPickerSheetWidget({super.key, required this.recipients});

  final List<PaymentVerificationRecipientEntity> recipients;

  @override
  State<VerificationRecipientPickerSheetWidget> createState() => _VerificationRecipientPickerSheetWidgetState();
}

final class _VerificationRecipientPickerSheetWidgetState extends State<VerificationRecipientPickerSheetWidget> {
  String? _selectedRecipientId;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;
    final selectedRecipientId = _selectedRecipientId;

    return Column(
      spacing: 24.0,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          spacing: 4.0,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            XPTextHeadingWidget.large(viewLocale.recipientPickerTitle),
            XPTextBodyWidget.small(viewLocale.recipientPickerBody, color: XPColorText.subtle),
          ],
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              spacing: 12.0,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final recipient in widget.recipients)
                  VerificationRecipientTileWidget(
                    recipient: recipient,
                    caption: viewLocale.recipientPhoneCaption,
                    selected: recipient.recipientId == selectedRecipientId,
                    onTap: () => setState(() => _selectedRecipientId = recipient.recipientId),
                  ),
              ],
            ),
          ),
        ),
        Column(
          spacing: 12.0,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            XPButtonFilled.medium(
              leadingIcon: Icon(Remix.send_plane_line, size: 20.0, color: selectedRecipientId != null ? XPColorIcon.inversed : XPColorIcon.subtle),
              label: viewLocale.recipientSendButton,
              enabled: selectedRecipientId != null,
              onPressed: () => Navigator.of(context).pop(selectedRecipientId),
            ),
            XPButtonFilled.medium(
              backgroundColor: XPColorSurface.state,
              labelColor: XPColorText.defaultColor,
              label: viewLocale.recipientCancelButton,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
    );
  }
}

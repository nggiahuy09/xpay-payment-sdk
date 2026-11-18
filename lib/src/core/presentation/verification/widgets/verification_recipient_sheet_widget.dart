import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/payment_verification_recipient_entity.dart';
import 'verification_cooldown_builder_widget.dart';
import 'verification_masked_phone_widget.dart';
import 'verification_recipient_tile_widget.dart';

final class VerificationRecipientSheetWidget extends StatefulWidget {
  const VerificationRecipientSheetWidget({super.key, required this.recipients, this.resendCooldownUntil, required this.currentPhoneLastDigits, this.currentRecipientId});

  final List<PaymentVerificationRecipientEntity> recipients;
  final DateTime? resendCooldownUntil;
  final String currentPhoneLastDigits;
  final String? currentRecipientId;

  @override
  State<VerificationRecipientSheetWidget> createState() => _VerificationRecipientSheetWidgetState();
}

final class _VerificationRecipientSheetWidgetState extends State<VerificationRecipientSheetWidget> {
  late final List<PaymentVerificationRecipientEntity> _otherRecipients = widget.recipients.where((recipient) => recipient.recipientId != widget.currentRecipientId).toList();

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
            XPTextHeadingWidget.large(viewLocale.recipientSheetTitle),
            XPTextBodyWidget.small(viewLocale.recipientSheetBody, color: XPColorText.subtle),
          ],
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              spacing: 24.0,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  spacing: 12.0,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    XPTextHighlightWidget.small(viewLocale.recipientCurrentLabel, color: XPColorText.subtle),
                    _VerificationCurrentRecipientWidget(lastDigits: widget.currentPhoneLastDigits),
                  ],
                ),
                if (_otherRecipients.isNotEmpty)
                  Column(
                    spacing: 12.0,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      XPTextHighlightWidget.small(viewLocale.recipientOthersLabel, color: XPColorText.subtle),
                      for (final recipient in _otherRecipients)
                        VerificationRecipientTileWidget(
                          recipient: recipient,
                          caption: viewLocale.recipientPhoneCaption,
                          selected: recipient.recipientId == selectedRecipientId,
                          onTap: () => setState(() => _selectedRecipientId = recipient.recipientId),
                        ),
                    ],
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
            VerificationCooldownBuilderWidget(
              deadline: widget.resendCooldownUntil,
              builder: (_, remainingSeconds) {
                final canSubmit = selectedRecipientId != null && remainingSeconds == 0;

                return XPButtonFilled.medium(
                  leadingIcon: Icon(Remix.send_plane_line, size: 20.0, color: canSubmit ? XPColorIcon.inversed : XPColorIcon.subtle),
                  label: remainingSeconds > 0 ? viewLocale.recipientConfirmButtonCooldown(remainingSeconds) : viewLocale.recipientConfirmButton,
                  enabled: canSubmit,
                  onPressed: () => Navigator.of(context).pop(selectedRecipientId),
                );
              },
            ),
            XPButtonFilled.medium(
              backgroundColor: XPColorSurface.state,
              labelColor: XPColorText.defaultColor,
              label: viewLocale.recipientKeepButton,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
    );
  }
}

final class _VerificationCurrentRecipientWidget extends StatelessWidget {
  const _VerificationCurrentRecipientWidget({required this.lastDigits});

  final String lastDigits;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    return DecoratedBox(
      decoration: const BoxDecoration(color: XPColorSurface.primary, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded16))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          spacing: 16.0,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(color: XPColorSurface.defaultColor, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded12))),
              child: SizedBox.square(dimension: 40.0, child: Icon(Remix.chat_check_line, size: 20.0, color: XPColorIcon.primary)),
            ),
            Expanded(
              child: Column(
                spacing: 2.0,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  XPTextBodyWidget.extraSmall(viewLocale.recipientPhoneCaption, color: XPColorText.subtle),
                  VerificationMaskedPhoneWidget(lastDigits: lastDigits),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

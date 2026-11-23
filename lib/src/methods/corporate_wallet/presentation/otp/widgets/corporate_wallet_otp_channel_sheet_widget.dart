import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../../base/define/constant/constant.dart';
import '../../../../../base/localization/localization.dart';
import '../../../../../core/presentation/verification/widgets/verification_cooldown_builder_widget.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/corporate_wallet_challenge_entity.dart';
import '../../../domain/entities/corporate_wallet_otp_channel_entity.dart';

final class CorporateWalletOtpChannelSheetWidget extends StatefulWidget {
  const CorporateWalletOtpChannelSheetWidget({super.key, required this.otherChannels, required this.challenge, this.currentChannel, this.resendCooldownUntil});

  final List<CorporateWalletOtpChannelEntity> otherChannels;
  final CorporateWalletChallengeEntity challenge;
  final CorporateWalletOtpChannelEntity? currentChannel;
  final DateTime? resendCooldownUntil;

  @override
  State<CorporateWalletOtpChannelSheetWidget> createState() => _CorporateWalletOtpChannelSheetWidgetState();
}

final class _CorporateWalletOtpChannelSheetWidgetState extends State<CorporateWalletOtpChannelSheetWidget> {
  CorporateWalletOtpChannelEntity? _selectedChannel;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.wallet;
    final verificationLocale = locale.payment.verification;

    final selectedChannel = _selectedChannel;
    final challenge = widget.challenge;

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
            XPTextHeadingWidget.large(viewLocale.changeSheetTitle),
            XPTextBodyWidget.small(viewLocale.changeSheetBody, color: XPColorText.subtle),
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
                    XPTextHighlightWidget.small(viewLocale.changeCurrentLabel, color: XPColorText.subtle),
                    _CorporateWalletCurrentChannelWidget(
                      icon: challenge.method.sentIcon,
                      label: widget.currentChannel?.getLabel(locale) ?? challenge.method.getLabel(locale),
                      destination: challenge.destinationMasked,
                    ),
                  ],
                ),
                if (widget.otherChannels.isNotEmpty)
                  Column(
                    spacing: 12.0,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      XPTextHighlightWidget.small(viewLocale.changeOthersLabel, color: XPColorText.subtle),
                      for (final channel in widget.otherChannels)
                        _CorporateWalletChannelTileWidget(
                          channel: channel,
                          selected: channel == selectedChannel,
                          onTap: () => setState(() => _selectedChannel = channel),
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
                final canSubmit = selectedChannel != null && remainingSeconds == 0;

                return XPButtonFilled.medium(
                  leadingIcon: Icon(Remix.send_plane_line, size: 20.0, color: canSubmit ? XPColorIcon.inversed : XPColorIcon.subtle),
                  label: remainingSeconds > 0 ? verificationLocale.recipientConfirmButtonCooldown(remainingSeconds) : verificationLocale.recipientConfirmButton,
                  enabled: canSubmit,
                  onPressed: () => Navigator.of(context).pop(selectedChannel),
                );
              },
            ),
            XPButtonFilled.medium(
              backgroundColor: XPColorSurface.state,
              labelColor: XPColorText.defaultColor,
              label: viewLocale.changeKeepButton,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
    );
  }
}

final class _CorporateWalletCurrentChannelWidget extends StatelessWidget {
  const _CorporateWalletCurrentChannelWidget({required this.icon, required this.destination, this.label});

  final IconData icon;
  final String destination;
  final String? label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: XPColorSurface.primary, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded16))),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        spacing: 16.0,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(color: XPColorSurface.defaultColor, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded12))),
            child: SizedBox.square(dimension: 40.0, child: Icon(icon, size: 20.0, color: XPColorIcon.primary)),
          ),
          Expanded(
            child: Column(
              spacing: 2.0,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label case final String value) XPTextBodyWidget.extraSmall(value, color: XPColorText.subtle),
                XPTextHeadingWidget.large(destination),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

final class _CorporateWalletChannelTileWidget extends StatelessWidget {
  const _CorporateWalletChannelTileWidget({required this.channel, required this.selected, required this.onTap});

  final CorporateWalletOtpChannelEntity channel;
  final bool selected;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;

    return XPListItemWidget.selectableRadio(
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
              child: Icon(channel.method.channelIcon, size: 20.0, color: selected ? XPColorIcon.primary : XPColorIcon.subtle),
            ),
          ),
          Expanded(
            child: Column(
              spacing: 2.0,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                XPTextBodyWidget.extraSmall(channel.getLabel(locale), color: XPColorText.subtle),
                XPTextHeadingWidget.large(channel.destinationMasked),
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
}

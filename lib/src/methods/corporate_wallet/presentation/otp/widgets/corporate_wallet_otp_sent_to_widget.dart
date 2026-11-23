import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../../base/define/constant/constant.dart';
import '../../../../../base/localization/localization.dart';
import '../../../../../shared/modal/modal_manager.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/corporate_wallet_otp_channel_entity.dart';
import '../blocs/corporate_wallet_otp_bloc.dart';
import 'corporate_wallet_otp_channel_sheet_widget.dart';

final class CorporateWalletOtpSentToWidget extends StatelessWidget {
  const CorporateWalletOtpSentToWidget({super.key});

  Future<void> _handleChangeChannel(BuildContext context, CorporateWalletOtpState state) async {
    final channel = await XPModalManager.showBottomSheet<CorporateWalletOtpChannelEntity>(
      context: context,
      autoWrap: true,
      child: CorporateWalletOtpChannelSheetWidget(
        otherChannels: state.otherChannels,
        challenge: state.challenge,
        currentChannel: state.currentChannel,
        resendCooldownUntil: state.resendCooldownUntil,
      ),
    );
    if (channel == null || context.mounted == false) return;

    context.read<CorporateWalletOtpBloc>().add(CorporateWalletOtpChangeChannelEvent(channel));
  }

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.wallet;

    return BlocBuilder<CorporateWalletOtpBloc, CorporateWalletOtpState>(
      builder: (_, state) {
        final challenge = state.challenge;
        final isSending = state is CorporateWalletOtpResendLoadingState;
        final canChangeChannel = !isSending && state is! CorporateWalletOtpSubmitLoadingState;

        return Row(
          spacing: 8.0,
          children: [
            Icon(challenge.method.sentIcon, size: 20.0, color: XPColorIcon.success),
            XPTextBodyWidget.medium(locale.payment.verification.otpSentToLabel, color: XPColorText.subtle),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: XPTextHighlightWidget.medium(challenge.destinationMasked),
              ),
            ),
            if (state.canChangeChannel)
              XPTextButton.small(
                leadingIcon: Icon(Remix.arrow_left_right_line, size: 18.0, color: canChangeChannel ? XPColorIcon.primary : XPColorIcon.subtle),
                label: viewLocale.changeButton,
                expanded: false,
                loading: isSending && state.isSwitchingChannel,
                onPressed: canChangeChannel ? () => _handleChangeChannel(context, state) : null,
              ),
          ],
        );
      },
    );
  }
}

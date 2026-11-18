import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/modal/modal_manager.dart';
import '../../../../shared/widgets/widgets.dart';
import '../blocs/verification_bloc.dart';
import 'verification_masked_phone_widget.dart';
import 'verification_recipient_sheet_widget.dart';

final class VerificationSentToWidget extends StatelessWidget {
  const VerificationSentToWidget({super.key});

  Future<void> _handleChangeRecipient(BuildContext context, VerificationState state) async {
    final verification = state.verification;
    final lastDigits = verification.phoneLastDigits;
    if (lastDigits == null) return;

    final recipientId = await XPModalManager.showBottomSheet<String>(
      context: context,
      autoWrap: true,
      child: VerificationRecipientSheetWidget(
        recipients: verification.recipients,
        resendCooldownUntil: state.resendCooldownUntil,
        currentPhoneLastDigits: lastDigits,
        currentRecipientId: verification.currentRecipientId,
      ),
    );
    if (recipientId == null || context.mounted == false) return;

    context.read<VerificationBloc>().add(VerificationSelectRecipientEvent(recipientId));
  }

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    return BlocBuilder<VerificationBloc, VerificationState>(
      builder: (_, state) {
        final lastDigits = state.verification.phoneLastDigits;
        if (lastDigits == null) return const SizedBox.shrink();

        final canChangeRecipient = state.canChangeRecipient;

        return Row(
          spacing: 8.0,
          children: [
            const Icon(Remix.chat_check_line, size: 20.0, color: XPColorIcon.success),
            XPTextBodyWidget.medium(viewLocale.otpSentToLabel, color: XPColorText.subtle),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: VerificationMaskedPhoneWidget(lastDigits: lastDigits),
              ),
            ),
            if (state.verification.hasRecipients && !state.isSessionOver)
              XPTextButton.small(
                leadingIcon: Icon(Remix.arrow_left_right_line, size: 18.0, color: canChangeRecipient ? XPColorIcon.primary : XPColorIcon.subtle),
                label: viewLocale.recipientChangeButton,
                expanded: false,
                loading: state is VerificationResendLoadingState && state.isSwitchingRecipient,
                onPressed: canChangeRecipient ? () => _handleChangeRecipient(context, state) : null,
              ),
          ],
        );
      },
    );
  }
}

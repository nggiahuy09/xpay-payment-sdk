import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';
import '../blocs/verification_bloc.dart';
import 'verification_cooldown_builder_widget.dart';

final class VerificationResendActionWidget extends StatelessWidget {
  const VerificationResendActionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    return BlocBuilder<VerificationBloc, VerificationState>(
      builder: (_, state) {
        if (!state.canOfferResend) {
          if (!state.verification.isCodeExpiredWithinSession) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: XPTextBodyWidget.small(viewLocale.resendExpiredPrompt, color: XPColorText.subtle, textAlign: TextAlign.center),
          );
        }

        return VerificationCooldownBuilderWidget(
          deadline: state.resendCooldownUntil,
          onFinished: () => context.read<VerificationBloc>().add(const VerificationResendCooldownEndedEvent()),
          builder: (_, remainingSeconds) {
            final isCoolingDown = remainingSeconds > 0;

            return XPButtonFilled.medium(
              leadingIcon: Icon(Remix.refresh_line, size: 20.0, color: isCoolingDown ? XPColorIcon.subtle : XPColorIcon.defaultColor),
              backgroundColor: XPColorSurface.state,
              labelColor: XPColorText.defaultColor,
              label: isCoolingDown ? viewLocale.resendButtonCooldown(remainingSeconds) : viewLocale.resendButton,
              enabled: !isCoolingDown,
              loading: state is VerificationResendLoadingState && !state.isSwitchingRecipient,
              onPressed: () => context.read<VerificationBloc>().add(const VerificationResendCodeEvent()),
            );
          },
        );
      },
    );
  }
}

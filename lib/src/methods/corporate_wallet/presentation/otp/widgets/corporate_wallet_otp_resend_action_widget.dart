import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../../base/define/constant/constant.dart';
import '../../../../../base/localization/localization.dart';
import '../../../../../core/presentation/verification/widgets/verification_cooldown_builder_widget.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../blocs/corporate_wallet_otp_bloc.dart';

final class CorporateWalletOtpResendActionWidget extends StatelessWidget {
  const CorporateWalletOtpResendActionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    return BlocBuilder<CorporateWalletOtpBloc, CorporateWalletOtpState>(
      builder: (_, state) => VerificationCooldownBuilderWidget(
        deadline: state.resendCooldownUntil,
        onFinished: () => context.read<CorporateWalletOtpBloc>().add(const CorporateWalletOtpResendCooldownEndedEvent()),
        builder: (_, remainingSeconds) {
          final isCoolingDown = remainingSeconds > 0;

          return XPButtonFilled.medium(
            leadingIcon: Icon(Remix.refresh_line, size: 20.0, color: isCoolingDown ? XPColorIcon.subtle : XPColorIcon.defaultColor),
            backgroundColor: XPColorSurface.state,
            labelColor: XPColorText.defaultColor,
            label: isCoolingDown ? viewLocale.resendButtonCooldown(remainingSeconds) : viewLocale.resendButton,
            enabled: !isCoolingDown && state is! CorporateWalletOtpSubmitLoadingState,
            loading: state is CorporateWalletOtpResendLoadingState && !state.isSwitchingChannel,
            onPressed: () => context.read<CorporateWalletOtpBloc>().add(const CorporateWalletOtpResendEvent()),
          );
        },
      ),
    );
  }
}

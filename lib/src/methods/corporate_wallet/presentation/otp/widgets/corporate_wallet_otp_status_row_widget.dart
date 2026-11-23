import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../../base/define/constant/constant.dart';
import '../../../../../base/localization/localization.dart';
import '../../../../../core/presentation/verification/widgets/verification_countdown_row_widget.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../blocs/corporate_wallet_otp_bloc.dart';

final class CorporateWalletOtpStatusRowWidget extends StatelessWidget {
  const CorporateWalletOtpStatusRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    return DecoratedBox(
      decoration: const BoxDecoration(color: XPColorSurface.secondary, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded16))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: BlocBuilder<CorporateWalletOtpBloc, CorporateWalletOtpState>(
          buildWhen: (prev, next) => prev.challenge.expiresAt != next.challenge.expiresAt || prev.attemptsRemaining != next.attemptsRemaining,
          builder: (_, state) {
            final attemptsRemaining = state.attemptsRemaining;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Remix.time_line, size: 18.0, color: XPColorIcon.positive),
                const SizedBox(width: 8.0),
                VerificationCountdownRowWidget(
                  deadline: state.challenge.expiresAt,
                  onExpired: () => context.read<CorporateWalletOtpBloc>().add(const CorporateWalletOtpCodeExpiredEvent()),
                ),
                if (attemptsRemaining != null && attemptsRemaining > 0) ...[
                  const XPDividerWidget.vertical(leftMargin: 16.0, rightMargin: 16.0, height: 20.0),
                  const Icon(Remix.shield_keyhole_line, size: 18.0, color: XPColorIcon.subtle),
                  const SizedBox(width: 8.0),
                  XPTextBodyWidget.small(viewLocale.attemptsLeftLabel, color: XPColorText.subtle),
                  const SizedBox(width: 4.0),
                  XPTextHighlightWidget.small(viewLocale.attemptsLeftValue(attemptsRemaining)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';
import '../blocs/verification_bloc.dart';
import 'verification_countdown_row_widget.dart';

final class VerificationStatusRowWidget extends StatelessWidget {
  const VerificationStatusRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    return DecoratedBox(
      decoration: const BoxDecoration(color: XPColorSurface.secondary, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded16))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: BlocBuilder<VerificationBloc, VerificationState>(
          buildWhen: (prev, next) => prev.countdownDeadline != next.countdownDeadline || prev.verification.attemptsRemaining != next.verification.attemptsRemaining,
          builder: (_, state) {
            final attemptsRemaining = state.verification.attemptsRemaining;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Remix.time_line, size: 18.0, color: XPColorIcon.positive),
                const SizedBox(width: 8.0),
                VerificationCountdownRowWidget(
                  deadline: state.countdownDeadline,
                  onExpired: () => context.read<VerificationBloc>().add(const VerificationCodeExpiredEvent()),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../base/localization/localization.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/corporate_wallet_failure_reason_enum.dart';
import '../blocs/corporate_wallet_otp_bloc.dart';

final class CorporateWalletOtpInlineErrorWidget extends StatelessWidget {
  const CorporateWalletOtpInlineErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;

    return BlocSelector<CorporateWalletOtpBloc, CorporateWalletOtpState, CorporateWalletFailureReason?>(
      selector: (state) => state.rejection,
      builder: (_, rejection) => switch (rejection) {
        final CorporateWalletFailureReason reason => XPInlineMessageWidget.danger(
          title: reason.getTitle(locale) ?? locale.payment.verification.verifyFailedTitle,
          body: reason.getBody(locale),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

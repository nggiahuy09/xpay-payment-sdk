import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../base/localization/localization.dart';
import '../../../../shared/modal/modal_manager.dart';
import '../../../domain/entities/payment_authorize_entity.dart';
import '../blocs/verification_bloc.dart';
import '../widgets/verification_abandon_sheet_widget.dart';
import 'verification_otp_view.dart';
import 'verification_pin_view.dart';

final class PaymentVerificationPage extends StatelessWidget {
  const PaymentVerificationPage({
    super.key,
    required this.verification,
    required this.amount,
    required this.authId,
    this.initialRecipientId,
    this.sessionExpiredExitLabel,
    required this.onSessionExpiredExit,
  });

  final PaymentAuthorizeVerificationEntity verification;
  final double amount;
  final String authId;
  final String? initialRecipientId;
  final String? sessionExpiredExitLabel;
  final void Function() onSessionExpiredExit;

  static bool _shouldConfirmAbandon(VerificationState state) => switch (state) {
    VerificationSubmitLoadingState _ => false,
    VerificationResendLoadingState _ => false,
    VerificationSendLoadingState _ => false,
    VerificationSessionExpiredState _ => false,
    VerificationApprovedState _ => false,
    VerificationDeclinedState _ => false,
    _ => true,
  };

  void _handleConfirmAbandon(BuildContext context) => XPModalManager.showBottomSheet<void>(
    context: context,
    autoWrap: true,
    showThumb: false,
    child: VerificationAbandonSheetWidget(
      onLeave: () {
        context.read<VerificationBloc>().add(const VerificationAbandonEvent());
        Navigator.of(context).pop();
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale, viewLocale = locale.payment.verification;

    return BlocProvider<VerificationBloc>(
      create: (_) => VerificationBloc(verification: verification, amount: amount, authId: authId, initialRecipientId: initialRecipientId),
      child: BlocSelector<VerificationBloc, VerificationState, bool>(
        selector: _shouldConfirmAbandon,
        builder: (blocContext, shouldConfirmAbandon) => PopScope(
          canPop: !shouldConfirmAbandon,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _handleConfirmAbandon(blocContext);
          },
          child: switch (verification.method) {
            PaymentAuthorizeVerificationMethod.smsOtp => VerificationOtpView(sessionExpiredExitLabel: sessionExpiredExitLabel, onSessionExpiredExit: onSessionExpiredExit),
            PaymentAuthorizeVerificationMethod.staticCode => VerificationPinView(
              body: viewLocale.pinBody,
              heading: viewLocale.pinHeading,
              note: viewLocale.verificationStaticCodeSuccessNote,
              sessionExpiredExitLabel: sessionExpiredExitLabel,
              codeLength: VerificationState.maxStaticCodeLength,
              onSessionExpiredExit: onSessionExpiredExit,
            ),
            PaymentAuthorizeVerificationMethod.tokenPin => VerificationPinView(
              body: viewLocale.tokenPinBody,
              heading: viewLocale.tokenPinHeading,
              note: viewLocale.verificationTokenPinSuccessNote,
              sessionExpiredExitLabel: sessionExpiredExitLabel,
              codeLength: VerificationState.tokenPinLength,
              onSessionExpiredExit: onSessionExpiredExit,
            ),
            PaymentAuthorizeVerificationMethod.unknown => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

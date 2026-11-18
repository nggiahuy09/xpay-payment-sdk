import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../base/extensions/extensions.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/loading/loading.dart';
import '../../../../shared/modal/modal_manager.dart';
import '../../../../shared/snack_bar/snack_bar_manager.dart';
import '../../../domain/entities/payment_authorize_entity.dart';
import '../../../domain/entities/payment_verify_result_entity.dart';
import '../blocs/verification_bloc.dart';
import '../views/verification_session_expired_view.dart';
import 'verification_recipient_picker_sheet_widget.dart';
import 'verification_resend_sent_sheet_widget.dart';

/// Handles the verification round-trip side effects for both OTP and PIN views: pops with a [PaymentVerifyResultEntity] on both approval and decline — the
/// server accepted either way, so both end the flow — replaces the input screen when the session expires, and surfaces a snackbar for request-level failures.
///
/// [onCodeCleared] empties the input for the two cases where what it holds is no longer submittable: a retryable rejection, and a resend that just invalidated the
/// code being typed. A rejection's message is rendered in place by [VerificationInlineErrorWidget] and survives that clear, because the bloc holds it for as long as
/// the field stays empty.
///
/// [sessionExpiredExitLabel] and [onSessionExpiredExit] override the expired screen's single action for callers that resumed a parked payment and have a record
/// to return to; left null it offers the create-payment path's "new transaction" exit.
final class VerificationListenerWidget extends StatelessWidget {
  const VerificationListenerWidget({super.key, required this.child, this.sessionExpiredExitLabel, this.onCodeCleared, required this.onSessionExpiredExit});

  final Widget child;
  final String? sessionExpiredExitLabel;
  final void Function()? onCodeCleared;
  final void Function() onSessionExpiredExit;

  NavigatorState? _popToInputScreen(BuildContext context) {
    final inputRoute = ModalRoute.of(context);
    if (inputRoute == null || !inputRoute.isActive) return null;

    return Navigator.of(context)..popUntil((route) => route == inputRoute);
  }

  Future<void> _promptRecipient(BuildContext context, PaymentAuthorizeVerificationEntity verification) async {
    final recipientId = await XPModalManager.showBottomSheet<String>(
      context: context,
      autoWrap: true,
      child: VerificationRecipientPickerSheetWidget(recipients: verification.recipients),
    );
    if (context.mounted == false) return;

    if (recipientId == null) {
      Navigator.of(context).pop();
      return;
    }

    context.read<VerificationBloc>().add(VerificationSelectRecipientEvent(recipientId));
  }

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification, xpayLocale = locale.payment.xpay;

    return MultiBlocListener(
      listeners: [
        BlocListener<VerificationBloc, VerificationState>(
          listenWhen: (prev, next) => prev is VerificationSendLoadingState || next is VerificationSendLoadingState,
          listener: (_, state) => state is VerificationSendLoadingState ? XPLoadingManager.showDefaultOverlay(context) : XPLoadingManager.hideDefaultOverlay(),
        ),
        BlocListener<VerificationBloc, VerificationState>(
          listener: (context, state) {
            switch (state) {
              case VerificationRecipientPromptState _:
                _promptRecipient(context, state.verification);
                break;
              case VerificationApprovedState _:
                _popToInputScreen(context)?.pop(PaymentVerifyResultEntity(verify: state.result, outcome: PaymentVerifyOutcome.approved));
                break;
              case VerificationRejectedState _:
                onCodeCleared?.call();
                break;
              case VerificationCodeExpiredState _:
                onCodeCleared?.call();
                break;
              case VerificationDeclinedState _:
                _popToInputScreen(context)?.pop(PaymentVerifyResultEntity(verify: state.result, outcome: PaymentVerifyOutcome.declined));
                break;
              case VerificationSessionExpiredState _:
                _popToInputScreen(context)?.push(
                  MaterialPageRoute<void>(
                    builder: (_) => VerificationSessionExpiredView(exitLabel: sessionExpiredExitLabel, onExit: onSessionExpiredExit),
                  ),
                );
                break;
              case VerificationErrorState _:
                XPSnackBarManager.show(
                  level: XPSnackBarMessageLevel.error,
                  title: state.failure.getTitle(viewLocale.verifyFailedTitle),
                  body: state.failure.getBody(xpayLocale.resultGenericError),
                );
                break;
              case VerificationResendSentState _:
                onCodeCleared?.call();
                XPModalManager.showBottomSheet<void>(
                  context: context,
                  autoWrap: true,
                  showThumb: false,
                  child: VerificationResendSentSheetWidget(phoneMasked: state.verification.phoneMasked ?? ''),
                );
                break;
              case VerificationCodeSentState _:
                onCodeCleared?.call();
                XPSnackBarManager.show(
                  level: XPSnackBarMessageLevel.success,
                  title: viewLocale.codeSentTitle,
                  body: viewLocale.codeSentBody(state.verification.phoneMasked ?? ''),
                );
                break;
              case VerificationResendErrorState _:
                XPSnackBarManager.show(
                  level: XPSnackBarMessageLevel.error,
                  duration: XPSnackBarDuration.long,
                  title: state.reason.getMessageTitle(locale),
                  body: state.reason.getMessageBody(locale, errorCode: () => state.failure?.errorCode),
                );
                break;
              default:
                break;
            }
          },
        ),
      ],
      child: child,
    );
  }
}

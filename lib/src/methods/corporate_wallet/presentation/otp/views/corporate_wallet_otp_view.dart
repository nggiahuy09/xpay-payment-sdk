import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../../base/define/constant/constant.dart';
import '../../../../../base/localization/localization.dart';
import '../../../../../core/domain/entities/payment_order_entity.dart';
import '../../../../../core/presentation/verification/widgets/verification_icon_widget.dart';
import '../../../../../shared/snack_bar/snack_bar_manager.dart';
import '../../../../../shared/views/views.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/corporate_wallet_challenge_entity.dart';
import '../../../domain/entities/corporate_wallet_failure_reason_enum.dart';
import '../../../domain/entities/corporate_wallet_payment_entity.dart';
import '../blocs/corporate_wallet_otp_bloc.dart';
import '../widgets/corporate_wallet_otp_inline_error_widget.dart';
import '../widgets/corporate_wallet_otp_resend_action_widget.dart';
import '../widgets/corporate_wallet_otp_sent_to_widget.dart';
import '../widgets/corporate_wallet_otp_status_row_widget.dart';
import '../widgets/corporate_wallet_otp_submit_action_widget.dart';

final class CorporateWalletOtpView extends StatefulWidget {
  const CorporateWalletOtpView({super.key, required this.order, required this.onSubmittingChanged, required this.onVerified, required this.onFailed});

  final PaymentOrderEntity order;
  final void Function(bool isSubmitting) onSubmittingChanged;
  final void Function(CorporateWalletPaymentEntity payment) onVerified;
  final void Function(String? errorCode, String? displayMessage) onFailed;

  @override
  State<CorporateWalletOtpView> createState() => _CorporateWalletOtpViewState();
}

final class _CorporateWalletOtpViewState extends State<CorporateWalletOtpView> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _handleFailure({required XPLocaleBase locale, required CorporateWalletFailureReason reason, String? errorCode, String? errorMessage, required String fallbackTitle}) {
    final body = reason.getBody(locale) ?? errorMessage ?? locale.payment.xpay.resultGenericError(errorCode);
    if (reason.isTerminal) return widget.onFailed.call(errorCode, body);

    XPSnackBarManager.show(level: XPSnackBarMessageLevel.error, title: reason.getTitle(locale) ?? fallbackTitle, body: body);
  }

  void _onStateChanged(BuildContext context, CorporateWalletOtpState state) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    switch (state) {
      case CorporateWalletOtpVerifiedState _:
        widget.onVerified.call(state.payment);
        break;
      case CorporateWalletOtpVerifyErrorState _:
        _handleFailure(locale: locale, reason: state.reason, errorCode: state.errorCode, errorMessage: state.errorMessage, fallbackTitle: viewLocale.verifyFailedTitle);
        break;
      case CorporateWalletOtpResendErrorState _:
        _handleFailure(locale: locale, reason: state.reason, errorCode: state.errorCode, errorMessage: state.errorMessage, fallbackTitle: viewLocale.resendFailedTitle);
        break;
      case CorporateWalletOtpResendSentState _:
        _otpController.clear();
        XPSnackBarManager.show(level: XPSnackBarMessageLevel.success, title: viewLocale.codeSentTitle, body: locale.payment.wallet.codeSentBody(state.challenge.destinationMasked));
        break;
      case CorporateWalletOtpRejectedState _:
      case CorporateWalletOtpCodeExpiredState _:
        _otpController.clear();
        break;
      case CorporateWalletOtpInitState _:
      case CorporateWalletOtpCodeChangedState _:
      case CorporateWalletOtpSubmitLoadingState _:
      case CorporateWalletOtpResendLoadingState _:
      case CorporateWalletOtpResendCooldownEndedState _:
        break;
    }

    widget.onSubmittingChanged.call(state is CorporateWalletOtpSubmitLoadingState);
  }

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    return BlocSelector<CorporateWalletOtpBloc, CorporateWalletOtpState, bool>(
      selector: (state) => state is CorporateWalletOtpSubmitLoadingState,
      builder: (_, isSubmitting) => PopScope(
        canPop: !isSubmitting,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: XPColorSurface.defaultColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: XPAppBarWidget(titleLabel: viewLocale.otpTitle, onBackPressed: () => Navigator.of(context).maybePop()),
          ),
          body: BlocListener<CorporateWalletOtpBloc, CorporateWalletOtpState>(
            listener: _onStateChanged,
            child: XPPlatformSafeAreaView(
              child: XPKeyboardDismissOnTap(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8.0),
                            const Center(child: VerificationIconWidget(icon: Remix.shield_keyhole_line)),
                            const SizedBox(height: 16.0),
                            XPTextHeadingWidget.large(viewLocale.otpHeading, textAlign: TextAlign.center),
                            const SizedBox(height: 8.0),
                            BlocSelector<CorporateWalletOtpBloc, CorporateWalletOtpState, CorporateWalletChallengeEntity>(
                              selector: (state) => state.challenge,
                              builder: (_, challenge) => XPTextBodyWidget.medium(
                                challenge.method.getBody(locale, challenge.destinationMasked),
                                color: XPColorText.subtle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24.0),
                            BlocSelector<CorporateWalletOtpBloc, CorporateWalletOtpState, bool>(
                              selector: (state) => state.rejection != null,
                              builder: (_, hasError) => XPPinCodeWidget(
                                controller: _otpController,
                                hasError: hasError,
                                onChanged: (code) => context.read<CorporateWalletOtpBloc>().add(CorporateWalletOtpChangeCodeEvent(code)),
                                onCompleted: (_) => context.read<CorporateWalletOtpBloc>().add(const CorporateWalletOtpSubmitEvent()),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            const CorporateWalletOtpStatusRowWidget(),
                            const SizedBox(height: 16.0),
                            const CorporateWalletOtpInlineErrorWidget(),
                          ],
                        ),
                      ),
                    ),
                    const XPDividerWidget.horizontal(),
                    const Padding(padding: EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 4.0), child: CorporateWalletOtpSentToWidget()),
                    const Padding(padding: EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 0.0), child: CorporateWalletOtpResendActionWidget()),
                    CorporateWalletOtpSubmitActionWidget(order: widget.order),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

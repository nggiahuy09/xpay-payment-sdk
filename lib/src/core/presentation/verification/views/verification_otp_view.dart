import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/views/views.dart';
import '../../../../shared/widgets/widgets.dart';
import '../blocs/verification_bloc.dart';
import '../widgets/verification_deadline_watcher_widget.dart';
import '../widgets/verification_icon_widget.dart';
import '../widgets/verification_inline_error_widget.dart';
import '../widgets/verification_listener_widget.dart';
import '../widgets/verification_resend_action_widget.dart';
import '../widgets/verification_sent_to_widget.dart';
import '../widgets/verification_status_row_widget.dart';
import '../widgets/verification_submit_action_widget.dart';

final class VerificationOtpView extends StatefulWidget {
  const VerificationOtpView({super.key, this.sessionExpiredExitLabel, required this.onSessionExpiredExit});

  final String? sessionExpiredExitLabel;
  final void Function() onSessionExpiredExit;

  @override
  State<VerificationOtpView> createState() => _VerificationOtpViewState();
}

final class _VerificationOtpViewState extends State<VerificationOtpView> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: XPColorSurface.defaultColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: XPAppBarWidget(titleLabel: viewLocale.otpTitle, onBackPressed: () => Navigator.of(context).maybePop()),
      ),
      body: VerificationListenerWidget(
        sessionExpiredExitLabel: widget.sessionExpiredExitLabel,
        onCodeCleared: _codeController.clear,
        onSessionExpiredExit: widget.onSessionExpiredExit,
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
                        XPTextBodyWidget.medium(viewLocale.otpSentBody, color: XPColorText.subtle, textAlign: TextAlign.center),
                        const SizedBox(height: 24.0),
                        BlocSelector<VerificationBloc, VerificationState, bool>(
                          selector: (state) => state.rejection != null,
                          builder: (_, hasError) => XPPinCodeWidget(
                            controller: _codeController,
                            hasError: hasError,
                            onChanged: (code) => context.read<VerificationBloc>().add(VerificationChangeCodeEvent(code)),
                            onCompleted: (_) => context.read<VerificationBloc>().add(const VerificationSubmitEvent()),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const VerificationStatusRowWidget(),
                        const SizedBox(height: 16.0),
                        const VerificationInlineErrorWidget(),
                        BlocSelector<VerificationBloc, VerificationState, DateTime?>(
                          selector: (state) => state.verification.expiresAt,
                          builder: (_, expiresAt) {
                            if (expiresAt == null || !expiresAt.isAfter(DateTime.now())) return const SizedBox.shrink();

                            return Offstage(
                              child: XPCountdownWidget(
                                deadline: expiresAt,
                                onFinished: () => context.read<VerificationBloc>().add(const VerificationCodeExpiredEvent()),
                              ),
                            );
                          },
                        ),
                        const VerificationDeadlineWatcherWidget(),
                      ],
                    ),
                  ),
                ),
                const XPDividerWidget.horizontal(),
                const Padding(padding: EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 4.0), child: VerificationSentToWidget()),
                const Padding(padding: EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 0.0), child: VerificationResendActionWidget()),
                VerificationSubmitActionWidget(label: viewLocale.verifyAndPayButton),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

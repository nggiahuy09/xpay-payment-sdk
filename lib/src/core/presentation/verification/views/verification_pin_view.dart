import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/views/views.dart';
import '../../../../shared/widgets/widgets.dart';
import '../blocs/verification_bloc.dart';
import '../widgets/verification_attempts_widget.dart';
import '../widgets/verification_countdown_row_widget.dart';
import '../widgets/verification_deadline_watcher_widget.dart';
import '../widgets/verification_icon_widget.dart';
import '../widgets/verification_inline_error_widget.dart';
import '../widgets/verification_listener_widget.dart';
import '../widgets/verification_submit_action_widget.dart';

final class VerificationPinView extends StatefulWidget {
  const VerificationPinView({
    super.key,
    required this.body,
    required this.heading,
    required this.note,
    this.sessionExpiredExitLabel,
    required this.codeLength,
    required this.onSessionExpiredExit,
  });

  final String body;
  final String heading;
  final String note;
  final String? sessionExpiredExitLabel;
  final int codeLength;
  final void Function() onSessionExpiredExit;

  @override
  State<VerificationPinView> createState() => _VerificationPinViewState();
}

final class _VerificationPinViewState extends State<VerificationPinView> {
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
        child: XPAppBarWidget(titleLabel: viewLocale.pinTitle, onBackPressed: () => Navigator.of(context).maybePop()),
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
                      children: [
                        const SizedBox(height: 8.0),
                        const VerificationIconWidget(icon: Remix.lock_password_line),
                        const SizedBox(height: 16.0),
                        Column(
                          spacing: 8.0,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            XPTextHeadingWidget.extraLarge(widget.heading, textAlign: TextAlign.center),
                            XPTextBodyWidget.medium(widget.body, color: XPColorText.subtle, textAlign: TextAlign.center),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        BlocSelector<VerificationBloc, VerificationState, bool>(
                          selector: (state) => state.rejection != null,
                          builder: (_, hasError) => XPPinCodeWidget(
                            controller: _codeController,
                            length: widget.codeLength,
                            hasError: hasError,
                            obscureText: true,
                            onChanged: (code) => context.read<VerificationBloc>().add(VerificationChangeCodeEvent(code)),
                            onCompleted: (_) => context.read<VerificationBloc>().add(const VerificationSubmitEvent()),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          runAlignment: WrapAlignment.center,
                          children: [
                            BlocSelector<VerificationBloc, VerificationState, DateTime?>(
                              selector: (state) => state.countdownDeadline,
                              builder: (_, deadline) => VerificationCountdownRowWidget(
                                deadline: deadline,
                                onExpired: () => context.read<VerificationBloc>().add(const VerificationCodeExpiredEvent()),
                              ),
                            ),
                            const XPTextHighlightWidget.small('-'),
                            BlocSelector<VerificationBloc, VerificationState, int?>(
                              selector: (state) => state.verification.attemptsRemaining,
                              builder: (_, attemptsRemaining) => VerificationAttemptsWidget(attemptsRemaining: attemptsRemaining),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        XPInlineMessageWidget.safe(title: widget.note),
                        const SizedBox(height: 16.0),
                        const VerificationInlineErrorWidget(),
                        const VerificationDeadlineWatcherWidget(),
                      ],
                    ),
                  ),
                ),
                VerificationSubmitActionWidget(label: viewLocale.confirmPaymentButton),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

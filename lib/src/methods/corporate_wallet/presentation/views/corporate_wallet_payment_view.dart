import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../base/localization/localization.dart';
import '../../../../core/domain/entities/payment_flow_outcome_entity.dart';
import '../../../../core/domain/entities/payment_session_entity.dart';
import '../../../../core/presentation/payment/helpers/payment_host_cancellation.dart';
import '../../../../core/presentation/payment/views/xpay_payment_entry_view.dart';
import '../../../../di/di.dart';
import '../../../../shared/loading/loading.dart';
import '../../../../shared/snack_bar/snack_bar_manager.dart';
import '../../domain/entities/corporate_wallet_otp_channel_entity.dart';
import '../../domain/entities/corporate_wallet_payment_entity.dart';
import '../../domain/entities/payment_intent_entity.dart';
import '../../domain/entities/payment_intent_status_enum.dart';
import '../blocs/corporate_wallet_bloc.dart';
import '../otp/views/corporate_wallet_otp_page.dart';
import '../qr/blocs/payment_intent_bloc.dart';
import '../qr/views/corporate_wallet_qr_view.dart';
import '../widgets/corporate_wallet_methods_widget.dart';

final class CorporateWalletPaymentView extends StatefulWidget {
  const CorporateWalletPaymentView({super.key, required this.session, required this.onOutcome});

  final PaymentSessionEntity session;
  final void Function(PaymentFlowOutcomeEntity outcome) onOutcome;

  @override
  State<CorporateWalletPaymentView> createState() => _CorporateWalletPaymentViewState();
}

final class _CorporateWalletPaymentViewState extends State<CorporateWalletPaymentView> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final PaymentHostCancellation _hostCancellation = getIt.get<PaymentHostCancellation>();

  bool _isCompleted = false;
  bool _isHostCancelPending = false;
  bool _isMethodOpen = false;
  bool _isOtpSubmitting = false;
  bool _isQrOpen = false;

  @override
  void initState() {
    super.initState();
    _hostCancellation.attach(_cancelByHost);
  }

  @override
  void dispose() {
    _hostCancellation.detach(_cancelByHost);
    super.dispose();
  }

  Future<void> _openQr() async {
    final navigator = _navigatorKey.currentState;
    final intentBloc = context.read<PaymentIntentBloc>();
    if (navigator == null || _isMethodOpen || intentBloc.state.isCancelling) return;

    _isMethodOpen = true;
    _isQrOpen = true;
    intentBloc.add(const PaymentIntentCreateEvent());
    try {
      await navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider<PaymentIntentBloc>.value(
            value: intentBloc,
            child: CorporateWalletQrView(order: widget.session.order),
          ),
        ),
      );
    } finally {
      _isMethodOpen = false;
      _isQrOpen = false;
    }
  }

  void _closeQr() {
    if (_isQrOpen) _navigatorKey.currentState?.pop();
  }

  void _requestOtp(CorporateWalletOtpChannelEntity channel) {
    if (_isMethodOpen || context.read<PaymentIntentBloc>().state.isCancelling) return;

    context.read<CorporateWalletBloc>().add(CorporateWalletRequestOtpEvent(channel));
  }

  Future<void> _openOtp(CorporateWalletOtpRequestedState state) async {
    final navigator = _navigatorKey.currentState;
    if (navigator == null || _isMethodOpen) return;

    _isMethodOpen = true;
    try {
      await navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => CorporateWalletOtpPage(
            channels: state.channels,
            challenge: state.challenge,
            order: widget.session.order,
            onSubmittingChanged: _onOtpSubmittingChanged,
            onVerified: _completeVerified,
            onInterrupted: _reportInterrupted,
            onFailed: _completeOtpFailed,
          ),
        ),
      );
    } finally {
      _isMethodOpen = false;
    }
  }

  void _onOtpSubmittingChanged(bool isSubmitting) {
    _isOtpSubmitting = isSubmitting;
    if (!isSubmitting && _isHostCancelPending) _complete(const PaymentFlowCancelledOutcomeEntity());
  }

  void _completeVerified(CorporateWalletPaymentEntity payment) =>
      _complete(PaymentFlowWalletCapturedOutcomeEntity(currency: payment.currency, externalRef: payment.externalRef, amount: payment.amount));

  void _completeFailed(String? errorCode) => _complete(PaymentFlowFailedOutcomeEntity(errorCode: errorCode));

  void _completeOtpFailed(String? errorCode, bool isConflict) =>
      _complete(isConflict ? PaymentFlowConflictOutcomeEntity(errorCode: errorCode) : PaymentFlowFailedOutcomeEntity(errorCode: errorCode));

  void _reportInterrupted(String? errorCode) {
    if (_isCompleted || mounted == false) return;

    XPLoadingManager.hideDefaultOverlay();
    widget.onOutcome.call(PaymentFlowWalletInterruptedOutcomeEntity(errorCode));
  }

  void _complete(PaymentFlowOutcomeEntity outcome) {
    if (_isCompleted || mounted == false) return;

    _isCompleted = true;
    _hostCancellation.detach(_cancelByHost);
    XPLoadingManager.hideDefaultOverlay();
    getIt.get<SnackBarCubit>().clear();
    widget.onOutcome.call(outcome);
  }

  void _cancelByHost() {
    if (_isOtpSubmitting) {
      _isHostCancelPending = true;
      return;
    }

    final intentState = context.read<PaymentIntentBloc>().state;
    if (intentState.isOpen || intentState.isCancelling) {
      _isHostCancelPending = true;
      context.read<PaymentIntentBloc>().add(const PaymentIntentCancelEvent());
      return;
    }

    _complete(const PaymentFlowCancelledOutcomeEntity());
  }

  Future<void> _handleBack() async {
    if (context.read<PaymentIntentBloc>().state.isCancelling) return;

    final isHandled = await _navigatorKey.currentState?.maybePop() ?? false;
    if (isHandled == false) _complete(const PaymentFlowCancelledOutcomeEntity());
  }

  bool _keepBackHandled(NavigationNotification notification) {
    if (notification.canHandlePop) return false;

    const NavigationNotification(canHandlePop: true).dispatch(context);
    return true;
  }

  void _onWalletStateChanged(BuildContext context, XPLocaleBase locale, CorporateWalletState state) {
    switch (state) {
      case CorporateWalletOtpRequestLoadingState _:
        XPLoadingManager.showDefaultOverlay(context);
        break;
      case CorporateWalletOtpRequestedState _:
        XPLoadingManager.hideDefaultOverlay();
        _openOtp(state);
        break;
      case CorporateWalletOtpRequestErrorState _:
        XPLoadingManager.hideDefaultOverlay();
        final reason = state.reason;
        if (reason.isTerminal) return _completeFailed(state.errorCode);

        XPSnackBarManager.show(
          level: XPSnackBarMessageLevel.error,
          title: reason.getTitle(locale) ?? locale.payment.wallet.otpDeliveryFailedTitle,
          body: reason.getBody(locale) ?? state.errorMessage ?? locale.payment.xpay.resultGenericError(state.errorCode),
        );
        break;
      case CorporateWalletChannelsLoadErrorState _:
        if (state.reason.isTerminal) _completeFailed(state.errorCode);
        break;
      case CorporateWalletInitState _:
      case CorporateWalletChannelsLoadingState _:
      case CorporateWalletChannelsLoadedState _:
        break;
    }
  }

  void _onIntentStateChanged(BuildContext context, XPLocaleBase locale, PaymentIntentState state) {
    switch (state) {
      case PaymentIntentCancelLoadingState _:
        XPLoadingManager.showDefaultOverlay(context);
        break;
      case PaymentIntentCancelledState _:
        XPLoadingManager.hideDefaultOverlay();
        if (_isHostCancelPending) return _complete(const PaymentFlowCancelledOutcomeEntity());

        _closeQr();
        break;
      case PaymentIntentCancelErrorState _:
        XPLoadingManager.hideDefaultOverlay();
        _isHostCancelPending = false;
        XPSnackBarManager.show(
          level: XPSnackBarMessageLevel.error,
          title: locale.payment.wallet.qrCancelFailedTitle,
          body: state.errorMessage ?? locale.payment.wallet.qrCancelFailedBody,
        );
        break;
      case PaymentIntentFailedState _:
        _complete(PaymentFlowFailedOutcomeEntity(errorCode: state.errorCode));
        break;
      case PaymentIntentCapturedState _:
        final intent = state.intent;
        _complete(
          PaymentFlowWalletCapturedOutcomeEntity(
            createdAt: intent.createdAt,
            authId: intent.authId,
            currency: intent.currency,
            externalRef: intent.externalRef,
            amount: intent.amount,
          ),
        );
        break;
      case PaymentIntentEndedState _:
        _complete(_toEndedOutcome(state.intent));
        break;
      case PaymentIntentInitState _:
      case PaymentIntentCreateLoadingState _:
      case PaymentIntentCreateErrorState _:
      case PaymentIntentPendingState _:
        break;
    }
  }

  PaymentFlowOutcomeEntity _toEndedOutcome(PaymentIntentEntity intent) => switch (intent.status) {
    PaymentIntentStatus.declined => const PaymentFlowWalletDeclinedOutcomeEntity(),
    PaymentIntentStatus.expired || PaymentIntentStatus.canceled => const PaymentFlowQrExpiredOutcomeEntity(),
    PaymentIntentStatus.requiresConfirmation || PaymentIntentStatus.captured || PaymentIntentStatus.unknown => const PaymentFlowCancelledOutcomeEntity(),
  };

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) return;
      _handleBack();
    },
    child: MultiBlocListener(
      listeners: [
        BlocListener<CorporateWalletBloc, CorporateWalletState>(listener: (context, state) => _onWalletStateChanged(context, XPLocalization.instance.locale, state)),
        BlocListener<PaymentIntentBloc, PaymentIntentState>(listener: (context, state) => _onIntentStateChanged(context, XPLocalization.instance.locale, state)),
      ],
      child: Stack(
        children: [
          NotificationListener<NavigationNotification>(
            onNotification: _keepBackHandled,
            child: Navigator(
              key: _navigatorKey,
              onGenerateInitialRoutes: (_, _) => [
                MaterialPageRoute<void>(
                  builder: (_) => XPayPaymentEntryView(
                    methods: CorporateWalletMethodsWidget(onQrSelected: _openQr, onChannelSelected: _requestOtp),
                    session: widget.session,
                    onBackPressed: _handleBack,
                  ),
                ),
              ],
            ),
          ),
          const XPSnackBarView(),
        ],
      ),
    ),
  );
}

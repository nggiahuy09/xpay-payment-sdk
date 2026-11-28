import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../api/xpay_payment_result.dart';
import '../../../../base/localization/localization.dart';
import '../../../../di/di.dart';
import '../../../../methods/manual_pan/presentation/views/card_manual_entry_page.dart';
import '../../../../methods/nfc_tap/domain/entities/chip_tap_cryptogram_entity.dart';
import '../../../../methods/nfc_tap/presentation/views/card_nfc_page.dart';
import '../../../../methods/scan_qr/presentation/views/card_qr_scan_page.dart';
import '../../../../shared/loading/loading.dart';
import '../../../../shared/modal/modal_manager.dart';
import '../../../../shared/snack_bar/snack_bar_manager.dart';
import '../../../domain/entities/payment_authorize_entity.dart';
import '../../../domain/entities/payment_chip_tap_entity.dart';
import '../../../domain/entities/payment_entry_mode_enum.dart';
import '../../../domain/entities/payment_flow_outcome_entity.dart';
import '../../../domain/entities/payment_session_entity.dart';
import '../../../domain/entities/payment_verify_result_entity.dart';
import '../../../domain/entities/xpay_qr_prefix.dart';
import '../../verification/views/verification_page.dart';
import '../../verification/widgets/verification_recipient_picker_sheet_widget.dart';
import '../blocs/xpay_payment_bloc.dart';
import '../helpers/payment_host_cancellation.dart';
import '../widgets/xpay_payment_card_methods_widget.dart';
import 'xpay_payment_entry_view.dart';

final class XPayPaymentView extends StatefulWidget {
  const XPayPaymentView({super.key, required this.entryModes, required this.session, required this.onOutcome});

  final List<PaymentEntryMode> entryModes;
  final PaymentSessionEntity session;
  final void Function(PaymentFlowOutcomeEntity outcome) onOutcome;

  @override
  State<XPayPaymentView> createState() => _XPayPaymentViewState();
}

final class _XPayPaymentViewState extends State<XPayPaymentView> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final PaymentHostCancellation _hostCancellation = getIt.get<PaymentHostCancellation>();

  String? _verificationAuthId;
  bool _isCardEntryOpen = false;
  bool _isCompleted = false;
  bool _isHostCancelPending = false;

  double get _amount => widget.session.order.amount.toDouble();

  BuildContext? get _innerContext => _navigatorKey.currentState?.overlay?.context;

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

  Future<void> _startCardEntry(PaymentEntryMode entryMode) async {
    final navigator = _navigatorKey.currentState;
    if (navigator == null || _isCardEntryOpen || context.read<XPayPaymentBloc>().state is XPayPaymentAuthorizingState) return;

    _isCardEntryOpen = true;
    try {
      await _openCardEntry(navigator, entryMode);
    } finally {
      _isCardEntryOpen = false;
    }
  }

  Future<void> _openCardEntry(NavigatorState navigator, PaymentEntryMode entryMode) async {
    switch (entryMode) {
      case PaymentEntryMode.chipTap:
        await _startNfcTap(navigator);
        break;
      case PaymentEntryMode.cardQr:
        await _startQrScan(navigator, prefix: XpayQrPrefix.xpCard, title: entryMode.getMethodTitle(XPLocalization.instance.locale));
        break;
      case PaymentEntryMode.token:
        await _startQrScan(navigator, prefix: XpayQrPrefix.xTok, title: entryMode.getMethodTitle(XPLocalization.instance.locale));
        break;
      case PaymentEntryMode.manualPan:
        await _startManualEntry(navigator);
        break;
      case PaymentEntryMode.rideCard:
        _chargeRideCard();
        break;
    }
  }

  Future<void> _startNfcTap(NavigatorState navigator) async {
    final cryptogram = await navigator.push<ChipTapCryptogramEntity>(MaterialPageRoute<ChipTapCryptogramEntity>(builder: (_) => CardNfcPage(amount: _amount)));
    if (mounted == false || cryptogram == null) return;

    final cardToken = cryptogram.cardToken;
    final counter = cryptogram.counter;
    final nonce = cryptogram.nonce;
    final signature = cryptogram.cryptogram;
    if (cryptogram.isAuthorizable == false || cardToken == null || counter == null || nonce == null || signature == null) {
      return _complete(const PaymentFlowFailedOutcomeEntity(errorCode: XPayErrorCode.unexpectedResponse));
    }

    final chipTap = PaymentChipTapEntity(cryptogram: signature, nonce: nonce, counter: counter, keyVersion: cryptogram.keyVersion);
    context.read<XPayPaymentBloc>().add(XPayCardTappedEvent(chipTap: chipTap, cardToken: cardToken));
  }

  Future<void> _startQrScan(NavigatorState navigator, {required XpayQrPrefix prefix, required String title}) async {
    final rawValue = await navigator.push<String>(
      MaterialPageRoute<String>(
        builder: (_) => CardQrScanPage(prefix: prefix, title: title, amount: _amount),
      ),
    );
    if (mounted == false || rawValue == null || rawValue.isEmpty) return;

    context.read<XPayPaymentBloc>().add(XPayQrScannedEvent(prefix: prefix, rawValue: rawValue));
  }

  Future<void> _startManualEntry(NavigatorState navigator) async {
    await navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CardManualEntryPage(amount: _amount, onSubmitted: (pan) => context.read<XPayPaymentBloc>().add(XPayPanEnteredEvent(pan))),
      ),
    );
  }

  void _chargeRideCard() {
    final rideCard = widget.session.rideCard;
    if (rideCard == null) return;

    context.read<XPayPaymentBloc>().add(XPayRideCardChargedEvent(rideCard.token));
  }

  void _closeCardEntry() {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  void _complete(PaymentFlowOutcomeEntity outcome) {
    if (_isCompleted || mounted == false) return;

    _isCompleted = true;
    _hostCancellation.detach(_cancelByHost);
    XPLoadingManager.hideDefaultOverlay();
    getIt.get<SnackBarCubit>().clear();
    widget.onOutcome.call(outcome);
  }

  /// An authorization in flight may already charge the card, so its outcome is awaited instead.
  void _cancelByHost() {
    if (context.read<XPayPaymentBloc>().state is XPayPaymentAuthorizingState) {
      _isHostCancelPending = true;
      return;
    }

    _complete(PaymentFlowCancelledOutcomeEntity(_verificationAuthId));
  }

  Future<void> _handleBack() async {
    if (context.read<XPayPaymentBloc>().state is XPayPaymentAuthorizingState) return;

    final isHandled = await _navigatorKey.currentState?.maybePop() ?? false;
    if (isHandled == false) _complete(const PaymentFlowCancelledOutcomeEntity());
  }

  void _routeAuthorization(PaymentAuthorizeEntity authorize, PaymentEntryMode entryMode) {
    final verification = authorize.verification;
    final authId = authorize.authId;
    if (authorize.canPresentVerification && verification != null && authId != null) {
      // Nobody is left to verify it.
      if (_isHostCancelPending) return _complete(PaymentFlowCancelledOutcomeEntity(authId));

      _verificationAuthId = authId;
      if (entryMode == PaymentEntryMode.manualPan && verification.isAwaitingRecipient) {
        _chooseRecipientThenVerify(verification: verification, authId: authId);
      } else {
        _closeCardEntry();
        _startVerification(verification: verification, authId: authId);
      }
      return;
    }

    _complete(PaymentFlowAuthorizedOutcomeEntity(authorize));
  }

  Future<void> _chooseRecipientThenVerify({required PaymentAuthorizeVerificationEntity verification, required String authId}) async {
    final innerContext = _innerContext;
    if (innerContext == null) return;

    final recipientId = await XPModalManager.showBottomSheet<String>(
      context: innerContext,
      autoWrap: true,
      child: VerificationRecipientPickerSheetWidget(recipients: verification.recipients),
    );
    if (mounted == false) return;
    if (recipientId == null) return _complete(PaymentFlowCancelledOutcomeEntity(authId));

    _closeCardEntry();
    _startVerification(verification: verification, authId: authId, initialRecipientId: recipientId);
  }

  Future<void> _startVerification({required PaymentAuthorizeVerificationEntity verification, required String authId, String? initialRecipientId}) async {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    final locale = XPLocalization.instance.locale;
    final result = await navigator.push<PaymentVerifyResultEntity>(
      MaterialPageRoute<PaymentVerifyResultEntity>(
        builder: (_) => PaymentVerificationPage(
          verification: verification,
          amount: _amount,
          authId: authId,
          initialRecipientId: initialRecipientId,
          sessionExpiredExitLabel: locale.payment.xpay.close,
          onSessionExpiredExit: () => _complete(const PaymentFlowExpiredOutcomeEntity()),
          onFailed: (errorCode, isConflict) => _complete(
            isConflict
                ? PaymentFlowConflictOutcomeEntity(errorCode: errorCode, pendingAuthId: authId)
                : PaymentFlowFailedOutcomeEntity(errorCode: errorCode, pendingAuthId: authId),
          ),
        ),
      ),
    );
    if (mounted == false) return;

    _complete(result == null ? PaymentFlowCancelledOutcomeEntity(authId) : PaymentFlowVerifiedOutcomeEntity(result: result, authId: authId));
  }

  bool _keepBackHandled(NavigationNotification notification) {
    if (notification.canHandlePop) return false;

    const NavigationNotification(canHandlePop: true).dispatch(context);
    return true;
  }

  void _onStateChanged(BuildContext context, XPayPaymentState state) {
    final locale = XPLocalization.instance.locale;
    final xpayLocale = locale.payment.xpay;

    switch (state) {
      case XPayPaymentInitState _:
        break;
      case XPayPaymentAuthorizingState _:
        XPLoadingManager.showDefaultOverlay(context);
        break;
      case XPayPaymentAuthorizeDoneState _:
        XPLoadingManager.hideDefaultOverlay();
        _routeAuthorization(state.authorize, state.entryMode);
        break;
      case XPayPaymentAuthorizeConflictState _:
        _complete(PaymentFlowConflictOutcomeEntity(errorCode: state.errorCode));
        break;
      case XPayPaymentAuthorizeErrorState _:
        _complete(PaymentFlowFailedOutcomeEntity(errorCode: state.errorCode));
        break;
      case XPayPaymentInvalidQrState _:
        XPSnackBarManager.show(level: XPSnackBarMessageLevel.error, title: xpayLocale.invalidQrCode);
        break;
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) return;
      _handleBack();
    },
    child: BlocListener<XPayPaymentBloc, XPayPaymentState>(
      listener: _onStateChanged,
      child: Stack(
        children: [
          NotificationListener<NavigationNotification>(
            onNotification: _keepBackHandled,
            child: Navigator(
              key: _navigatorKey,
              onGenerateInitialRoutes: (_, _) => [
                MaterialPageRoute<void>(
                  builder: (_) => XPayPaymentEntryView(
                    methods: XPayPaymentCardMethodsWidget(entryModes: widget.entryModes, rideCard: widget.session.rideCard, onSelected: _startCardEntry),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/di.dart';
import '../../../../shared/loading/loading.dart';
import '../../../../shared/modal/modal_manager.dart';
import '../../../../shared/snack_bar/snack_bar_manager.dart';
import '../../../domain/entities/payment_checkout_result_entity.dart';
import '../../../domain/entities/payment_entry_mode_enum.dart';
import '../../../domain/entities/payment_failure_entity.dart';
import '../../../domain/entities/payment_flow_outcome_entity.dart';
import '../../../domain/entities/payment_session_entity.dart';
import '../../payment/helpers/payment_host_cancellation.dart';
import '../../payment/views/xpay_payment_page.dart';
import '../blocs/payment_checkout_bloc.dart';
import '../widgets/payment_failure_sheet_widget.dart';
import 'payment_checkout_hotline_wait_view.dart';
import 'payment_checkout_options_view.dart';
import 'payment_checkout_paid_view.dart';
import 'payment_checkout_ride_closed_view.dart';
import 'payment_checkout_status_check_view.dart';

final class PaymentCheckoutView extends StatefulWidget {
  const PaymentCheckoutView({super.key, required this.entryModes, required this.session});

  final List<PaymentEntryMode> entryModes;
  final PaymentSessionEntity session;

  @override
  State<PaymentCheckoutView> createState() => _PaymentCheckoutViewState();
}

final class _PaymentCheckoutViewState extends State<PaymentCheckoutView> {
  final PaymentHostCancellation _hostCancellation = getIt.get<PaymentHostCancellation>();

  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _hostCancellation
      ..reset()
      ..attach(_cancelByHost);
  }

  @override
  void dispose() {
    _hostCancellation.detach(_cancelByHost);
    super.dispose();
  }

  void _reportOutcome(PaymentFlowOutcomeEntity outcome) => context.read<PaymentCheckoutBloc>().add(PaymentCheckoutOutcomeReportedEvent(outcome, _hostCancellation.isRequested));

  void _handleBack() => _leave(context.read<PaymentCheckoutBloc>().state);

  void _cancelByHost() {
    final bloc = context.read<PaymentCheckoutBloc>();
    switch (bloc.state) {
      case PaymentCheckoutCollectingState _:
      case PaymentCheckoutSettlingState _:
      case PaymentCheckoutFailedState _:
        bloc.add(const PaymentCheckoutCancelledEvent());
        break;
      case final PaymentCheckoutState state:
        _leave(state);
        break;
    }
  }

  void _leave(PaymentCheckoutState state) {
    final bloc = context.read<PaymentCheckoutBloc>();
    switch (state) {
      case PaymentCheckoutCheckingState _:
        bloc.add(const PaymentCheckoutCancelledEvent());
        break;
      case PaymentCheckoutOptionsState _:
        bloc.add(const PaymentCheckoutOtherMethodPressedEvent());
        break;
      case PaymentCheckoutHotlineWaitingState _:
        bloc.add(const PaymentCheckoutHotlineWaitLeftEvent());
        break;
      case PaymentCheckoutPaidState _:
        bloc.add(PaymentCheckoutPaidDismissedEvent(state.payment));
        break;
      case PaymentCheckoutRideClosedState _:
        bloc.add(PaymentCheckoutRideClosedDismissedEvent(state.settlement));
        break;
      case PaymentCheckoutCollectingState _:
      case PaymentCheckoutSettlingState _:
      case PaymentCheckoutFailedState _:
      case PaymentCheckoutClosedState _:
        break;
    }
  }

  Future<void> _showFailure(PaymentFailureEntity failure) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final action = await XPModalManager.showBottomSheet<PaymentFailureSheetAction>(
      context: context,
      barrierDismissible: false,
      enableDrag: false,
      autoWrap: true,
      showThumb: false,
      child: PaymentFailureSheetWidget(failure: failure, rideRef: widget.session.order.externalRef),
    );
    if (mounted == false || action == null) return;

    final bloc = context.read<PaymentCheckoutBloc>();
    switch (action) {
      case PaymentFailureSheetAction.retry:
        bloc.add(const PaymentCheckoutRetryPressedEvent());
        break;
      case PaymentFailureSheetAction.backToCheckout:
        bloc.add(const PaymentCheckoutBackToPartnerPressedEvent());
        break;
      case PaymentFailureSheetAction.hotlineConfirmed:
        bloc.add(const PaymentCheckoutHotlineConfirmedEvent());
        break;
    }
  }

  void _close(PaymentCheckoutResultEntity result) {
    if (_isClosing) return;

    _isClosing = true;
    XPLoadingManager.hideDefaultOverlay();
    getIt.get<SnackBarCubit>().clear();
    final navigator = Navigator.of(context);
    final route = ModalRoute.of(context);
    if (route != null) navigator.popUntil((candidate) => candidate == route);
    navigator.pop(result);
  }

  void _onStateChanged(BuildContext context, PaymentCheckoutState state) {
    switch (state) {
      case PaymentCheckoutFailedState _:
        _showFailure(state.failure);
        break;
      case PaymentCheckoutClosedState _:
        _close(state.result);
        break;
      case PaymentCheckoutCheckingState _:
      case PaymentCheckoutCollectingState _:
      case PaymentCheckoutSettlingState _:
      case PaymentCheckoutOptionsState _:
      case PaymentCheckoutHotlineWaitingState _:
      case PaymentCheckoutPaidState _:
      case PaymentCheckoutRideClosedState _:
        break;
    }
  }

  void _onSettlingChanged(BuildContext context, PaymentCheckoutState state) {
    if (state is PaymentCheckoutSettlingState) return XPLoadingManager.showDefaultOverlay(context);

    XPLoadingManager.hideDefaultOverlay();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) return;
      _handleBack();
    },
    child: MultiBlocListener(
      listeners: [
        BlocListener<PaymentCheckoutBloc, PaymentCheckoutState>(listener: _onStateChanged),
        BlocListener<PaymentCheckoutBloc, PaymentCheckoutState>(
          listenWhen: (prev, next) => prev is PaymentCheckoutSettlingState || next is PaymentCheckoutSettlingState,
          listener: _onSettlingChanged,
        ),
      ],
      child: BlocBuilder<PaymentCheckoutBloc, PaymentCheckoutState>(
        buildWhen: (_, next) => next is! PaymentCheckoutClosedState,
        builder: (_, state) {
          final cover = switch (state) {
            PaymentCheckoutCheckingState _ => PaymentCheckoutStatusCheckView(onBackPressed: _handleBack),
            PaymentCheckoutCollectingState _ || PaymentCheckoutSettlingState _ || PaymentCheckoutFailedState _ || PaymentCheckoutClosedState _ => null,
            PaymentCheckoutOptionsState _ => PaymentCheckoutOptionsView(
              onBackPressed: _handleBack,
              onHotlinePayPressed: () => context.read<PaymentCheckoutBloc>().add(const PaymentCheckoutHotlinePayPressedEvent()),
              onOtherMethodPressed: () => context.read<PaymentCheckoutBloc>().add(const PaymentCheckoutOtherMethodPressedEvent()),
              onRetryXpayPressed: () => context.read<PaymentCheckoutBloc>().add(const PaymentCheckoutRetryXpayPressedEvent()),
            ),
            PaymentCheckoutHotlineWaitingState _ => PaymentCheckoutHotlineWaitView(order: widget.session.order, deadline: state.deadline, onBackPressed: _handleBack),
            PaymentCheckoutPaidState _ => PaymentCheckoutPaidView(
              payment: state.payment,
              session: widget.session,
              onDismissed: () => context.read<PaymentCheckoutBloc>().add(PaymentCheckoutPaidDismissedEvent(state.payment)),
            ),
            PaymentCheckoutRideClosedState _ => PaymentCheckoutRideClosedView(
              session: widget.session,
              settlement: state.settlement,
              onDismissed: () => context.read<PaymentCheckoutBloc>().add(PaymentCheckoutRideClosedDismissedEvent(state.settlement)),
            ),
          };
          final showsMethod = switch (state) {
            PaymentCheckoutCollectingState _ || PaymentCheckoutSettlingState _ || PaymentCheckoutFailedState _ || PaymentCheckoutClosedState _ => true,
            PaymentCheckoutOptionsState _ => state.keepsMethod,
            PaymentCheckoutHotlineWaitingState _ => state.keepsMethod,
            PaymentCheckoutCheckingState _ || PaymentCheckoutPaidState _ || PaymentCheckoutRideClosedState _ => false,
          };

          return Stack(
            fit: StackFit.expand,
            children: [
              if (showsMethod)
                Offstage(
                  offstage: cover != null,
                  child: TickerMode(
                    enabled: cover == null,
                    child: XPayPaymentPage(
                      key: ValueKey(state.attempt),
                      entryModes: widget.entryModes,
                      session: widget.session,
                      method: state.method,
                      onOutcome: _reportOutcome,
                    ),
                  ),
                ),
              ?cover,
            ],
          );
        },
      ),
    ),
  );
}

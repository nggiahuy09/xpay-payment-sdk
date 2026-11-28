import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/helpers/helpers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/payment_checkout_result_entity.dart';
import '../../../domain/entities/payment_session_entity.dart';
import '../widgets/payment_checkout_detail_rows_widget.dart';
import '../widgets/payment_checkout_result_header_widget.dart';
import '../widgets/payment_checkout_scaffold_widget.dart';

final class PaymentCheckoutPaidView extends StatelessWidget {
  const PaymentCheckoutPaidView({super.key, required this.payment, required this.session, required this.onDismissed});

  final PaymentCheckoutPaymentEntity payment;
  final PaymentSessionEntity session;
  final void Function() onDismissed;

  static const String _kTimeFormat = 'HH:mm';

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.xpay;

    final order = session.order;
    final trip = session.trip;
    final pickupLocation = trip.pickupLocation;
    final destination = trip.destination;
    final plateNumber = trip.plateNumber;
    final currency = payment.currency ?? order.currency;
    final paidAt = (payment.createdAt ?? DateTime.now()).toLocal();
    final rows = [
      PaymentCheckoutDetailRow(label: viewLocale.entryRideRefLabel, value: payment.externalRef ?? order.externalRef),
      if (pickupLocation != null) PaymentCheckoutDetailRow(label: viewLocale.entryPickupLabel, value: pickupLocation),
      if (destination != null) PaymentCheckoutDetailRow(label: viewLocale.entryDestinationLabel, value: destination),
      if (plateNumber != null) PaymentCheckoutDetailRow(label: viewLocale.entryPlateNumberLabel, value: plateNumber),
      PaymentCheckoutDetailRow(label: viewLocale.transactionTimeLabel, value: '${viewLocale.todayLabel}, ${DateFormat(_kTimeFormat).format(paidAt)}'),
    ];

    return PaymentCheckoutScaffoldWidget(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32.0),
            PaymentCheckoutResultHeaderWidget(
              backgroundColor: XPColorAction.primary,
              iconColor: XPColorIcon.inversed,
              icon: Remix.check_line,
              body: payment.paidBy.isCs ? locale.payment.outcome.paidByHotlineLabel : viewLocale.paymentSuccessBody,
              title: viewLocale.paymentSuccessTitle,
            ),
            const SizedBox(height: 16.0),
            XPTextDisplayWidget.tripleExtraLarge(
              payment.amount == null ? XPHelperCurrencyFormat.format(order.amount, currency: currency) : XPHelperCurrencyFormat.formatRemote(payment.amount, currency: currency),
              color: XPColorText.primary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            PaymentCheckoutDetailRowsWidget(rows: rows),
          ],
        ),
      ),
      footer: _PaymentCheckoutAutoBackButtonWidget(onDismissed: onDismissed),
      onBackPressed: onDismissed,
    );
  }
}

final class _PaymentCheckoutAutoBackButtonWidget extends StatefulWidget {
  const _PaymentCheckoutAutoBackButtonWidget({required this.onDismissed});

  final void Function() onDismissed;

  @override
  State<_PaymentCheckoutAutoBackButtonWidget> createState() => _PaymentCheckoutAutoBackButtonWidgetState();
}

final class _PaymentCheckoutAutoBackButtonWidgetState extends State<_PaymentCheckoutAutoBackButtonWidget> {
  static const int _kAutoBackSeconds = 3;

  Timer? _timer;
  int _secondsLeft = _kAutoBackSeconds;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onTick(Timer timer) {
    if (_secondsLeft > 1) return setState(() => _secondsLeft--);

    _dismiss();
  }

  void _dismiss() {
    _timer?.cancel();
    if (_isDismissed) return;

    _isDismissed = true;
    widget.onDismissed.call();
  }

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.outcome;

    return XPButtonFilled.medium(label: viewLocale.autoBackLabel(_secondsLeft), onPressed: _dismiss);
  }
}

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/helpers/helpers.dart';
import '../../../../shared/views/views.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/payment_entry_mode_enum.dart';
import '../../../domain/entities/payment_order_entity.dart';
import '../../../domain/entities/payment_ride_card_entity.dart';
import '../../../domain/entities/payment_session_entity.dart';

final class XPayPaymentEntryView extends StatelessWidget {
  const XPayPaymentEntryView({super.key, required this.entryModes, required this.session, required this.onSelected});

  final List<PaymentEntryMode> entryModes;
  final PaymentSessionEntity session;
  final void Function(PaymentEntryMode entryMode) onSelected;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.xpay;
    final trip = session.trip;
    final pickupLocation = trip.pickupLocation;
    final destination = trip.destination;
    final plateNumber = trip.plateNumber;
    final tripRows = [
      _XPayPaymentEntryTripRow(label: viewLocale.entryRideRefLabel, value: session.order.externalRef),
      if (pickupLocation != null) _XPayPaymentEntryTripRow(label: viewLocale.entryPickupLabel, value: pickupLocation),
      if (destination != null) _XPayPaymentEntryTripRow(label: viewLocale.entryDestinationLabel, value: destination),
      if (plateNumber != null) _XPayPaymentEntryTripRow(label: viewLocale.entryPlateNumberLabel, value: plateNumber),
    ];

    return Scaffold(
      backgroundColor: XPColorSurface.defaultColor,
      body: XPPlatformSafeAreaView(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              spacing: 24.0,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _XPayPaymentEntryAmountWidget(order: session.order),
                _XPayPaymentEntrySectionWidget(
                  title: viewLocale.entryTripTitle,
                  child: _XPayPaymentEntryTripWidget(rows: tripRows),
                ),
                _XPayPaymentEntrySectionWidget(
                  title: viewLocale.entryMethodsTitle,
                  child: Column(
                    spacing: 12.0,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final entryMode in entryModes)
                        _XPayPaymentEntryMethodWidget(
                          rideCard: entryMode == PaymentEntryMode.rideCard ? session.rideCard : null,
                          entryMode: entryMode,
                          onTap: () => onSelected.call(entryMode),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _XPayPaymentEntryAmountWidget extends StatelessWidget {
  const _XPayPaymentEntryAmountWidget({required this.order});

  final PaymentOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.xpay;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: XPColorSurface.primary,
        borderRadius: const BorderRadius.all(Radius.circular(XPBorderRadius.rounded20)),
        border: Border.all(color: XPColorBorder.primary),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          spacing: 8.0,
          children: [
            XPTextHighlightWidget.small(viewLocale.amountToChargeLabel, color: XPColorText.primary, textAlign: TextAlign.center),
            XPTextDisplayWidget.quadrupleExtraLarge(XPHelperCurrencyFormat.format(order.amount, currency: order.currency), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

final class _XPayPaymentEntrySectionWidget extends StatelessWidget {
  const _XPayPaymentEntrySectionWidget({required this.child, required this.title});

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) => Column(
    spacing: 12.0,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      XPTextHighlightWidget.extraSmall(title.toUpperCase(), color: XPColorText.subtle),
      child,
    ],
  );
}

final class _XPayPaymentEntryTripWidget extends StatelessWidget {
  const _XPayPaymentEntryTripWidget({required this.rows});

  final List<_XPayPaymentEntryTripRow> rows;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(XPBorderRadius.rounded16)),
      border: Border.all(color: XPColorBorder.secondary),
    ),
    child: Column(
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) const XPDividerWidget.horizontal(color: XPColorBorder.secondary),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              spacing: 12.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 80.0),
                  child: XPTextBodyWidget.small(row.label, color: XPColorText.subtle),
                ),
                Expanded(child: XPTextHighlightWidget.small(row.value, textAlign: TextAlign.end)),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

final class _XPayPaymentEntryMethodWidget extends StatelessWidget {
  const _XPayPaymentEntryMethodWidget({this.rideCard, required this.entryMode, required this.onTap});

  final PaymentRideCardEntity? rideCard;
  final PaymentEntryMode entryMode;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;

    return XPListItemWidget.general(
      leading: DecoratedBox(
        decoration: const BoxDecoration(color: XPColorAction.primary, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded12))),
        child: SizedBox.square(dimension: 48.0, child: Icon(entryMode.icon, size: 24.0, color: XPColorIcon.inversed)),
      ),
      trailing: const Icon(Remix.arrow_right_s_line, size: 24.0, color: XPColorIcon.primary),
      borderColor: XPColorBorder.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      titleStyle: XPTextStyle.highlightMedium,
      subtitle: entryMode.getMethodBody(locale, rideCard),
      title: entryMode.getMethodTitle(locale, rideCard),
      borderRadius: XPBorderRadius.rounded16,
      borderWidth: 1.0,
      contentGap: 0.0,
      leadingGap: 12.0,
      subtitleMaxLines: 2,
      onTap: onTap,
    );
  }
}

@immutable
final class _XPayPaymentEntryTripRow {
  const _XPayPaymentEntryTripRow({required this.label, required this.value});

  final String label;
  final String value;
}

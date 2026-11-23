import 'package:flutter/material.dart';

import '../../../../base/localization/localization.dart';
import '../../../domain/entities/payment_entry_mode_enum.dart';
import '../../../domain/entities/payment_ride_card_entity.dart';
import 'xpay_payment_method_tile_widget.dart';

final class XPayPaymentCardMethodsWidget extends StatelessWidget {
  const XPayPaymentCardMethodsWidget({super.key, required this.entryModes, this.rideCard, required this.onSelected});

  final List<PaymentEntryMode> entryModes;
  final PaymentRideCardEntity? rideCard;
  final void Function(PaymentEntryMode entryMode) onSelected;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;

    return Column(
      spacing: 12.0,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entryMode in entryModes)
          XPayPaymentMethodTileWidget(
            icon: entryMode.icon,
            subtitle: entryMode.getMethodBody(locale, entryMode == PaymentEntryMode.rideCard ? rideCard : null),
            title: entryMode.getMethodTitle(locale, entryMode == PaymentEntryMode.rideCard ? rideCard : null),
            onTap: () => onSelected.call(entryMode),
          ),
      ],
    );
  }
}

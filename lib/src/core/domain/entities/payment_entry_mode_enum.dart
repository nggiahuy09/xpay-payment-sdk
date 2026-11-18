import 'package:flutter/widgets.dart';
import 'package:remixicon/remixicon.dart';

import '../../../base/localization/localization.dart';
import 'payment_ride_card_entity.dart';

enum PaymentEntryMode {
  token(Remix.qr_code_line),
  manualPan(Remix.keyboard_box_line),
  cardQr(Remix.qr_scan_2_line),
  chipTap(Remix.rfid_line),
  rideCard(Remix.bank_card_line);

  const PaymentEntryMode(this.icon);

  final IconData icon;

  static PaymentEntryMode? fromRemote(String? value) => switch (value) {
    'token' => PaymentEntryMode.token,
    'manual_pan' => PaymentEntryMode.manualPan,
    'card_qr' => PaymentEntryMode.cardQr,
    'chip_tap' => PaymentEntryMode.chipTap,
    'ride_card' => PaymentEntryMode.rideCard,
    _ => null,
  };

  bool get autoCapture => switch (this) {
    PaymentEntryMode.token => false,
    PaymentEntryMode.manualPan => true,
    PaymentEntryMode.cardQr => true,
    PaymentEntryMode.chipTap => true,
    PaymentEntryMode.rideCard => true,
  };

  String getTitle(XPLocaleBase locale) {
    final xpayLocale = locale.payment.xpay;
    return switch (this) {
      PaymentEntryMode.token => xpayLocale.entryModeToken,
      PaymentEntryMode.manualPan => xpayLocale.entryModeManualPan,
      PaymentEntryMode.cardQr => xpayLocale.entryModeCardQr,
      PaymentEntryMode.chipTap => xpayLocale.entryModeChipTap,
      PaymentEntryMode.rideCard => xpayLocale.entryModeRideCard,
    };
  }

  String getMethodTitle(XPLocaleBase locale, [PaymentRideCardEntity? rideCard]) {
    final xpayLocale = locale.payment.xpay;
    return switch (this) {
      PaymentEntryMode.token => xpayLocale.methodTokenTitle,
      PaymentEntryMode.manualPan => xpayLocale.methodManualPanTitle,
      PaymentEntryMode.cardQr => xpayLocale.methodCardQrTitle,
      PaymentEntryMode.chipTap => xpayLocale.methodChipTapTitle,
      PaymentEntryMode.rideCard => rideCard?.name ?? rideCard?.maskedNumber ?? xpayLocale.methodRideCardBody,
    };
  }

  String getMethodBody(XPLocaleBase locale, [PaymentRideCardEntity? rideCard]) {
    final xpayLocale = locale.payment.xpay;
    return switch (this) {
      PaymentEntryMode.token => xpayLocale.methodTokenBody,
      PaymentEntryMode.manualPan => xpayLocale.methodManualPanBody,
      PaymentEntryMode.cardQr => xpayLocale.methodCardQrBody,
      PaymentEntryMode.chipTap => xpayLocale.methodChipTapBody,
      PaymentEntryMode.rideCard => rideCard?.name == null ? xpayLocale.methodRideCardBody : '${xpayLocale.methodRideCardBody} · ${rideCard?.maskedNumber}',
    };
  }

  List<String> getAlternativeTitles(XPLocaleBase locale, bool canTapCard) {
    final xpayLocale = locale.payment.xpay;
    return [
      if (this != PaymentEntryMode.manualPan) xpayLocale.entryModeManualPanAlternative,
      if (this != PaymentEntryMode.cardQr) xpayLocale.entryModeCardQrAlternative,
      if (canTapCard && this != PaymentEntryMode.chipTap) xpayLocale.entryModeChipTapAlternative,
    ];
  }

  String toRemote() => switch (this) {
    PaymentEntryMode.token => 'token',
    PaymentEntryMode.manualPan => 'manual_pan',
    PaymentEntryMode.cardQr => 'card_qr',
    PaymentEntryMode.chipTap => 'chip_tap',
    PaymentEntryMode.rideCard => 'ride_card',
  };
}

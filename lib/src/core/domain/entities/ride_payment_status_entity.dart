import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../base/define/constant/constant.dart';
import '../../../base/localization/localization.dart';
import 'payment_method_enum.dart';

@immutable
final class RidePaymentStatusEntity with Equatable {
  const RidePaymentStatusEntity({this.payment, required this.rideStatus, required this.externalRef});

  final RidePaymentEntity? payment;
  final RideStatus rideStatus;
  final String externalRef;

  RideSettlement get settlement {
    if (payment != null) return RideSettlement.paid;

    return switch (rideStatus) {
      RideStatus.completed => RideSettlement.closedWithoutPayment,
      RideStatus.cancelled => RideSettlement.cancelled,
      RideStatus.assigned || RideStatus.riding || RideStatus.unknown => RideSettlement.open,
    };
  }

  @override
  List<Object?> get props => [payment, rideStatus, externalRef];
}

@immutable
final class RidePaymentEntity with Equatable {
  const RidePaymentEntity({required this.method, required this.paidBy, this.authId, this.amount});

  final PaymentMethod method;
  final RidePaymentPayer paidBy;
  final String? authId;
  final String? amount;

  @override
  List<Object?> get props => [method, paidBy, authId, amount];
}

enum RideStatus {
  assigned,
  riding,
  completed,
  cancelled,
  unknown;

  static RideStatus fromRemote(String? value) => switch (value) {
    'assigned' => RideStatus.assigned,
    'riding' => RideStatus.riding,
    'completed' => RideStatus.completed,
    'cancelled' => RideStatus.cancelled,
    _ => RideStatus.unknown,
  };
}

enum RidePaymentPayer {
  partner,
  cs,
  unknown;

  static RidePaymentPayer fromRemote(String? value) => switch (value) {
    'partner' => RidePaymentPayer.partner,
    'cs' => RidePaymentPayer.cs,
    _ => RidePaymentPayer.unknown,
  };

  bool get isCs => this == RidePaymentPayer.cs;
}

enum RideSettlement {
  open(null, null, null),
  paid(null, null, null),
  closedWithoutPayment(XPColorSurface.info, XPColorIcon.info, Remix.customer_service_2_line),
  cancelled(XPColorSurface.warning, XPColorIcon.warning, Remix.close_circle_line);

  const RideSettlement(this.backgroundColor, this.iconColor, this.icon);

  final Color? backgroundColor;
  final Color? iconColor;
  final IconData? icon;

  bool get isSettled => this != RideSettlement.open;

  String? getTitle(XPLocaleBase locale) {
    final outcomeLocale = locale.payment.outcome;
    return switch (this) {
      RideSettlement.open => null,
      RideSettlement.paid => null,
      RideSettlement.closedWithoutPayment => outcomeLocale.rideCompletedTitle,
      RideSettlement.cancelled => outcomeLocale.rideCancelledTitle,
    };
  }

  String? getBody(XPLocaleBase locale) {
    final outcomeLocale = locale.payment.outcome;
    return switch (this) {
      RideSettlement.open => null,
      RideSettlement.paid => null,
      RideSettlement.closedWithoutPayment => outcomeLocale.rideCompletedBody,
      RideSettlement.cancelled => outcomeLocale.rideCancelledBody,
    };
  }

  String? getLabel(XPLocaleBase locale) {
    final outcomeLocale = locale.payment.outcome;
    return switch (this) {
      RideSettlement.open => null,
      RideSettlement.paid => null,
      RideSettlement.closedWithoutPayment => outcomeLocale.rideStatusCompleted,
      RideSettlement.cancelled => outcomeLocale.rideStatusCancelled,
    };
  }
}

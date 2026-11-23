import 'package:flutter/foundation.dart';

import 'payment_entry_mode_enum.dart';
import 'payment_method_enum.dart';
import 'payment_order_entity.dart';
import 'payment_ride_card_entity.dart';
import 'payment_trip_entity.dart';

@immutable
final class PaymentSessionEntity {
  const PaymentSessionEntity({required List<PaymentEntryMode> entryModes, required this.order, this.rideCard, required this.trip, required this.method, required this.sessionToken})
    : _entryModes = entryModes;

  final List<PaymentEntryMode> _entryModes;
  final PaymentOrderEntity order;
  final PaymentRideCardEntity? rideCard;
  final PaymentTripEntity trip;
  final PaymentMethod method;
  final String sessionToken;

  List<PaymentEntryMode> get entryModes => List.unmodifiable(_entryModes);
}

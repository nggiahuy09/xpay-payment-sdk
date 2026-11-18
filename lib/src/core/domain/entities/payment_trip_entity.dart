import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class PaymentTripEntity with Equatable {
  const PaymentTripEntity({this.destination, this.pickupLocation, this.plateNumber});

  final String? destination;
  final String? pickupLocation;
  final String? plateNumber;

  @override
  List<Object?> get props => [destination, pickupLocation, plateNumber];
}

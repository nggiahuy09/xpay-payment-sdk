import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class PaymentRideCardEntity with Equatable {
  const PaymentRideCardEntity({required this.last4, this.name, required this.token});

  final String last4;
  final String? name;
  final String token;

  String get maskedNumber => '•••• $last4';

  @override
  List<Object?> get props => [last4, name, token];
}

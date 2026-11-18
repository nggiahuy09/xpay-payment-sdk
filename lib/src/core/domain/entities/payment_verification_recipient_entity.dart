import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class PaymentVerificationRecipientEntity with Equatable {
  const PaymentVerificationRecipientEntity({required this.recipientId, required this.phoneMasked});

  final String recipientId;
  final String phoneMasked;

  static String lastDigitsOf(String phoneMasked) => RegExp(r'\d+$').firstMatch(phoneMasked)?.group(0) ?? phoneMasked;

  String get phoneLastDigits => lastDigitsOf(phoneMasked);

  @override
  List<Object?> get props => [recipientId, phoneMasked];
}

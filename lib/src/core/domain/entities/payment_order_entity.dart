import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../shared/helpers/helpers.dart';
import 'create_payment_product_type_enum.dart';
import 'payment_request_reject_reason_enum.dart';

@immutable
final class PaymentOrderEntity with Equatable {
  const PaymentOrderEntity({
    required this.productType,
    this.serviceDate,
    required this.currency,
    required this.externalRef,
    required this.amount,
  });

  static const int maxExternalRefLength = 64;

  /// Same minimum as the merchant app's form. The gateway does not enforce it.
  static const int minAmount = 1000;

  final CreatePaymentProductType productType;
  final DateTime? serviceDate;
  final String currency;
  final String externalRef;
  final int amount;

  bool get isValid => violation == null;

  PaymentRequestRejectReason? get violation {
    if (amount < minAmount) return PaymentRequestRejectReason.amountBelowMinimum;
    if (currency.isEmpty) return PaymentRequestRejectReason.missingCurrency;
    if (externalRef.isEmpty || externalRef.length > maxExternalRefLength) return PaymentRequestRejectReason.invalidExternalRef;
    return null;
  }

  String get idempotencySignature => jsonEncode([
    externalRef,
    amount,
    currency,
    productType.toRemote(),
    XPHelperDateTime.format(serviceDate, format: XPDateTimeFormat.yearMonthDay),
  ]);

  @override
  List<Object?> get props => [productType, serviceDate, currency, externalRef, amount];
}

import 'dart:convert';
import 'package:fpdart/fpdart.dart';

import '../../base/extensions/extensions.dart';
import '../../base/localization/localization.dart';
import '../../core/data/datasources/remote/models/payment_session_response_model.dart';
import '../../core/domain/entities/create_payment_product_type_enum.dart';
import '../../core/domain/entities/payment_entry_mode_enum.dart';
import '../../core/domain/entities/payment_order_entity.dart';
import '../../core/domain/entities/payment_request_reject_reason_enum.dart';
import '../../core/domain/entities/payment_ride_card_entity.dart';
import '../../core/domain/entities/payment_session_entity.dart';
import '../../core/domain/entities/payment_trip_entity.dart';
import '../xpay_config.dart';
import '../xpay_payment_request.dart';

extension XPayPaymentRequestMapper on XPayPaymentRequest {
  Either<PaymentRequestRejectReason, PaymentSessionEntity> toSession() {
    final Object? json;
    try {
      json = jsonDecode(sessionJson);
    } on FormatException {
      return const Left(PaymentRequestRejectReason.invalidSessionJson);
    }
    if (json is! Map<String, dynamic>) return const Left(PaymentRequestRejectReason.invalidSessionJson);

    final PaymentSessionResponseModel model;
    try {
      model = PaymentSessionResponseModel.fromJson(json);
    } on TypeError {
      return const Left(PaymentRequestRejectReason.malformedSession);
    }

    final sessionToken = model.sessionToken?.trim() ?? '';
    if (sessionToken.isEmpty) return const Left(PaymentRequestRejectReason.missingSessionToken);

    final amount = model.amount?._toWholeAmount();
    if (amount == null) return const Left(PaymentRequestRejectReason.invalidAmount);

    final template = model.paymentTemplate;
    final order = PaymentOrderEntity(
      productType: CreatePaymentProductType.fromRemote(template?.productType),
      serviceDate: DateTime.now(),
      currency: (template?.currency ?? _defaultCurrency).trim().toUpperCase(),
      externalRef: (model.externalRef ?? template?.externalRef ?? '').trim(),
      amount: amount,
    );
    final violation = order.violation;
    if (violation != null) return Left(violation);

    final rideCard = model._rideCard;
    final entryModes = (model.entryModes ?? const <String>[])
        .mapNotNull(PaymentEntryMode.fromRemote)
        .where((mode) => mode != PaymentEntryMode.rideCard || rideCard != null)
        .toSet()
        .toList();
    if (entryModes.isEmpty) return const Left(PaymentRequestRejectReason.missingEntryModes);

    final enhancedData = template?.enhancedData;
    final trip = PaymentTripEntity(
      destination: enhancedData?.destination?.nullIfEmpty((value) => value.trim()),
      pickupLocation: enhancedData?.pickupLocation?.nullIfEmpty((value) => value.trim()),
      plateNumber: enhancedData?.plateNumber?.nullIfEmpty((value) => value.trim()),
    );
    return Right(PaymentSessionEntity(entryModes: entryModes, order: order, rideCard: rideCard, trip: trip, sessionToken: sessionToken));
  }

  static const String _defaultCurrency = 'VND';
}

extension XPayLanguageMapper on XPayLanguage {
  XPLocale toLocale() => switch (this) {
    XPayLanguage.en => XPLocale.en,
    XPayLanguage.vi => XPLocale.vi,
  };
}

extension on PaymentSessionResponseModel {
  PaymentRideCardEntity? get _rideCard {
    final last4 = rideCard?.cardLast4?.nullIfEmpty((value) => value.trim());
    final token = orderId?.nullIfEmpty((value) => value.trim());
    if (last4 == null || token == null) return null;

    return PaymentRideCardEntity(last4: last4, name: rideCard?.cardName?.nullIfEmpty((value) => value.trim()), token: token);
  }
}

extension on String {
  int? _toWholeAmount() {
    final match = RegExp(r'^(\d{1,16})(?:\.(\d{1,2}))?$').firstMatch(trim());
    final fraction = match?.group(2) ?? '';
    if (match == null || fraction.replaceAll('0', '').isNotEmpty) return null;
    return int.tryParse(match.group(1) ?? '');
  }
}

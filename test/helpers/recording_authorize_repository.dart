import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:xpay_payment_sdk/src/base/domain/domain.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/create_payment_product_type_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_authorize_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_chip_tap_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_entry_mode_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_verify_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/repositories/payment_authorize_repo.dart';

final class RecordingAuthorizeRepository extends PaymentAuthorizeRepository {
  final List<bool> _autoCaptures = [];
  final List<String> _cardTokens = [];
  final List<PaymentEntryMode> _entryModes = [];
  final List<String> _idempotencyKeys = [];
  final List<DateTime?> _serviceDates = [];

  Completer<void>? gate;

  XPException? nextFailure;

  PaymentAuthorizeEntity nextAuthorize = const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.approved);

  List<bool> get autoCaptures => List.unmodifiable(_autoCaptures);

  List<String> get cardTokens => List.unmodifiable(_cardTokens);

  List<PaymentEntryMode> get entryModes => List.unmodifiable(_entryModes);

  List<String> get idempotencyKeys => List.unmodifiable(_idempotencyKeys);

  List<DateTime?> get serviceDates => List.unmodifiable(_serviceDates);

  void clear() {
    _autoCaptures.clear();
    _cardTokens.clear();
    _entryModes.clear();
    _idempotencyKeys.clear();
    _serviceDates.clear();
    gate = null;
    nextFailure = null;
    nextAuthorize = const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.approved);
  }

  @override
  Future<Either<XPException, PaymentAuthorizeEntity>> authorize({
    required String cardToken,
    required PaymentEntryMode entryMode,
    required String amount,
    required String currency,
    required String externalRef,
    required String idempotencyKey,
    PaymentChipTapEntity? chipTap,
    CreatePaymentProductType? productType,
    DateTime? serviceDate,
    String? verificationCode,
    String? merchantId,
    String? mcc,
    String? otpRecipientId,
    bool autoCapture = false,
  }) async {
    _autoCaptures.add(autoCapture);
    _cardTokens.add(cardToken);
    _entryModes.add(entryMode);
    _idempotencyKeys.add(idempotencyKey);
    _serviceDates.add(serviceDate);
    await gate?.future;

    final failure = nextFailure;
    nextFailure = null;
    if (failure != null) return Left(failure);

    return Right(nextAuthorize);
  }

  @override
  Future<Either<XPException, PaymentVerifyEntity>> verify({required String authId, required String code, required String idempotencyKey}) async => throw UnimplementedError();

  @override
  Future<Either<XPException, PaymentVerifyEntity>> resendVerification({required String authId, String? recipientId}) async => throw UnimplementedError();

  @override
  Future<Either<XPException, PaymentVerifyEntity>> getPayment(String authId) async => throw UnimplementedError();
}

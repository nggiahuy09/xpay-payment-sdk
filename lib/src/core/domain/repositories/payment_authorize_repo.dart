import 'package:fpdart/fpdart.dart';

import '../../../base/domain/domain.dart';
import '../entities/create_payment_product_type_enum.dart';
import '../entities/payment_authorize_entity.dart';
import '../entities/payment_chip_tap_entity.dart';
import '../entities/payment_entry_mode_enum.dart';
import '../entities/payment_verify_entity.dart';

abstract class PaymentAuthorizeRepository {
  /// [idempotencyKey] is supplied by the caller rather than generated here, so retrying the same logical authorization reuses the key and the server can
  /// deduplicate it instead of authorizing the card twice.
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
    bool autoCapture,
  });

  /// [idempotencyKey] is supplied by the caller so resubmitting the same code replays the original outcome instead of consuming another server-side verification attempt.
  Future<Either<XPException, PaymentVerifyEntity>> verify({required String authId, required String code, required String idempotencyKey});

  /// Sends a fresh code for a sale still awaiting verification, invalidating the previous one, and returns the refreshed authorization.
  ///
  /// Takes no idempotency key: unlike [verify], a repeat call must issue a genuinely new code rather than replay the previous send. The server's cooldown and
  /// per-sale cap bound the repeats instead.
  Future<Either<XPException, PaymentVerifyEntity>> resendVerification({required String authId, String? recipientId});

  Future<Either<XPException, PaymentVerifyEntity>> getPayment(String authId);
}

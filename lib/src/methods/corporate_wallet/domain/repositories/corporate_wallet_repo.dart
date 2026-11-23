import 'package:fpdart/fpdart.dart';

import '../../../../base/domain/domain.dart';
import '../../../../core/domain/entities/create_payment_product_type_enum.dart';
import '../entities/corporate_wallet_challenge_entity.dart';
import '../entities/corporate_wallet_otp_channel_entity.dart';
import '../entities/corporate_wallet_otp_method_enum.dart';
import '../entities/corporate_wallet_payment_entity.dart';
import '../entities/payment_intent_entity.dart';

abstract class CorporateWalletRepository {
  Future<Either<XPException, List<CorporateWalletOtpChannelEntity>>> getOtpChannels();

  Future<Either<XPException, CorporateWalletChallengeEntity>> requestOtp(CorporateWalletOtpMethod method, String recipientId);

  Future<Either<XPException, CorporateWalletPaymentEntity>> verifyOtp({required String walletPaymentId, required String code});

  Future<Either<XPException, PaymentIntentEntity>> createIntent({
    required CreatePaymentProductType productType,
    required String currency,
    required String externalRef,
    required String idempotencyKey,
    required int amount,
  });

  Future<Either<XPException, PaymentIntentEntity>> getIntent(String intentId);

  Future<Either<XPException, PaymentIntentEntity>> cancelIntent(String intentId);
}

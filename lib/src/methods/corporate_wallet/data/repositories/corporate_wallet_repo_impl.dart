import 'package:fpdart/fpdart.dart';

import '../../../../api/xpay_payment_result.dart';
import '../../../../base/domain/domain.dart';
import '../../../../core/domain/entities/create_payment_product_type_enum.dart';
import '../../../../di/di.dart';
import '../../domain/entities/corporate_wallet_challenge_entity.dart';
import '../../domain/entities/corporate_wallet_otp_channel_entity.dart';
import '../../domain/entities/corporate_wallet_otp_method_enum.dart';
import '../../domain/entities/corporate_wallet_payment_entity.dart';
import '../../domain/entities/payment_intent_entity.dart';
import '../../domain/repositories/corporate_wallet_repo.dart';
import '../datasources/remote/corporate_wallet_remote_datasrc.dart';
import '../datasources/remote/models/corporate_wallet_payment_models.dart';
import '../datasources/remote/models/corporate_wallet_payment_request_model.dart';
import '../datasources/remote/models/corporate_wallet_verify_request_model.dart';
import '../datasources/remote/models/payment_intent_create_request_model.dart';
import '../datasources/remote/models/payment_intent_response_model.dart';
import 'corporate_wallet_repo_mapper.dart';

final class CorporateWalletRepositoryImpl extends CorporateWalletRepository {
  final _remote = getIt.get<CorporateWalletRemoteDatasource>();

  static const String _kOtherProductType = 'other';
  static const XPUnknownException _kUnexpectedResponse = XPUnknownException(errorCode: XPayErrorCode.unexpectedResponse);

  @override
  Future<Either<XPException, List<CorporateWalletOtpChannelEntity>>> getOtpChannels() async {
    try {
      final models = await _remote.getRecipients();
      return Right(models.toChannels());
    } on XPException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(XPUnknownException(error: e));
    }
  }

  @override
  Future<Either<XPException, CorporateWalletChallengeEntity>> requestOtp(CorporateWalletOtpMethod method, String recipientId) async {
    final remoteMethod = method.toRemote();
    if (remoteMethod == null) return const Left(_kUnexpectedResponse);

    try {
      final model = await _remote.requestPayment(CorporateWalletPaymentRequestModel(remoteMethod, recipientId));
      final challenge = model.toEntity();
      return challenge == null ? const Left(_kUnexpectedResponse) : Right(challenge);
    } on XPException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(XPUnknownException(error: e));
    }
  }

  @override
  Future<Either<XPException, CorporateWalletPaymentEntity>> verifyOtp({required String walletPaymentId, required String code}) async {
    try {
      final model = await _remote.verify(walletPaymentId, CorporateWalletVerifyRequestModel(code));
      return Right(model.toEntity());
    } on XPApiException catch (e) {
      final details = e.details;
      return Left(details is CorporateWalletOtpErrorDetailsModel ? e.withDetails(details.toEntity()) : e);
    } on XPException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(XPUnknownException(error: e));
    }
  }

  @override
  Future<Either<XPException, PaymentIntentEntity>> createIntent({
    required CreatePaymentProductType productType,
    required String currency,
    required String externalRef,
    required String idempotencyKey,
    required int amount,
  }) async {
    final request = PaymentIntentCreateRequestModel(
      amount: amount.toString(),
      currency: currency,
      externalRef: externalRef,
      productType: productType.toRemote() ?? _kOtherProductType,
    );
    return _guardIntent(() => _remote.createIntent(request: request, idempotencyKey: idempotencyKey));
  }

  @override
  Future<Either<XPException, PaymentIntentEntity>> getIntent(String intentId) => _guardIntent(() => _remote.getIntent(intentId));

  @override
  Future<Either<XPException, PaymentIntentEntity>> cancelIntent(String intentId) => _guardIntent(() => _remote.cancelIntent(intentId));

  Future<Either<XPException, PaymentIntentEntity>> _guardIntent(Future<PaymentIntentResponseModel> Function() request) async {
    try {
      final intent = (await request.call()).toEntity();
      return intent == null ? const Left(_kUnexpectedResponse) : Right(intent);
    } on XPException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(XPUnknownException(error: e));
    }
  }
}

import 'package:fpdart/fpdart.dart';

import '../../../base/domain/domain.dart';
import '../../../di/di.dart';
import '../../domain/entities/create_payment_product_type_enum.dart';
import '../../domain/entities/payment_authorize_entity.dart';
import '../../domain/entities/payment_chip_tap_entity.dart';
import '../../domain/entities/payment_entry_mode_enum.dart';
import '../../domain/entities/payment_verify_entity.dart';
import '../../domain/repositories/payment_authorize_repo.dart';
import '../datasources/remote/models/payment_authorize_request_model.dart';
import '../datasources/remote/models/payment_resend_verification_request_model.dart';
import '../datasources/remote/models/payment_verify_request_model.dart';
import '../datasources/remote/payment_authorize_remote_datasrc.dart';
import 'payment_authorize_repo_mapper.dart';
import 'payment_verify_repo_mapper.dart';

final class PaymentAuthorizeRepositoryImpl extends PaymentAuthorizeRepository {
  final _remote = getIt.get<PaymentAuthorizeRemoteDatasource>();

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
    try {
      final request = PaymentAuthorizeRequestModel(
        cardToken: cardToken,
        entryMode: entryMode.toRemote(),
        amount: amount,
        currency: currency,
        externalRef: externalRef,
        chipTap: chipTap?.toModel(),
        verificationCode: verificationCode,
        merchantId: merchantId,
        mcc: mcc,
        otpRecipientId: otpRecipientId,
        productType: productType?.toRemote(),
        serviceDate: serviceDate?.toRemoteServiceDate(),
        autoCapture: autoCapture,
      );

      final model = await _remote.authorize(request: request, idempotencyKey: idempotencyKey);
      return Right(model.toEntity());
    } on XPException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(XPUnknownException(error: e));
    }
  }

  @override
  Future<Either<XPException, PaymentVerifyEntity>> verify({required String authId, required String code, required String idempotencyKey}) async {
    try {
      final request = PaymentVerifyRequestModel(code: code);
      final model = await _remote.verify(authId: authId, request: request, idempotencyKey: idempotencyKey);
      return Right(model.toEntity());
    } on XPException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(XPUnknownException(error: e));
    }
  }

  @override
  Future<Either<XPException, PaymentVerifyEntity>> resendVerification({required String authId, String? recipientId}) async {
    try {
      final model = await _remote.resendVerification(authId, PaymentResendVerificationRequestModel(recipientId));
      return Right(model.toEntity());
    } on XPException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(XPUnknownException(error: e));
    }
  }
}

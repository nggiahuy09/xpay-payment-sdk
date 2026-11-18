import 'package:fpdart/fpdart.dart';

import '../../../base/domain/domain.dart';
import '../entities/payment_verify_entity.dart';
import '../repositories/payment_authorize_repo.dart';

final class VerifyPaymentUseCase with XPUseCase<VerifyPaymentInput, PaymentVerifyEntity> {
  const VerifyPaymentUseCase(this._repository);

  final PaymentAuthorizeRepository _repository;

  @override
  Future<Either<XPException, PaymentVerifyEntity>> execute(VerifyPaymentInput input) {
    return _repository.verify(authId: input.authId, code: input.code, idempotencyKey: input.idempotencyKey);
  }
}

final class VerifyPaymentInput implements XPLoggable {
  const VerifyPaymentInput({required this.authId, required this.code, required this.idempotencyKey});

  final String authId;
  final String code;

  /// Supplied by the caller so resubmitting the same code replays the original outcome instead of consuming another verification attempt.
  final String idempotencyKey;

  @override
  Map<String, dynamic> toLog() => {'auth_id': authId};
}

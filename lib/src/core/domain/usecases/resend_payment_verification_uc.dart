import 'package:fpdart/fpdart.dart';

import '../../../base/domain/domain.dart';
import '../entities/payment_verify_entity.dart';
import '../repositories/payment_authorize_repo.dart';

final class ResendPaymentVerificationUseCase with XPUseCase<ResendPaymentVerificationInput, PaymentVerifyEntity> {
  const ResendPaymentVerificationUseCase(this._repository);

  final PaymentAuthorizeRepository _repository;

  @override
  Future<Either<XPException, PaymentVerifyEntity>> execute(ResendPaymentVerificationInput input) {
    return _repository.resendVerification(authId: input.authId, recipientId: input.recipientId);
  }
}

final class ResendPaymentVerificationInput implements XPLoggable {
  const ResendPaymentVerificationInput({required this.authId, this.recipientId});

  final String authId;
  final String? recipientId;

  @override
  Map<String, dynamic> toLog() => {'auth_id': authId, if (recipientId != null) 'recipient_id': recipientId};
}

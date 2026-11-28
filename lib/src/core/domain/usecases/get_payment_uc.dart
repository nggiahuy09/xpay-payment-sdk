import 'package:fpdart/fpdart.dart';

import '../../../base/domain/domain.dart';
import '../entities/payment_verify_entity.dart';
import '../repositories/payment_authorize_repo.dart';

final class GetPaymentUseCase with XPUseCase<String, PaymentVerifyEntity> {
  const GetPaymentUseCase(this._repository);

  final PaymentAuthorizeRepository _repository;

  @override
  Future<Either<XPException, PaymentVerifyEntity>> execute(String input) => _repository.getPayment(input);
}

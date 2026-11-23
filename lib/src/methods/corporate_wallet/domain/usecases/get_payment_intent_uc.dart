import 'package:fpdart/fpdart.dart';

import '../../../../base/domain/domain.dart';
import '../entities/payment_intent_entity.dart';
import '../repositories/corporate_wallet_repo.dart';

final class GetPaymentIntentUseCase with XPUseCase<String, PaymentIntentEntity> {
  const GetPaymentIntentUseCase(this._repository);

  final CorporateWalletRepository _repository;

  @override
  Future<Either<XPException, PaymentIntentEntity>> execute(String input) => _repository.getIntent(input);
}

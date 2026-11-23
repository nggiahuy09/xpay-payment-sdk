import 'package:fpdart/fpdart.dart';

import '../../../../base/domain/domain.dart';
import '../../../../core/domain/entities/create_payment_product_type_enum.dart';
import '../entities/payment_intent_entity.dart';
import '../repositories/corporate_wallet_repo.dart';

final class CreatePaymentIntentUseCase with XPUseCase<CreatePaymentIntentInput, PaymentIntentEntity> {
  const CreatePaymentIntentUseCase(this._repository);

  final CorporateWalletRepository _repository;

  @override
  Future<Either<XPException, PaymentIntentEntity>> execute(CreatePaymentIntentInput input) => _repository.createIntent(
    productType: input.productType,
    currency: input.currency,
    externalRef: input.externalRef,
    idempotencyKey: input.idempotencyKey,
    amount: input.amount,
  );
}

final class CreatePaymentIntentInput implements XPLoggable {
  const CreatePaymentIntentInput({required this.productType, required this.currency, required this.externalRef, required this.idempotencyKey, required this.amount});

  final CreatePaymentProductType productType;
  final String currency;
  final String externalRef;
  final String idempotencyKey;
  final int amount;

  @override
  Map<String, dynamic> toLog() => {'product_type': productType.toRemote(), 'currency': currency, 'external_ref': externalRef, 'amount': amount};
}

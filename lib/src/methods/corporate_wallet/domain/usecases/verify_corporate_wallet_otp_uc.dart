import 'package:fpdart/fpdart.dart';

import '../../../../base/domain/domain.dart';
import '../entities/corporate_wallet_payment_entity.dart';
import '../repositories/corporate_wallet_repo.dart';

final class VerifyCorporateWalletOtpUseCase with XPUseCase<VerifyCorporateWalletOtpInput, CorporateWalletPaymentEntity> {
  const VerifyCorporateWalletOtpUseCase(this._repository);

  final CorporateWalletRepository _repository;

  @override
  Future<Either<XPException, CorporateWalletPaymentEntity>> execute(VerifyCorporateWalletOtpInput input) {
    return _repository.verifyOtp(walletPaymentId: input.walletPaymentId, code: input.code);
  }
}

final class VerifyCorporateWalletOtpInput implements XPLoggable {
  const VerifyCorporateWalletOtpInput({required this.walletPaymentId, required this.code});

  final String walletPaymentId;
  final String code;

  @override
  Map<String, dynamic> toLog() => {'wallet_payment_id': walletPaymentId};
}

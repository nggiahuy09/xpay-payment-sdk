import 'package:fpdart/fpdart.dart';

import '../../../../base/domain/domain.dart';
import '../entities/corporate_wallet_challenge_entity.dart';
import '../entities/corporate_wallet_otp_method_enum.dart';
import '../repositories/corporate_wallet_repo.dart';

final class RequestCorporateWalletOtpUseCase with XPUseCase<RequestCorporateWalletOtpInput, CorporateWalletChallengeEntity> {
  const RequestCorporateWalletOtpUseCase(this._repository);

  final CorporateWalletRepository _repository;

  @override
  Future<Either<XPException, CorporateWalletChallengeEntity>> execute(RequestCorporateWalletOtpInput input) => _repository.requestOtp(input.method, input.recipientId);
}

final class RequestCorporateWalletOtpInput implements XPLoggable {
  const RequestCorporateWalletOtpInput(this.method, this.recipientId);

  final CorporateWalletOtpMethod method;
  final String recipientId;

  @override
  Map<String, dynamic> toLog() => {'method': method.toRemote(), 'recipient_id': recipientId};
}

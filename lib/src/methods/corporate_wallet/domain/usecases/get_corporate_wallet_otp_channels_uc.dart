import 'package:fpdart/fpdart.dart';

import '../../../../base/domain/domain.dart';
import '../entities/corporate_wallet_otp_channel_entity.dart';
import '../repositories/corporate_wallet_repo.dart';

final class GetCorporateWalletOtpChannelsUseCase with XPUseCase<void, List<CorporateWalletOtpChannelEntity>> {
  const GetCorporateWalletOtpChannelsUseCase(this._repository);

  final CorporateWalletRepository _repository;

  @override
  Future<Either<XPException, List<CorporateWalletOtpChannelEntity>>> execute(void input) => _repository.getOtpChannels();
}

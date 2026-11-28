import 'package:fpdart/fpdart.dart';

import '../../../base/domain/domain.dart';
import '../entities/ride_payment_status_entity.dart';
import '../repositories/ride_payment_repo.dart';

final class GetRidePaymentStatusUseCase with XPUseCase<void, RidePaymentStatusEntity> {
  const GetRidePaymentStatusUseCase(this._repository);

  final RidePaymentRepository _repository;

  @override
  Future<Either<XPException, RidePaymentStatusEntity>> execute(void input) => _repository.getStatus();
}

import 'package:fpdart/fpdart.dart';

import '../../../base/domain/domain.dart';
import '../../../di/di.dart';
import '../../domain/entities/ride_payment_status_entity.dart';
import '../../domain/repositories/ride_payment_repo.dart';
import '../datasources/remote/ride_payment_remote_datasrc.dart';
import 'ride_payment_repo_mapper.dart';

final class RidePaymentRepositoryImpl extends RidePaymentRepository {
  final _remote = getIt.get<RidePaymentRemoteDatasource>();

  @override
  Future<Either<XPException, RidePaymentStatusEntity>> getStatus() async {
    try {
      final model = await _remote.getStatus();
      return Right(model.toEntity());
    } on XPException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(XPUnknownException(error: e));
    }
  }
}

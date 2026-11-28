import 'package:fpdart/fpdart.dart';

import '../../../base/domain/domain.dart';
import '../entities/ride_payment_status_entity.dart';

abstract class RidePaymentRepository {
  Future<Either<XPException, RidePaymentStatusEntity>> getStatus();
}

import 'package:fpdart/fpdart.dart';

import '../../../../base/domain/domain.dart';
import '../../../../di/di.dart';
import '../../domain/entities/chip_tap_cryptogram_entity.dart';
import '../../domain/entities/chip_tap_prepare_entity.dart';
import '../../domain/repositories/chip_tap_repo.dart';
import '../datasources/remote/chip_tap_remote_datasrc.dart';
import '../datasources/remote/models/chip_tap_cryptogram_request_model.dart';
import '../datasources/remote/models/chip_tap_prepare_request_model.dart';
import 'chip_tap_repo_mapper.dart';

final class ChipTapRepositoryImpl extends ChipTapRepository {
  final _remote = getIt.get<ChipTapRemoteDatasource>();

  @override
  Future<Either<XPException, ChipTapPrepareEntity>> prepare({required String chipUid}) async {
    try {
      final model = await _remote.prepare(request: ChipTapPrepareRequestModel(chipUid: chipUid));
      return Right(model.toEntity());
    } on XPException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(XPUnknownException(error: e));
    }
  }

  @override
  Future<Either<XPException, ChipTapCryptogramEntity>> sign({required String chipUid, required int counter}) async {
    try {
      final request = ChipTapCryptogramRequestModel(chipUid: chipUid, counter: counter);
      final model = await _remote.sign(request: request);
      return Right(model.toEntity());
    } on XPException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(XPUnknownException(error: e));
    }
  }
}

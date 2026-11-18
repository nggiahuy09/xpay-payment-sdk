import 'package:fpdart/fpdart.dart';

import '../../../../base/domain/domain.dart';
import '../entities/chip_tap_prepare_entity.dart';
import '../repositories/chip_tap_repo.dart';

final class PrepareChipTapUseCase with XPUseCase<PrepareChipTapInput, ChipTapPrepareEntity> {
  const PrepareChipTapUseCase(this._repository);

  final ChipTapRepository _repository;

  @override
  Future<Either<XPException, ChipTapPrepareEntity>> execute(PrepareChipTapInput input) {
    return _repository.prepare(chipUid: input.chipUid);
  }
}

final class PrepareChipTapInput implements XPLoggable {
  const PrepareChipTapInput(this.chipUid);

  final String chipUid;

  @override
  Map<String, dynamic> toLog() => {'chip_uid': chipUid};
}

import 'package:fpdart/fpdart.dart';

import '../../../../base/domain/domain.dart';
import '../entities/chip_tap_cryptogram_entity.dart';
import '../repositories/chip_tap_repo.dart';

final class SignChipTapUseCase with XPUseCase<SignChipTapInput, ChipTapCryptogramEntity> {
  const SignChipTapUseCase(this._repository);

  final ChipTapRepository _repository;

  @override
  Future<Either<XPException, ChipTapCryptogramEntity>> execute(SignChipTapInput input) {
    return _repository.sign(chipUid: input.chipUid, counter: input.counter);
  }
}

final class SignChipTapInput implements XPLoggable {
  const SignChipTapInput({required this.chipUid, required this.counter});

  final String chipUid;
  final int counter;

  @override
  Map<String, dynamic> toLog() => {'chip_uid': chipUid, 'counter': counter};
}

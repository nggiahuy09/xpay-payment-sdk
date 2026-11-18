import 'package:fpdart/fpdart.dart';

import '../../../../base/domain/domain.dart';
import '../entities/chip_tap_cryptogram_entity.dart';
import '../entities/chip_tap_prepare_entity.dart';

abstract class ChipTapRepository {
  /// Exchanges [chipUid] for this tap's sector keys, layout, and the issuer's record of the card.
  ///
  /// Authenticated as the merchant operator — the terminal never holds a platform credential, so it cannot reach the admin key endpoint that would also yield `auth_key`.
  Future<Either<XPException, ChipTapPrepareEntity>> prepare({required String chipUid});

  /// Signs [counter] for [chipUid], yielding the cryptogram `authorize` requires.
  ///
  /// [counter] must be the value read back off the chip after the increment, never a predicted one — the server records the highest counter it has verified, so a
  /// value the card never took reads as a replay.
  Future<Either<XPException, ChipTapCryptogramEntity>> sign({required String chipUid, required int counter});
}

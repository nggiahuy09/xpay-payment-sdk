import 'package:fpdart/fpdart.dart';

import '../exceptions/xp_exception.dart';

/// Base contract for all feature use cases.
///
/// A use case performs a single business operation by calling one or more
/// repositories and returns `Either<XPException, Output>`. Use cases MUST NOT
/// call other use cases.
mixin XPUseCase<Input, Output> {
  Future<Either<XPException, Output>> execute(Input input);
}

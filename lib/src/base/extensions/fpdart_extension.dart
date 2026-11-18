import 'package:fpdart/fpdart.dart';

extension XPEitherResultExtension<L, R> on Either<L, R> {
  /// Returns the left value or throws a [StateError] if it's not present.
  L getLeftOrThrow() => fold((l) => l, (r) => throw StateError('Expected Left but got Right: $r'));

  /// Returns the right value or throws a StateError if it's not present.
  ///
  /// Similar to [getOrElse] but throws a [StateError] instead of returning a default value.
  R getOrThrow() => fold((l) => throw StateError('Expected Right but got Left: $l'), (r) => r);

  R? getOrNull() => fold((l) => null, (r) => r);

  L? getLeftOrNull() => fold((l) => l, (r) => null);
}

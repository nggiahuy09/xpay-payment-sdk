import 'package:collection/collection.dart';

extension SetComparisonExtension<T> on Set<T> {
  static const _equality = DeepCollectionEquality();

  /// Is used to deep compare two Set. Use this if you want to compare two unmodifiable set,
  /// which were created to prevent unwanted modification to the original set, e.g., in a state class.
  bool equals(Set<T> other) => _equality.equals(this, other);
}

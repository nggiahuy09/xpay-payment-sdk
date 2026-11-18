extension IterableExtension<T> on Iterable<T> {
  /// Returns the first element that satisfies the given predicate [test].
  ///
  /// Iterates through the elements of the iterable and returns the first one
  /// that satisfies [test]. If no element satisfies [test], returns null.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final even = numbers.firstWhereOrNull((n) => n.isEven); // Returns 2
  /// final negative = numbers.firstWhereOrNull((n) => n < 0); // Returns null
  /// ```
  T? firstWhereOrNull(bool Function(T element) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Maps each element using [transform], and filters out null results.
  ///
  /// Works like `map().where((e) => e != null)` but in one pass and type-safe.
  ///
  ///
  /// **Only works with synchronous operations**.
  Iterable<E> mapNotNull<E>(E? Function(T element) transform) sync* {
    for (final element in this) {
      final result = transform(element);
      if (result != null) yield result;
    }
  }

  /// Returns [null] if this iterable is empty. Otherwise, return this iterable.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final even = numbers.nullIfEmpty(); // Returns [1, 2, 3, 4, 5]
  /// final empty = <int>[].nullIfEmpty(); // Returns null
  /// ```
  Iterable<T>? nullIfEmpty() => isEmpty ? null : this;

  /// Returns the iterable if it is not empty. Otherwise, return the result of [ifEmpty].
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final even = numbers.valueIfEmpty(() => [0]); // Returns [1, 2, 3, 4, 5]
  /// final empty = <int>[].valueIfEmpty(() => [0]); // Returns [0]
  /// ```
  Iterable<T> valueIfEmpty(Iterable<T> Function() ifEmpty) => isEmpty ? ifEmpty.call() : this;

  /// Returns the number of elements in this iterable that satisfy the given predicate [test].
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final evenCount = numbers.countWhere((n) => n.isEven); // Returns 2
  /// final negativeCount = numbers.countWhere((n) => n < 0); // Returns 0
  /// ```
  int countWhere(bool Function(T element) test) => where(test).length;
}

extension NullableIterableExtension<T> on Iterable<T?> {
  /// Filters out null elements from the iterable
  ///
  /// Returns a new lazy iterable containing only the non-null elements and is type-safe.
  Iterable<T> whereNotNull() => where((element) => element != null).cast<T>();
}

extension StringIterableExtension on Iterable<String> {
  String joinWithLast({required String separator, required String lastSeparator}) {
    if (length < 2) return join();
    return '${take(length - 1).join(separator)}$lastSeparator$last';
  }
}

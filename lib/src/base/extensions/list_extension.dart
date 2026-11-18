import 'dart:math';

import 'package:collection/collection.dart' as collection;

extension ListModifyExtension<T> on List<T> {
  /// Updates the element at [index] with [value] if the index is valid
  ///
  /// - Only performs the update when [index] is between 0 (inclusive) and [length] (exclusive)
  void updateAt(int index, T value) {
    if (index >= 0 && index < length) {
      this[index] = value;
    }
  }

  /// Expands the list (if needed) and fills the range from [start] to [end] with [fillValue].
  ///
  /// - If [end] exceeds the current [length], the list is expanded with [fillValue] elements
  /// - When [start] > [end], the values are swapped to create a valid range.
  /// - [fillValue] must be provided if [T]] is non-nullable
  /// - Both [start] and [end] must be non-negative
  void expandFillRange(int start, int end, [T? fillValue]) {
    assert(start >= 0, 'start must be ≥ 0 (got $start)');
    assert(end >= 0, 'end must be ≥ 0 (got $end)');
    assert(null is T || fillValue != null, 'fillValue must be provided since $T is non-nullable');

    if (start > end) {
      final tmp = start;
      start = end;
      end = tmp;
    }

    if (end > length) {
      final extraLength = end - length;
      addAll(List<T>.filled(extraLength, fillValue as T));
    }
    fillRange(start, end, fillValue);
  }

  /// Returns an iterable containing the first [length] elements from the list.
  ///
  /// This is equivalent to calling [take] on the list. If [length] is greater than the list's length, all elements are returned. If [length] is 0, an empty iterable is returned.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// final first3 = list.firstRange(3); // [1, 2, 3]
  /// final first10 = list.firstRange(10); // [1, 2, 3, 4, 5]
  /// final first0 = list.firstRange(0); // []
  /// final emptyList = <int>[];
  /// final fromEmpty = emptyList.firstRange(2); // []
  /// ```
  Iterable<T> firstCount(int length) => take(length);

  /// Returns an iterable containing all elements except the last [lastCount] elements, ultimately the reversed version of [firstCount].
  ///
  /// If [lastCount] is greater than or equal to the list's length, an empty iterable is returned. If [lastCount] is 0, all elements are returned.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// final first3 = list.firstRangeExclude(2); // [1, 2, 3]
  /// final first0 = list.firstRangeExclude(5); // []
  /// final all = list.firstRangeExclude(0); // [1, 2, 3, 4, 5]
  /// ```
  Iterable<T> firstCountExclude(int lastCount) => take(max(0, length - lastCount));

  /// Returns an iterable containing the last [length] elements from the list,
  ///
  /// If [length] is greater than or equal to the list's length, all elements are returned.
  /// If [length] is 0 or negative, an empty iterable is returned.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// final last3 = list.lastRange(3); // [3, 4, 5]
  /// final last10 = list.lastRange(10); // [1, 2, 3, 4, 5]
  /// final last0 = list.lastRange(0); // []
  /// final emptyList = <int>[];
  /// final fromEmpty = emptyList.lastRange(2); // []
  /// ```
  Iterable<T> lastCount(int length) {
    final skipCount = this.length - length;
    return skipCount < 0 ? this : skip(skipCount);
  }

  /// Returns an iterable containing all elements except the first [firstCount] elements, ultimately the reversed version of [lastCount].
  ///
  /// This is equivalent to calling [skip] on the list. If [firstCount] is greater than or equal to the list's length, an empty iterable is returned. If [firstCount] is 0,
  /// all elements are returned.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// final last3 = list.lastRangeExclude(2); // [3, 4, 5]
  /// final last0 = list.lastRangeExclude(5); // []
  /// final all = list.lastRangeExclude(0); // [1, 2, 3, 4, 5]
  /// ```
  Iterable<T> lastCountExclude(int firstCount) => skip(firstCount);

  /// Replaces elements at the beginning of the list with the provided [values].
  ///
  /// Uses Dart's `replaceRange()` method to replace elements from index 0 to `min(length, values.length)`. If [values] contains more elements than the
  /// current list length, the list will be expanded to accommodate all values.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// list.replaceFirstRange([10, 20]); // list becomes [10, 20, 3, 4, 5]
  ///
  /// final shortList = [1, 2];
  /// shortList.replaceFirstRange([10, 20, 30]); // shortList becomes [10, 20, 30]
  ///
  /// final emptyList = <int>[];
  /// emptyList.replaceFirstRange([10, 20]); // emptyList becomes [10, 20]
  ///
  /// final list2 = [1, 2, 3];
  /// list2.replaceFirstRange([]); // list2 remains [1, 2, 3]
  /// ```
  void replaceFirstRange(Iterable<T> values) => replaceRange(0, min(length, values.length), values);

  /// Replaces elements at the end of the list with the provided [values].
  ///
  /// Uses Dart's `replaceRange()` method to replace elements from `max(0, length - values.length)` to the end of the list. If [values]
  /// contains more elements than the current list length, the list will be expanded to accommodate all values.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// list.replaceLastRange([10, 20]); // list becomes [1, 2, 3, 10, 20]
  ///
  /// final shortList = [1, 2];
  /// shortList.replaceLastRange([10, 20, 30]); // shortList becomes [10, 20, 30]
  ///
  /// final emptyList = <int>[];
  /// emptyList.replaceLastRange([10, 20]); // emptyList becomes [10, 20]
  ///
  /// final list2 = [1, 2, 3];
  /// list2.replaceLastRange([]); // list2 remains [1, 2, 3]
  /// ```
  void replaceLastRange(Iterable<T> values) => replaceRange(max(0, length - values.length), length, values);

  /// Returns [null] if this list is empty. Otherwise, return this list.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// final even = list.nullIfEmpty(); // Returns [1, 2, 3, 4, 5]
  /// final empty = <int>[].nullIfEmpty(); // Returns null
  /// ```
  List<T>? nullIfEmpty() => isEmpty ? null : this;

  /// Returns the list if it is not empty. Otherwise, return the result of [ifEmpty] function.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// final even = list.valueIfEmpty(() => []); // Returns [1, 2, 3, 4, 5]
  /// final empty = <int>[].valueIfEmpty(() => []); // Returns []
  /// ```
  List<T>? valueIfEmpty(List<T> Function() ifEmpty) => isEmpty ? ifEmpty.call() : this;
}

extension ListComparisonExtension<T> on List<T> {
  static const _equality = collection.DeepCollectionEquality();
  static const _unorderedEquality = collection.UnorderedIterableEquality();

  /// Is used to deep compare two List. Use this if you want to compare two unmodifiable list,
  /// which were created to prevent unwanted modification to the original list, e.g., in a state class.
  bool equals(List<T> other, [bool unordered = false]) => unordered ? _unorderedEquality.equals(this, other) : _equality.equals(this, other);
}

extension ListSortingExtension<T> on List<T> {
  /// Sorts the list using the merge sort algorithm, to guarantee its stability.
  void mergeSort([int Function(T a, T b)? compare]) => collection.mergeSort<T>(this, compare: compare);
}

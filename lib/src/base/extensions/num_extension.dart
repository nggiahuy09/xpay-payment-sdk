extension NumCompareExtension on num {
  bool between(num lower, num upper, [NumBetweenComparison method = NumBetweenComparison.includeBoth]) {
    switch (method) {
      case NumBetweenComparison.includeBoth:
        return this >= lower && this <= upper;
      case NumBetweenComparison.excludeBoth:
        return this > lower && this < upper;
      case NumBetweenComparison.excludeLower:
        return this > lower && this <= upper;
      case NumBetweenComparison.excludeUpper:
        return this >= lower && this < upper;
    }
  }
}

extension FlexibleNumExtension<T extends num> on T {
  T? nullIf(bool Function(T value) test) => test.call(this) ? null : this;
}

extension TimestampConverterExtension on int {
  /// Assuming [this] is an integer representing timestamp in milliseconds at UTC (GMT+0).
  ///
  /// Then convert it to local timezone.
  DateTime toLocalDateTime() => DateTime.fromMillisecondsSinceEpoch(this, isUtc: true).toLocal();

  /// Assuming [this] is an integer representing timestamp in milliseconds at UTC. Convert it to a specified offset.
  ///
  /// If you somehow need the offset, use the [offset] passed to this method. Don't use [timezoneOffset] from the result [DateTime] object.
  DateTime asUtcWithOffset(Duration offset) => DateTime.fromMillisecondsSinceEpoch(this, isUtc: true).add(offset);
}

enum NumBetweenComparison {
  excludeLower,
  excludeUpper,
  excludeBoth,
  includeBoth,
}

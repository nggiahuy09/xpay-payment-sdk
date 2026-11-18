import '../../shared/helpers/helpers.dart';

extension DateTimeComparisonExtension on DateTime {
  /// Checks if this date is yesterday compared to the given date
  ///
  /// Returns true if this date is exactly one day before [other]
  ///
  /// Example:
  /// ```dart
  /// final today = DateTime(2024, 1, 15);
  /// final yesterday = DateTime(2024, 1, 14);
  /// print(yesterday.isYesterdayOf(today)); // true
  /// ```
  bool isYesterdayOf(DateTime other) {
    final thisDate = DateTime(year, month, day);
    final otherDate = DateTime(other.year, other.month, other.day);
    return thisDate.difference(otherDate).inDays == -1;
  }

  /// Checks if this date is tomorrow compared to the given date
  ///
  /// Returns true if this date is exactly one day after [other]
  ///
  /// Example:
  /// ```dart
  /// final today = DateTime(2024, 1, 15);
  /// final tomorrow = DateTime(2024, 1, 16);
  /// print(tomorrow.isTomorrowOf(today)); // true
  /// ```
  bool isTomorrowOf(DateTime other) {
    final thisDate = DateTime(year, month, day);
    final otherDate = DateTime(other.year, other.month, other.day);
    return thisDate.difference(otherDate).inDays == 1;
  }

  /// Checks if this date comes before another date, ignoring time
  ///
  /// Returns true if this date is before [other], comparing only dates
  ///
  /// Example:
  /// ```dart
  /// final date1 = DateTime(2024, 1, 15, 14, 30); // Jan 15, 2024 14:30
  /// final date2 = DateTime(2024, 1, 16, 9, 0);   // Jan 16, 2024 9:00
  /// print(date1.isBeforeInDays(date2)); // true
  /// ```
  bool isBeforeInDays(DateTime other) {
    final thisDate = DateTime(year, month, day);
    final otherDate = DateTime(other.year, other.month, other.day);
    return thisDate.isBefore(otherDate);
  }

  /// Checks if this date comes before now, ignoring time
  ///
  /// Returns true if this date is before now, comparing only dates
  bool isBeforeNowInDays() => isBeforeInDays(DateTime.now());

  /// Checks if this date comes after another date, ignoring time
  ///
  /// Returns true if this date is after [other], comparing only dates
  ///
  /// Example:
  /// ```dart
  /// final date1 = DateTime(2024, 1, 15);
  /// final date2 = DateTime(2024, 1, 14);
  /// print(date1.isAfterInDays(date2)); // true
  /// ```
  bool isAfterInDays(DateTime other) {
    final thisDate = DateTime(year, month, day);
    final otherDate = DateTime(other.year, other.month, other.day);
    return thisDate.isAfter(otherDate);
  }

  /// Checks if this date comes after now, ignoring time
  ///
  /// Returns true if this date is after now, comparing only dates
  bool isAfterNowInDays() => isAfterInDays(DateTime.now());

  /// Returns the later date between this date and [other]. Is order-agnostic.
  DateTime noSoonerThan(DateTime other) => isBefore(other) ? other : this;

  /// Returns the later date between this date and now.
  DateTime noSoonerThanNow() => noSoonerThan(DateTime.now());

  /// Returns the earlier date between this date and [other]. Is order-agnostic.
  DateTime noLaterThan(DateTime other) => isAfter(other) ? other : this;

  /// Returns the earlier date between this date and now.
  DateTime noLaterThanNow() => noLaterThan(DateTime.now());

  /// Returns a new DateTime object with only day month year, and the time set to midnight (00:00:00)
  DateTime get date => DateTime(year, month, day);

  /// Returns the absolute difference in days between this date and [other].
  ///
  /// As such, no need to check [isBefore] or [isAfter] between two dates.
  int diffInDays(DateTime other) => difference(other).inDays.abs();

  /// Returns true if this date is the same day as [other].
  bool isSameDay(DateTime other) => year == other.year && month == other.month && day == other.day;

  bool isBeforeOrAt(DateTime other) => isBefore(other) || isAtSameMomentAs(other);

  bool isAfterOrAt(DateTime other) => isAfter(other) || isAtSameMomentAs(other);

  /// Format date to GraphQL Date scalar (yyyy-MM-dd)
  String toGqlDate() => XPHelperDateTime.format(this, format: XPDateTimeFormat.yearMonthDay);

  // DateTime asUtc() => isUtc ? this : DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch, isUtc: true);
}

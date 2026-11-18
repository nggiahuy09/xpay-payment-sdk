import 'package:flutter/material.dart' show DateTimeRange;
import 'package:intl/intl.dart';

import '../../base/extensions/extensions.dart';
import '../../base/localization/localization.dart';

final class XPHelperDateTime {
  const XPHelperDateTime._();

  /// Get local timezone offset in the format "+HH:mm" or "-HH:mm".
  static String get localTimezone {
    final offset = DateTime.now().timeZoneOffset;

    final totalMinutes = offset.inMinutes;
    final sign = totalMinutes >= 0 ? '+' : '-';
    final absMinutes = totalMinutes.abs();
    final hours = absMinutes ~/ 60;
    final minutes = absMinutes % 60;

    final hh = hours.toString().padLeft(2, '0');
    final mm = minutes.toString().padLeft(2, '0');

    return '$sign$hh:$mm';
  }

  static Duration get localTimezoneOffset => DateTime.now().timeZoneOffset;

  static DateTime get vietnamToday => DateTime.now().millisecondsSinceEpoch.asUtcWithOffset(const Duration(hours: 7)).date;

  static DateTime toVietnamTime(DateTime dateTime) => dateTime.millisecondsSinceEpoch.asUtcWithOffset(const Duration(hours: 7));

  /// Automatically enforce UTC if [format] is [XPDateTimeFormat.iso8601withMilliseconds].
  static DateTime? tryParse(String? data, {XPDateTimeFormat format = XPDateTimeFormat.yearMonthDay, bool isUtc = false, bool toLocal = true, int? offsetHours}) {
    try {
      isUtc = format == XPDateTimeFormat.iso8601withMilliseconds ? true : isUtc;
      final parsedDateTime = data != null ? DateFormat(format.formatString).parse(data, isUtc) : null;

      if (offsetHours != null) parsedDateTime?.add(Duration(hours: offsetHours));

      return toLocal ? parsedDateTime?.toLocal() : parsedDateTime;
    } catch (_) {}
    return null;
  }

  /// Parse [data] and treat it as a date, with timezone UTC, and without converting to local.
  static DateTime? tryParseDate(String? data, {XPDateTimeFormat format = XPDateTimeFormat.yearMonthDay}) {
    return tryParse(data, format: format, isUtc: true, toLocal: false);
  }

  static String format(DateTime? datetime, {XPDateTimeFormat format = XPDateTimeFormat.monthDayYear}) {
    final localeId = XPLocalization.instance.localeId;
    return datetime != null ? DateFormat(format.formatString, localeId).format(datetime) : '';
  }

  /// Combines the period into a single string with optimizations for same day, month, year.
  ///
  /// Ex: Jan 1 - 12, 2023 or Jan 28 - Feb 2, 2023 or Dec 30, 2023 - Jan 2, 2024
  static String formatCombinedPeriod(DateTime? beginAt, DateTime? endAt) {
    if (beginAt == null || endAt == null) return XPHelperDateTime.format(beginAt ?? endAt, format: XPDateTimeFormat.dayMonthYearVerbose);

    if (beginAt.year == endAt.year && beginAt.month == endAt.month && beginAt.day == endAt.day) {
      return XPHelperDateTime.format(beginAt, format: XPDateTimeFormat.dayMonthYearVerbose);
    }

    final sameMonth = beginAt.month == endAt.month && beginAt.year == endAt.year;
    final sameYear = beginAt.year == endAt.year;

    final String startDate;
    if (sameMonth) {
      startDate = XPHelperDateTime.format(beginAt, format: XPDateTimeFormat.day);
    } else if (sameYear) {
      startDate = XPHelperDateTime.format(beginAt, format: XPDateTimeFormat.dayMonthVerbose);
    } else {
      startDate = XPHelperDateTime.format(beginAt, format: XPDateTimeFormat.dayMonthYearVerbose);
    }
    final endDate = XPHelperDateTime.format(endAt, format: XPDateTimeFormat.dayMonthYearVerbose);
    return '$startDate - $endDate';
  }

  /// "14:30" GMT+7
  /*static String formatLocalTime(String? dateTimeString, XPDateTimeFormat format) {
    if (dateTimeString?.isEmpty != false) return '';
    final dateTime = XPHelperDateTime.tryParse(dateTimeString!, format: format)?.toLocal();

    if (dateTime == null) return '';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }*/

  static int countUniqueDays(List<DateTimeRange> ranges) {
    if (ranges.isEmpty) return 0;
    final sortedRanges = List<DateTimeRange>.from(ranges)..sort((a, b) => a.start.compareTo(b.start));
    var currentStart = sortedRanges.first.start.date;
    var currentEnd = sortedRanges.first.end.date;
    var totalDays = 0;

    for (int i = 1; i < sortedRanges.length; i++) {
      final nextStart = sortedRanges[i].start.date, nextEnd = sortedRanges[i].end.date;
      if (nextStart.isAfterInDays(currentEnd)) {
        totalDays += currentEnd.diffInDays(currentStart) + 1;
        currentStart = nextStart;
        currentEnd = nextEnd;
      } else if (nextEnd.isAfterInDays(currentEnd)) {
        currentEnd = nextEnd;
      }
    }

    totalDays += currentEnd.diffInDays(currentStart) + 1;
    return totalDays;
  }

  static String tryParseAndFormat(String? data, {bool isUtc = false, required XPDateTimeFormat parseFormat, required XPDateTimeFormat convertFormat}) {
    return format(
      tryParse(data, format: parseFormat, isUtc: isUtc),
      format: convertFormat,
    );
  }

  /// Shortens a timezone offset string for display.
  ///
  /// Accepts: "Z", "z", "-09:00", "+09:30", "+0930", "+9:30", "+09", "+9", "09:00", "9:00", "0900"
  ///
  /// Examples: "+07:00" -> "+7", "07:00" -> "+7", "0700" -> "+7", "-01:30" -> "-1:30"
  ///
  /// Returns null for invalid formats or out-of-range values.
  static String? shortenTimezoneString(String? timezone) {
    if (timezone == null) return null;
    final sanitizedTimezone = timezone.trim();
    if (sanitizedTimezone.isEmpty) return null;
    if (sanitizedTimezone == 'Z' || sanitizedTimezone == 'z') return '+0';

    final match = RegExp(r'^([+-])?(\d{1,2})(?::?(\d{2}))?$').firstMatch(sanitizedTimezone);
    if (match == null) return null;

    final sign = match.group(1) == '-' ? '-' : '+';
    final hours = int.tryParse(match.group(2) ?? '');
    final minutes = match.group(3) != null ? int.tryParse(match.group(3)!) : 0;
    if (hours == null || minutes == null) return null;
    if (hours < 0 || hours > 14) return null;
    if (minutes < 0 || minutes >= 60) return null;
    if (hours == 14 && minutes != 0) return null;
    if (hours == 0 && minutes == 0) return '+0';

    if (minutes == 0) return '$sign$hours';
    return '$sign$hours:${minutes.toString().padLeft(2, '0')}';
  }

  /// Converts a [timezone] string to [Duration].
  ///
  /// Accepts: "Z", "z", "-09:00", "+09:30", "+0930", "+9:30", "+09", "+9"
  ///
  /// Returns null for invalid formats or out-of-range values.
  static Duration? getTimezoneFromString(String? timezone) {
    if (timezone == null) return null;
    final s = timezone.trim();
    if (s.isEmpty) return null;

    // Accept "Z" or "z" as UTC
    if (s == 'Z' || s == 'z') return Duration.zero;

    // Accept forms: +HH, +HHMM, +HH:MM and single-digit hour like +9:30
    final reg = RegExp(r'^[+-](\d{1,2})(?::?(\d{2}))?$');
    final match = reg.firstMatch(s);
    if (match == null) return null;

    final isNegative = s.startsWith('-');
    final hours = int.tryParse(match.group(1)!) ?? 0;
    final minutes = match.group(2) != null ? int.tryParse(match.group(2)!) : 0;
    if (minutes == null) return null;

    // Validate ranges:
    // - typical timezone offsets lie between -14:00 and +14:00
    if (hours < 0 || hours > 14) return null;
    if (minutes < 0 || minutes >= 60) return null;
    // If hour is 14, minutes must be 0 (max offset +14:00)
    if (hours == 14 && minutes != 0) return null;

    final totalMinutes = hours * 60 + minutes;
    return Duration(minutes: isNegative ? -totalMinutes : totalMinutes);
  }
}

final class XPDateTimeFormat {
  const XPDateTimeFormat._(this.formatString);

  /// Example: "04/15/2025"
  static const XPDateTimeFormat monthDayYear = XPDateTimeFormat._('MM/dd/yyyy');

  /// Example: "15/04/2025"
  static const XPDateTimeFormat dayMonthYear = XPDateTimeFormat._('dd/MM/yyyy');

  /// Example: "May 20, 2025"
  static const XPDateTimeFormat monthDayYearVerbose = XPDateTimeFormat._('MMM dd, yyyy');

  /// Example: "20 May"
  static const XPDateTimeFormat dayMonthVerbose = XPDateTimeFormat._('dd MMM');

  /// Example: "20 May, 2025"
  static const XPDateTimeFormat dayMonthYearVerbose = XPDateTimeFormat._('dd MMM, yyyy');

  /// Example: "Mon, May 20, 2025"
  static const XPDateTimeFormat weekdayMonthDayYear = XPDateTimeFormat._('E, MMM dd, yyyy');

  /// Example: "Mon, 20 May, 2025"
  static const XPDateTimeFormat weekdayDayMonthYear = XPDateTimeFormat._('E, dd MMM, yyyy');

  /// Example: "Thu, 20/05/2025"
  static const XPDateTimeFormat weekdayDayMonthYearNumeric = XPDateTimeFormat._('E, dd/MM/yyyy');

  /// Example: "Thursday, 20 May"
  static const XPDateTimeFormat weekdayDayMonthVerbose = XPDateTimeFormat._('EEEE, dd MMM');

  /// Example: "Thursday, 20 May, 2025"
  static const XPDateTimeFormat weekdayDayMonthYearVerbose = XPDateTimeFormat._('EEEE, dd MMM, yyyy');

  /// Example: "2025-04-28"
  static const XPDateTimeFormat yearMonthDay = XPDateTimeFormat._('yyyy-MM-dd');

  /// Example: "Apr 16"
  static const XPDateTimeFormat monthDayVerbose = XPDateTimeFormat._('MMM dd');

  /// Example: "14:30"
  static const XPDateTimeFormat hourMinute24Hour = XPDateTimeFormat._('HH:mm');

  /// Example: "14:30:00"R
  static const XPDateTimeFormat hourMinuteSecond24Hour = XPDateTimeFormat._('HH:mm:ss');

  /// Example: "02:00 PM, Apr 16"
  static const XPDateTimeFormat hourMinute12MMMdd = XPDateTimeFormat._('HH:mm a, MMM dd');

  /// Example: "02:00 PM, 16 Apr"
  static const XPDateTimeFormat hourMinute12ddMMM = XPDateTimeFormat._('HH:mm a, dd MMM');

  /// Example: "14:30, 16 Apr"
  static const XPDateTimeFormat hourMinute24ddMMM = XPDateTimeFormat._('HH:mm, dd MMM');

  /// Example: "14:30 · 16/04"
  static const XPDateTimeFormat hourMinuteDayMonthNumeric = XPDateTimeFormat._('HH:mm · dd/MM');

  /// Example: "14:30 · 16/04/2025"
  static const XPDateTimeFormat hourMinuteDayMonthYearNumeric = XPDateTimeFormat._('HH:mm · dd/MM/yyyy');

  /// Example: "16"
  static const XPDateTimeFormat day = XPDateTimeFormat._('dd');

  /// Example: "2025-08-23T23:00:00.000Z"
  static const XPDateTimeFormat iso8601withMilliseconds = XPDateTimeFormat._('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');

  /// Example: "2025-08-23T23:00:00Z"
  static const XPDateTimeFormat iso8601 = XPDateTimeFormat._('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

  /// Example: "2025-08-23T23:00:00+0700"
  ///
  /// Note: `DateFormat`'s `Z` pattern emits an offset only for a UTC [DateTime]; formatting a local value with this yields no offset at all. To send a
  /// timezone-qualified local instant, use [iso8601NoTimezone] and append [XPHelperDateTime.localTimezone].
  static const XPDateTimeFormat iso8601WithTimezone = XPDateTimeFormat._('yyyy-MM-dd\'T\'HH:mm:ssZ');

  /// Example: "2025-08-23T23:00:00"
  ///
  /// Local wall-clock time with no zone marker. Pair with [XPHelperDateTime.localTimezone] to build an offset-qualified timestamp.
  static const XPDateTimeFormat iso8601NoTimezone = XPDateTimeFormat._('yyyy-MM-dd\'T\'HH:mm:ss');

  /// Example: "5 Aug, 2025, 12:15"
  static const XPDateTimeFormat dayMonthYearHourMinute = XPDateTimeFormat._('dd MMM, yyyy, HH:mm');

  /// Example: "05/08/2025, 12:15"
  static const XPDateTimeFormat dayMonthYearNumericHourMinute = XPDateTimeFormat._('dd/MM/yyyy, HH:mm');

  /// Example: "12:15 - 05 Aug, 2025"
  static const XPDateTimeFormat hourMinuteDayMonthYear = XPDateTimeFormat._('HH:mm - dd MMM, yyyy');

  /// Example: "2025-08-23 23:00:00"
  static const XPDateTimeFormat yearMonthDayHourMinuteSecond = XPDateTimeFormat._('yyyy-MM-dd HH:mm:ss');

  /// Example: "2026-01-07 14:00"
  static const XPDateTimeFormat yearMonthDayHourMinute = XPDateTimeFormat._('yyyy-MM-dd HH:mm');

  final String formatString;
}

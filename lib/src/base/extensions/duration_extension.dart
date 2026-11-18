import '../localization/localization.dart';

extension DurationFormatExtension on Duration {
  static const Map<_XPDurationUnit, Map<String, String>> _text = {
    _XPDurationUnit.hourShort: {'en': 'hr', 'vi': 'g'},
    _XPDurationUnit.hourExtremeShort: {'en': 'h', 'vi': 'g'},
    _XPDurationUnit.minuteShort: {'en': 'min', 'vi': 'p'},
    _XPDurationUnit.minuteExtremeShort: {'en': 'm', 'vi': 'p'},
  };

  /// Converts the duration to a human-readable string format
  ///
  /// Parameters:
  /// - [locale]: The locale settings to use for formatting
  /// - [format]: The format to use for the duration string (defaults to hoursMinutes)
  ///
  /// Returns a formatted string representation of the duration.
  /// For example: "2 hr 30 min"
  String displayText({String? localeId, XPDurationFormat format = XPDurationFormat.hoursMinutesShort}) {
    localeId ??= XPLocalization.instance.localeId;
    final StringBuffer buffer;
    final totalHours = inHours.abs();
    final totalMinutes = inMinutes.abs();
    final totalSeconds = inSeconds.abs();
    final paddedHours = totalHours.toString().padLeft(2, '0');
    final paddedMinutes = (totalMinutes % 60).toString().padLeft(2, '0');
    final paddedTotalMinutes = totalMinutes.toString().padLeft(2, '0');
    final paddedSeconds = (totalSeconds % 60).toString().padLeft(2, '0');
    switch (format) {
      case XPDurationFormat.hoursMinutesShort:
        buffer = StringBuffer();
        if (totalHours > 0) buffer.write('$totalHours ${_text[_XPDurationUnit.hourShort]?[localeId] ?? 'hr'} ');
        buffer.write('${totalMinutes % 60} ${_text[_XPDurationUnit.minuteShort]?[localeId] ?? 'min'}');
        break;
      case XPDurationFormat.hoursMinutesExtremeShort:
        buffer = StringBuffer();
        if (totalHours > 0) buffer.write('$totalHours${_text[_XPDurationUnit.hourExtremeShort]?[localeId] ?? 'h'} ');
        buffer.write('${totalMinutes % 60}${_text[_XPDurationUnit.minuteExtremeShort]?[localeId] ?? 'm'}');
        break;
      case XPDurationFormat.hourMinuteSecond:
        buffer = StringBuffer('$paddedHours:$paddedMinutes:$paddedSeconds');
        break;
      case XPDurationFormat.minuteSecond:
        buffer = StringBuffer('$paddedTotalMinutes:$paddedSeconds');
        break;
    }
    return buffer.toString();
  }
}

/// Defines the available formats for duration display
enum XPDurationFormat {
  /// Format showing hours and minutes (e.g. "2 hr 30 min")
  hoursMinutesShort,

  /// Format showing hours and minutes with extreme short units (e.g. "2h 30m")
  hoursMinutesExtremeShort,

  /// Format showing hours, minutes, and seconds (e.g. "02:30:45")
  hourMinuteSecond,

  /// Format showing minutes and seconds (e.g. "30:45")
  minuteSecond,
}

enum _XPDurationUnit { hourShort, hourExtremeShort, minuteShort, minuteExtremeShort }

import 'package:flutter/services.dart';

/// Validates a manually entered card number using the Luhn (mod-10) algorithm.
///
/// The manual channel accepts any Luhn-valid number of an acceptable length, independent of card brand — some accepted cards are domestic/private-label
/// numbers whose prefixes are not recognized by international brand detectors.
abstract final class XPHelperCardManualPanValidator {
  const XPHelperCardManualPanValidator._();

  static const int minDigits = 12;
  static const int maxDigits = 16;
  static const int expiryDigits = 4;

  static bool isValid(String pan) {
    final digits = onlyDigits(pan);
    if (digits.length < minDigits || digits.length > maxDigits) return false;

    return _passesLuhn(digits);
  }

  /// Whether an `MM/YY` expiry is a real, non-expired date.
  ///
  /// Requires exactly four digits, a month in `1..12`, and a year/month not in the past relative to [now] (defaults to the current date). The two-digit
  /// year is expanded within the current century. Pass [now] to keep callers testable and deterministic.
  static bool isExpiryValid(String expiry, {DateTime? now}) {
    final digits = onlyDigits(expiry);
    if (digits.length != expiryDigits) return false;

    final month = int.tryParse(digits.substring(0, 2));
    final year = int.tryParse(digits.substring(2, 4));
    if (month == null || year == null || month < 1 || month > 12) return false;

    final reference = now ?? DateTime.now();
    final fullYear = reference.year - reference.year % 100 + year;
    return fullYear > reference.year || (fullYear == reference.year && month >= reference.month);
  }

  /// Strips every non-digit character, returning only the `0-9` run.
  static String onlyDigits(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  static bool _passesLuhn(String digits) {
    var sum = 0;
    var isSecondDigit = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var digit = digits.codeUnitAt(i) - 0x30;
      if (isSecondDigit) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      isSecondDigit = !isSecondDigit;
    }

    return sum % 10 == 0;
  }
}

/// Formats a card number as space-separated groups of four digits (e.g. `4111 1111 1111 1111`) while capping the raw digit count at [maxDigits].
class XPHelperCardPanInputFormatter extends TextInputFormatter {
  const XPHelperCardPanInputFormatter({required this.maxDigits});

  static const int _groupSize = 4;

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = XPHelperCardManualPanValidator.onlyDigits(newValue.text);
    final capped = digits.length > maxDigits ? digits.substring(0, maxDigits) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i != 0 && i % _groupSize == 0) buffer.write(' ');
      buffer.write(capped[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formats card expiry input as `MM/YY`, inserting the separator automatically after the month and capping the raw digit count at four.
class XPHelperCardExpiryInputFormatter extends TextInputFormatter {
  const XPHelperCardExpiryInputFormatter();

  static const int _maxDigits = 4;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = XPHelperCardManualPanValidator.onlyDigits(newValue.text);
    final capped = digits.length > _maxDigits ? digits.substring(0, _maxDigits) : digits;

    final formatted = capped.length <= 2 ? capped : '${capped.substring(0, 2)}/${capped.substring(2)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

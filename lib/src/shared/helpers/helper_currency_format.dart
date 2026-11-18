import 'package:intl/intl.dart';

import '../../base/define/constant/constant.dart';
import '../../base/extensions/extensions.dart';
import '../../base/localization/localization.dart';

/// Formats money amounts with the symbol placed, spaced and signed the way the app language writes them.
///
/// | Currency | `vi`        | `en`       |
/// | -------- | ----------- | ---------- |
/// | VND      | `45.000 ₫`  | `₫45,000`  |
/// | VND (−)  | `-45.000 ₫` | `-₫45,000` |
/// | USD      | `12,34 $`   | `$12.34`   |
///
/// The decimal digits follow the currency (VND 0, USD 2), not the locale. A missing currency is treated as [XPCurrencyConstant.kDefaultCurrency], and a code with no
/// known symbol is shown as the code itself (e.g. `XYZ12.34` in English). The space between the number and a trailing symbol is a non-breaking space so the
/// symbol never wraps onto its own line.
///
/// The locale is the language picked in the app ([XPLocalization.localeId]), never the device region: a French phone showing the app in English
/// must still read `₫45,000`, not `45 000 ₫`.
final class XPHelperCurrencyFormat {
  const XPHelperCurrencyFormat._();

  /// Formats [value] with the symbol of [currency], e.g. `45.000 ₫` or `₫45,000`. Returns an empty string when [value] is `null`.
  ///
  /// Negative values are always prefixed with `-`. Set [showsPositiveSign] to prefix positive values with `+`, for incoming amounts.
  static String format(num? value, {String? currency, String? localeId, bool showsPositiveSign = false}) {
    if (value == null) return '';

    // `value == 0` also holds for -0.0, which would otherwise render as `-₫0` when a zero amount is negated into an outflow.
    final formatted = _formatter(currency, localeId).format(value == 0 ? 0 : value);
    return showsPositiveSign && value > 0 ? '+$formatted' : formatted;
  }

  /// Parses [amount] as returned by the API and formats it like [format]. Returns [placeholder] when it is not a number.
  static String formatRemote(String? amount, {String? currency, String? localeId, String placeholder = '--'}) {
    final value = double.tryParse(amount ?? '');
    return value != null ? format(value, currency: currency, localeId: localeId) : placeholder;
  }

  /// Formats [value] with the grouping and decimal digits of [currency], but without its symbol. Pair it with [symbol] and [isSymbolLeading]
  /// when the number and the symbol are styled separately.
  static String formatNumber(num? value, {String? currency, String? localeId}) {
    if (value == null) return '';

    final formatter = _formatter(currency, localeId);
    return NumberFormat.decimalPatternDigits(locale: formatter.locale, decimalDigits: formatter.maximumFractionDigits).format(value);
  }

  /// The symbol shown for [currency], e.g. `₫` for VND and `$` for USD.
  static String symbol({String? currency, String? localeId}) => _formatter(currency, localeId).currencySymbol;

  /// Whether the active locale writes the symbol of [currency] before the number (`₫45,000`) rather than after it (`45.000 ₫`).
  static bool isSymbolLeading({String? currency, String? localeId}) => _formatter(currency, localeId).positivePrefix.isNotEmpty;

  static NumberFormat _formatter(String? currency, String? localeId) {
    final code = currency?.trim().nullIfEmpty()?.toUpperCase() ?? XPCurrencyConstant.kDefaultCurrency;
    return NumberFormat.simpleCurrency(locale: localeId ?? XPLocalization.instance.localeId, name: code);
  }
}

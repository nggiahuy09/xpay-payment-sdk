import '../../../base/extensions/extensions.dart';

enum XpayQrPrefix {
  xpCard('XPCARD'),
  xTok('XTOK');

  const XpayQrPrefix(this.value);

  final String value;

  static const String _separator = ':';

  /// Resolves the QR prefix from a scanned raw value (e.g. `XPCARD:ptok_...`).
  /// Returns `null` when the value does not start with any known prefix.
  static XpayQrPrefix? resolve(String rawValue) {
    final separatorIndex = rawValue.indexOf(_separator);
    if (separatorIndex <= 0) return null;

    final prefix = rawValue.substring(0, separatorIndex);
    return XpayQrPrefix.values.firstWhereOrNull((e) => e.value == prefix);
  }

  /// Strips this prefix from [rawValue], returning the token after the separator.
  String extractToken(String rawValue) {
    final expectedPrefix = '$value$_separator';
    if (!rawValue.startsWith(expectedPrefix)) return rawValue;

    return rawValue.substring(expectedPrefix.length);
  }
}

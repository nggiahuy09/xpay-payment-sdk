import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../base/define/logging/logger.dart';

final class XPHelperPhone {
  const XPHelperPhone._();

  static const String _kTelScheme = 'tel';

  /// Opens the dialer with [phoneNumber]; when no dialer opens, copies the number instead and returns false.
  static Future<bool> dialOrCopy(String phoneNumber) async {
    try {
      final isDialed = await launchUrl(
        Uri(scheme: _kTelScheme, path: phoneNumber),
        mode: LaunchMode.externalApplication,
      );
      if (isDialed) return true;
    } catch (e, stackTrace) {
      XPLogger.error(error: e, stackTrace: stackTrace, message: 'The dialer could not be opened, copying the number instead');
    }

    await Clipboard.setData(ClipboardData(text: phoneNumber));
    return false;
  }
}

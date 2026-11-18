import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../base/localization/localization.dart';
import '../snack_bar/snack_bar_manager.dart';

final class XPPermissionManager {
  XPPermissionManager._();

  /// Requests camera permission. Prompts on first request; shows a snackbar guiding the user to app settings when the permission is blocked (permanently denied or OS-restricted).
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final newStatus = await Permission.camera.request();
      if (newStatus.isGranted) return true;
      if (newStatus.isPermanentlyDenied || newStatus.isRestricted) _showCameraBlockedSnackBar();
      return false;
    }

    if (status.isPermanentlyDenied || status.isRestricted) _showCameraBlockedSnackBar();

    return false;
  }

  static void _showCameraBlockedSnackBar() {
    final locale = XPLocalization.instance.locale.shared;
    XPSnackBarManager.show(title: locale.permissionPermanentlyDenied, level: XPSnackBarMessageLevel.information, closeOnContentTapped: true, onTapContent: openAppSettings);
  }
}

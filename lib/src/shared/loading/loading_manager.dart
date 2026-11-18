import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../base/define/constant/constant.dart';

part 'loading_overlay_default_widget.dart';

final class XPLoadingManager {
  const XPLoadingManager._();

  static OverlayEntry? _overlay;

  /// Shows a cupertino style non-dismissible loading overlay for the entire app.
  ///
  /// Calling this method repeatedly will not stack multiple overlays on top of each other.
  static void showDefaultOverlay(BuildContext context) {
    if (XPLoadingManager._overlay == null) XPLoadingManager._showLoading(context);
  }

  static void hideDefaultOverlay() => _hideLoading();

  static void _showLoading(BuildContext context) {
    final entry = OverlayEntry(builder: (_) => const _LoadingOverlayDefaultWidget());
    XPLoadingManager._overlay = entry;
    Overlay.of(context).insert(entry);
  }

  static void _hideLoading() {
    XPLoadingManager._overlay?.remove();
    XPLoadingManager._overlay = null;
  }
}

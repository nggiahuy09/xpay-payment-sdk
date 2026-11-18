import 'dart:ui';

import 'package:flutter/cupertino.dart' show CupertinoSheetRoute;
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../base/define/constant/constant.dart';
import '../views/views.dart';
import '../widgets/buttons/button_icon.dart';
import '../widgets/keyboard_dismiss/keyboard_dismiss.dart';
import '../widgets/text/text_widgets.dart';

export 'modal_header_section.dart';

part 'bottom_modal_sheet_widget.dart';
part 'cupertino_sheet_widget.dart';

final class XPModalManager {
  const XPModalManager._();

  /// Show a bottom sheet.
  /// - [title] - title of bottom sheet that is show above the child, and has a bottom spacing of 16 px.
  /// - [barrierDismissible] - set to false if you want to disable dismiss by tapping outside of the bottom sheet.
  /// - [enableDrag] - set to false if you want to disable drag to dismiss the bottom sheet.
  /// - [overscrollToClose] - if true, enables over-scroll gesture to close the sheet when the child is a scrollable widget (ListView, etc.).
  ///   When scrolled to the top and dragged down further (over-scroll > 200px), the sheet will close. Default is true.
  /// - [isScrollControlled] - set to true if child has a scrollable widget.
  /// - [blurIntensity] - blur intensity of background.
  /// - [topPadding] - top padding of bottom sheet. Default is 80.0 from the top of **the screen**.
  /// - [topBorderRadius] - top border radius of bottom sheet.
  /// - [autoWrap] - If true, then the size of the view will be dynamically adjusted based on the child's height. If the child actual height exceeds the screen height,
  /// then [topPadding] will be applied. Auto scale base on contents of the child wrapped in a scroll view.
  /// - [topRightCloseButton] - if true, then show a close button on top right corner of the bottom sheet. Only visible if [title] is present.
  ///
  /// Note:
  ///
  /// - Bottom padding will be different between focused and unfocused states of the child, if child has a focus node.
  /// - Set both [barrierDismissible] and [enableDrag] to false if you want to disable popping the sheet with device back button.
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    Key? key,
    XPPlatformSafeAreaConfig iosSafeAreaConfig = const XPPlatformSafeAreaConfig.bottomSheetIOS(),
    XPPlatformSafeAreaConfig androidSafeAreaConfig = const XPPlatformSafeAreaConfig.bottomSheetAndroid(),
    String? title,
    double blurIntensity = 16.0,
    double topPadding = 80.0,
    double titleBottomPadding = 16.0,
    double leftContentPadding = 24.0,
    double topContentPadding = 16.0,
    double rightContentPadding = 24.0,
    double topBorderRadius = 24.0,
    bool barrierDismissible = true,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool overscrollToClose = true,
    bool unfocusOnTap = false,
    bool autoWrap = false,
    bool showThumb = true,
    bool useSafeArea = true,
    bool topRightCloseButton = false,
  }) async {
    final effectiveIosConfig = useSafeArea ? iosSafeAreaConfig : const XPPlatformSafeAreaConfig();
    final effectiveAndroidConfig = useSafeArea ? androidSafeAreaConfig : const XPPlatformSafeAreaConfig();
    final preventPop = barrierDismissible == false && enableDrag == false;
    return await showModalBottomSheet<T>(
      context: context,
      builder: (_) => _XPBottomModalSheetWidget(
        key: key,
        iosSafeAreaConfig: effectiveIosConfig,
        androidSafeAreaConfig: effectiveAndroidConfig,
        title: title,
        blurIntensity: blurIntensity,
        topPadding: topPadding,
        titleBottomPadding: titleBottomPadding,
        leftContentPadding: leftContentPadding,
        topContentPadding: topContentPadding,
        rightContentPadding: rightContentPadding,
        topBorderRadius: topBorderRadius,
        unfocusOnTap: unfocusOnTap,
        autoWrap: autoWrap,
        showThumb: showThumb,
        overscrollToClose: overscrollToClose,
        preventPop: preventPop,
        topRightCloseButton: topRightCloseButton,
        child: child,
      ),
      isScrollControlled: isScrollControlled,
      isDismissible: barrierDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: XPColorOverlay.reverseTheme40,
      elevation: 0.0,
    );
  }

  /// Shows a iOS-style sheet from below the screen as a stack (stack modal), push the current page below, and support drag to dismiss.
  /// The page's content padding is 24.0 horizontally and 16.0 vertically, apply for both title and body.
  /// - [title] - title of the sheet. Max line is 1 and will be clipped if overflow. If [null], then you need to supply your own title & action button widget.
  /// - [child] - child of the sheet. No need for a Material widget ancestor or padding. The padding is 24 horizontally and 16 vertically.
  /// - [overscrollToClose] - if true, enables over-scroll gesture to close the sheet when the child is a scrollable widget (ListView, etc.).
  ///   When scrolled to the top and dragged down further (over-scroll > 80px), the sheet will close. Default is true.
  ///
  /// If you show the sheet from a bottom sheet, it's recommended to call [NavigatorState.pop] to dismiss the bottom sheet first, before showing the cupertino sheet.
  /// Otherwise, the cupertino sheet will behave visually similar to a bottom sheet.
  /// Note that calling [NavigatorState.maybePop] will not dismiss the current bottom sheet in this case.
  ///
  /// The parent route of this cupertino sheet root, if used [NavigatorState.push], should NOT specify generic type.
  /// Otherwise, the cupertino sheet will behave visually similar to a bottom sheet.
  /// TODO: Migrate from child to builder to leverage the returned scroll controller.
  static Future<T?> showCupertinoSheet<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? trailingAction,
    bool useSafeArea = true,
    bool overscrollToClose = true,
    bool showCloseButton = true,
    XPPlatformSafeAreaConfig iosSafeAreaConfig = const XPPlatformSafeAreaConfig.cupertinoSheetIOS(),
    XPPlatformSafeAreaConfig androidSafeAreaConfig = const XPPlatformSafeAreaConfig.cupertinoSheetAndroid(),
    Key? key,
  }) async {
    final effectiveIosConfig = useSafeArea ? iosSafeAreaConfig : const XPPlatformSafeAreaConfig();
    final effectiveAndroidConfig = useSafeArea ? androidSafeAreaConfig : const XPPlatformSafeAreaConfig();
    return await Navigator.of(context).push<T>(
      CupertinoSheetRoute(
        scrollableBuilder: (_, _) => _XPCupertinoSheetWidget(
          key: key,
          trailingAction: trailingAction,
          androidSafeAreaConfig: effectiveAndroidConfig,
          iosSafeAreaConfig: effectiveIosConfig,
          title: title,
          overscrollToClose: overscrollToClose,
          showCloseButton: showCloseButton,
          child: child,
        ),
      ),
    );
    /*return await cupertino.showCupertinoSheet(
      context: context,
      useNestedNavigation: nestedNavigation,
      pageBuilder: (_) => _XPCupertinoSheetWidget(key: key, title: title, child: child),
    );*/
  }

  static Future<T?> showDialog<T>({required BuildContext context, required Widget child, bool barrierDismissible = true}) async {
    return await Navigator.of(context).push<T>(
      DialogRoute<T>(
        context: context,
        builder: (_) => PopScope(
          canPop: barrierDismissible,
          child: Dialog(
            backgroundColor: XPColorSurface.defaultColor,
            elevation: 0.0,
            surfaceTintColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24.0),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded20))),
            child: SingleChildScrollView(padding: const EdgeInsets.all(24.0), child: child),
          ),
        ),
        barrierColor: XPColorOverlay.reverseTheme40,
        barrierDismissible: barrierDismissible,
      ),
    );
  }
}

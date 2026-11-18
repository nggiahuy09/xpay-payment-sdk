import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class XPPlatformSafeAreaView extends StatelessWidget {
  /// A safe area widget that use a custom calculation for bottom and/or top padding,
  /// instead of always using the value from [MediaQuery].
  const XPPlatformSafeAreaView({
    super.key,
    this.iOSConfig = const XPPlatformSafeAreaConfig.defaultIOS(),
    this.androidConfig = const XPPlatformSafeAreaConfig.defaultAndroid(),
    this.child,
    this.builder,
  }) : assert(child != null || builder != null, 'Either child or builder must be provided');

  final XPPlatformSafeAreaConfig iOSConfig;
  final XPPlatformSafeAreaConfig androidConfig;
  final Widget? child;

  /// A builder function that returns a widget with the calculated padding.
  ///
  /// Useful when you want to wrap the child with a widget that has a different padding behavior, e.g., [ListView], [SingleChildScrollView].
  final Widget Function(EdgeInsets safePadding)? builder;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (iOSConfig.enabled == false) return child ?? builder!.call(EdgeInsets.zero);
      final bottom = iOSConfig.bottom;
      final bottomPadding = MediaQuery.paddingOf(context).bottom * bottom.multiplier;
      final padding = EdgeInsets.only(bottom: max(bottomPadding, bottom.min));
      return builder?.call(padding) ?? Padding(padding: padding, child: child);
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (androidConfig.enabled == false) return child ?? builder!.call(EdgeInsets.zero);
      final bottom = androidConfig.bottom;
      final bottomPadding = MediaQuery.paddingOf(context).bottom * bottom.multiplier;
      final padding = EdgeInsets.only(bottom: max(bottomPadding, bottom.min));
      return builder?.call(padding) ?? Padding(padding: padding, child: child);
    }

    return child ?? builder!.call(EdgeInsets.zero);
  }
}

@immutable
final class XPPlatformSafeAreaConfig {
  const XPPlatformSafeAreaConfig({this.bottom = const XPPlatformSafeAreaPadding(), this.enabled = false});

  /// A default config for iOS for all views except sheets.
  const XPPlatformSafeAreaConfig.defaultIOS() : bottom = const XPPlatformSafeAreaPadding(multiplier: 0.75), enabled = true;

  /// A default config for Android for all views except sheets.
  const XPPlatformSafeAreaConfig.defaultAndroid() : bottom = const XPPlatformSafeAreaPadding(multiplier: 1.25), enabled = true;

  const XPPlatformSafeAreaConfig.bottomSheetIOS() : bottom = const XPPlatformSafeAreaPadding(), enabled = false;

  const XPPlatformSafeAreaConfig.bottomSheetAndroid() : bottom = const XPPlatformSafeAreaPadding(multiplier: 0.5), enabled = true;

  const XPPlatformSafeAreaConfig.cupertinoSheetIOS() : bottom = const XPPlatformSafeAreaPadding(multiplier: 0.75), enabled = true;

  const XPPlatformSafeAreaConfig.cupertinoSheetAndroid() : bottom = const XPPlatformSafeAreaPadding(multiplier: 1.25, min: 48.0), enabled = true;

  final XPPlatformSafeAreaPadding bottom;
  final bool enabled;
}

@immutable
final class XPPlatformSafeAreaPadding {
  const XPPlatformSafeAreaPadding({double multiplier = 0.0, double threshold = 9999.0, this.min = 0.0, this.minThreshold = 0.0})
    : multiplier = multiplier > threshold ? threshold : multiplier,
      overflow = multiplier > threshold ? multiplier - threshold : 0.0,
      assert(multiplier >= 0.0 && threshold >= 0.0, 'multiplier, overflow and threshold must be positive');

  /// A multiplier that applies for the whole screen.
  ///
  /// Please note that when the virtual keyboard is shown, the screen bottom padding will be zero.
  /// As such, views should implement a form of padding if there are fixed contents at the bottom of the screen.
  final double multiplier;

  /// A multiplier that apples to a portion of the screen, base on [threshold].
  /// Currently used in [XPModalManager.showCupertinoSheet()] for ios, because too high [multiplier] cause the entire sheet view to shift to top.
  ///
  /// So we need an overflow offset for the view.
  final double overflow;

  /// Absolute min padding, not accounted my ANY multiplier.
  /// Currently used in [XPModalManager.showCupertinoSheet()] for android, because in gesture navigation mode, the bottom padding is zero.
  final double min;

  /// A threshold at which [min] will be applied.
  final double minThreshold;
}

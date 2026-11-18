import 'package:flutter/material.dart';

import '../base/define/constant/constant.dart';
import '../shared/loading/loading.dart';
import '../shared/views/views.dart';

final class XPayEmbeddedApp extends StatelessWidget {
  const XPayEmbeddedApp({super.key, required this.navigatorKey, required this.navigatorObserver});

  final GlobalKey<NavigatorState> navigatorKey;
  final NavigatorObserver navigatorObserver;

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigatorKey,
    navigatorObservers: [navigatorObserver],
    debugShowCheckedModeBanner: false,
    home: const _XPayEmbeddedIdleView(),
  );
}

final class _XPayEmbeddedIdleView extends StatelessWidget {
  const _XPayEmbeddedIdleView();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: XPColorSurface.defaultColor,
    body: XPPlatformSafeAreaView(child: XPCupertinoLoadingWidget()),
  );
}

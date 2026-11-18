import 'package:flutter/widgets.dart';

import 'src/embedded/xpay_embedded_api.g.dart';
import 'src/embedded/xpay_embedded_app.dart';
import 'src/embedded/xpay_embedded_bridge.dart';

@pragma('vm:entry-point')
void xpayEmbeddedMain() {
  WidgetsFlutterBinding.ensureInitialized();

  final navigatorKey = GlobalKey<NavigatorState>();
  final bridge = XPayEmbeddedBridge(navigatorKey, XPayEmbeddedHostApi());
  XPayEmbeddedFlutterApi.setUp(bridge);
  runApp(XPayEmbeddedApp(navigatorKey: navigatorKey, navigatorObserver: bridge));
}

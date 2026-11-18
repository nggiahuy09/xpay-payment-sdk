import 'package:flutter/material.dart';

import 'xpay_demo_page.dart';

final class XPayDemoApp extends StatelessWidget {
  const XPayDemoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'XPay SDK Demo',
    theme: ThemeData(colorSchemeSeed: const Color(0xFF1F6FEB), useMaterial3: true),
    home: const XPayDemoPage(),
  );
}

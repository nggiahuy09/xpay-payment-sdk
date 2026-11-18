import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remixicon/remixicon.dart';
import 'package:xpay_payment_sdk/src/base/localization/localization.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/xpay_qr_prefix.dart';
import 'package:xpay_payment_sdk/src/di/di.dart';
import 'package:xpay_payment_sdk/src/methods/scan_qr/presentation/views/card_qr_scan_page.dart';
import 'package:xpay_payment_sdk/src/methods/scan_qr/presentation/widgets/camera_permission_blocked_widget.dart';
import 'package:xpay_payment_sdk/src/shared/snack_bar/snack_bar_manager.dart';

import '../../../helpers/capture_page_harness.dart';

const _permissionChannel = MethodChannel('flutter.baseflow.com/permissions/methods');

const int _kDenied = 0;

const int _kCameraPermission = 1;

const String _title = 'Scan card QR';

void main() {
  setUpAll(() {
    XPLocalization.instance.changeLocale(XPLocale.en);
    getIt.registerLazySingleton(SnackBarCubit.new);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_permissionChannel, (call) async {
      return switch (call.method) {
        'checkPermissionStatus' => _kDenied,
        'requestPermissions' => {_kCameraPermission: _kDenied},
        _ => null,
      };
    });
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_permissionChannel, null);
    await getIt.reset();
  });

  testWidgets('a blocked camera shows the settings prompt instead of the scanner', (tester) async {
    await pushCapturePage<String>(tester, const CardQrScanPage(prefix: XpayQrPrefix.xpCard, title: _title, amount: 100000.0));
    await tester.pump();

    expect(find.text(_title), findsOneWidget);
    expect(find.byType(CameraPermissionBlockedWidget), findsOneWidget);
    expect(find.text(XPLocalization.instance.locale.payment.xpay.cameraPermissionRequiredTitle), findsOneWidget);
  });

  testWidgets('closing the scanner hands back no QR', (tester) async {
    final recorder = await pushCapturePage<String>(tester, const CardQrScanPage(prefix: XpayQrPrefix.xpCard, title: _title, amount: 100000.0));
    await tester.pump();

    await tester.tap(find.byIcon(Remix.close_line).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(recorder.isPopped, isTrue);
    expect(recorder.result, isNull);
  });
}

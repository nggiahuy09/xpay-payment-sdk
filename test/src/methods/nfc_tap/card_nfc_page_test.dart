import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:remixicon/remixicon.dart';
import 'package:xpay_payment_sdk/src/base/domain/domain.dart';
import 'package:xpay_payment_sdk/src/base/localization/localization.dart';
import 'package:xpay_payment_sdk/src/di/di.dart';
import 'package:xpay_payment_sdk/src/methods/nfc_tap/domain/entities/chip_tap_cryptogram_entity.dart';
import 'package:xpay_payment_sdk/src/methods/nfc_tap/domain/entities/chip_tap_prepare_entity.dart';
import 'package:xpay_payment_sdk/src/methods/nfc_tap/domain/repositories/chip_tap_repo.dart';
import 'package:xpay_payment_sdk/src/methods/nfc_tap/presentation/views/card_nfc_page.dart';
import 'package:xpay_payment_sdk/src/methods/nfc_tap/presentation/widgets/card_nfc_not_enabled_widget.dart';
import 'package:xpay_payment_sdk/src/shared/business_logger/xp_business_logger.dart';
import 'package:xpay_payment_sdk/src/shared/snack_bar/snack_bar_manager.dart';

import '../../../helpers/capture_page_harness.dart';

final class _UnusedChipTapRepository extends ChipTapRepository {
  @override
  Future<Either<XPException, ChipTapPrepareEntity>> prepare({required String chipUid}) async => throw UnimplementedError();

  @override
  Future<Either<XPException, ChipTapCryptogramEntity>> sign({required String chipUid, required int counter}) async => throw UnimplementedError();
}

void main() {
  setUpAll(() {
    XPLocalization.instance.changeLocale(XPLocale.en);
    getIt.registerSingleton<ChipTapRepository>(_UnusedChipTapRepository());
    getIt.registerSingleton(const XPBusinessLogger(null));
    getIt.registerLazySingleton(SnackBarCubit.new);
  });

  tearDownAll(() => getIt.reset());

  testWidgets('a handset whose NFC is unavailable shows the not-enabled screen with its settings shortcut', (tester) async {
    await pushCapturePage<ChipTapCryptogramEntity>(tester, const CardNfcPage(amount: 100000.0));
    await tester.pump();

    final xpayLocale = XPLocalization.instance.locale.payment.xpay;
    expect(find.text(xpayLocale.nfcTitle), findsOneWidget);
    expect(find.byType(CardNfcNotEnabledWidget), findsOneWidget);
    expect(find.text(xpayLocale.openSettings), findsOneWidget);
  });

  testWidgets('closing the tap screen hands back no cryptogram', (tester) async {
    final recorder = await pushCapturePage<ChipTapCryptogramEntity>(tester, const CardNfcPage(amount: 100000.0));
    await tester.pump();

    await tester.tap(find.byIcon(Remix.close_line).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(recorder.isPopped, isTrue);
    expect(recorder.result, isNull);
  });
}

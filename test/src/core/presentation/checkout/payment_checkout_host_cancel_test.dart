import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:xpay_payment_sdk/src/base/domain/domain.dart';
import 'package:xpay_payment_sdk/src/base/localization/localization.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/create_payment_product_type_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_authorize_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_checkout_result_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_decline_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_entry_mode_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_method_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_order_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_session_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_trip_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/ride_payment_status_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/repositories/payment_authorize_repo.dart';
import 'package:xpay_payment_sdk/src/core/domain/repositories/ride_payment_repo.dart';
import 'package:xpay_payment_sdk/src/core/presentation/checkout/views/payment_checkout_page.dart';
import 'package:xpay_payment_sdk/src/core/presentation/checkout/views/payment_checkout_paid_view.dart';
import 'package:xpay_payment_sdk/src/core/presentation/checkout/widgets/payment_failure_sheet_widget.dart';
import 'package:xpay_payment_sdk/src/core/presentation/payment/helpers/payment_authorize_idempotency_tracker.dart';
import 'package:xpay_payment_sdk/src/core/presentation/payment/helpers/payment_host_cancellation.dart';
import 'package:xpay_payment_sdk/src/di/di.dart';
import 'package:xpay_payment_sdk/src/shared/business_logger/xp_business_logger.dart';
import 'package:xpay_payment_sdk/src/shared/snack_bar/snack_bar_manager.dart';

import '../../../../helpers/recording_authorize_repository.dart';

final _authorizeRepository = RecordingAuthorizeRepository();

const _session = PaymentSessionEntity(
  entryModes: [PaymentEntryMode.manualPan],
  order: PaymentOrderEntity(productType: CreatePaymentProductType.taxiTrip, currency: 'VND', externalRef: 'XP-1048', amount: 138000),
  trip: PaymentTripEntity(),
  method: PaymentMethod.card,
  sessionToken: 'rps_token',
);

final class _OpenRideRepository extends RidePaymentRepository {
  @override
  Future<Either<XPException, RidePaymentStatusEntity>> getStatus() async => const Right(RidePaymentStatusEntity(rideStatus: RideStatus.riding, externalRef: 'XP-1048'));
}

final class _ResultRecorder {
  PaymentCheckoutResultEntity? result;
  bool isClosed = false;
}

Future<_ResultRecorder> _openManualEntry(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170.0, 2532.0);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final recorder = _ResultRecorder();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            recorder.result = await Navigator.of(context).push(
              MaterialPageRoute<PaymentCheckoutResultEntity>(
                builder: (_) => const PaymentCheckoutPage(entryModes: [PaymentEntryMode.manualPan], session: _session),
              ),
            );
            recorder.isClosed = true;
          },
          child: const Text('pay'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('pay'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(XPLocalization.instance.locale.payment.xpay.methodManualPanTitle));
  await tester.pumpAndSettle();
  return recorder;
}

Future<void> _submitPanAndHold(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), '4111111111111111');
  await tester.pump();
  await tester.tap(find.text(XPLocalization.instance.locale.payment.create.manualEntrySubmitButton));
  await tester.pump();
}

void main() {
  setUpAll(() {
    XPLocalization.instance.changeLocale(XPLocale.en);
    getIt.registerSingleton<PaymentAuthorizeRepository>(_authorizeRepository);
    getIt.registerSingleton<RidePaymentRepository>(_OpenRideRepository());
    getIt.registerSingleton(PaymentAuthorizeIdempotencyTracker());
    getIt.registerSingleton(PaymentHostCancellation());
    getIt.registerSingleton(const XPBusinessLogger(null));
    getIt.registerLazySingleton(SnackBarCubit.new);
  });

  tearDownAll(() => getIt.reset());

  setUp(() {
    _authorizeRepository.clear();
    getIt.get<PaymentAuthorizeIdempotencyTracker>().release();
  });

  testWidgets('a decline after the app closed the SDK during the authorization returns cancelled instead of a popup nobody sees', (tester) async {
    final gate = Completer<void>();
    _authorizeRepository.gate = gate;
    _authorizeRepository.nextAuthorize = PaymentAuthorizeEntity(
      status: PaymentAuthorizeStatus.declined,
      authId: 'auth-1',
      declineReason: PaymentDeclineEntity.fromRemote('insufficient_funds'),
    );
    final recorder = await _openManualEntry(tester);
    await _submitPanAndHold(tester);

    expect(getIt.get<PaymentHostCancellation>().request(), isTrue);
    await tester.pump();
    expect(recorder.isClosed, isFalse);

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.byType(PaymentFailureSheetWidget), findsNothing);
    expect(recorder.isClosed, isTrue);
    expect(recorder.result, isA<PaymentCheckoutCancelledResultEntity>());
  });

  testWidgets('an approval after the app closed the SDK during the authorization returns paid at once, without the success screen', (tester) async {
    final gate = Completer<void>();
    _authorizeRepository.gate = gate;
    _authorizeRepository.nextAuthorize = const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.approved, authId: 'auth-2');
    final recorder = await _openManualEntry(tester);
    await _submitPanAndHold(tester);

    getIt.get<PaymentHostCancellation>().request();
    gate.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PaymentCheckoutPaidView), findsNothing);
    expect(recorder.isClosed, isTrue);
    expect(recorder.result, isA<PaymentCheckoutPaidResultEntity>().having((r) => r.payment.authId, 'authId', 'auth-2'));
  });

  testWidgets('a new payment starts without the cancellation of the previous one', (tester) async {
    final cancellation = getIt.get<PaymentHostCancellation>();
    void previousFlow() {}
    cancellation
      ..attach(previousFlow)
      ..request()
      ..detach(previousFlow);
    _authorizeRepository.nextAuthorize = PaymentAuthorizeEntity(
      status: PaymentAuthorizeStatus.declined,
      authId: 'auth-3',
      declineReason: PaymentDeclineEntity.fromRemote('insufficient_funds'),
    );
    final recorder = await _openManualEntry(tester);
    await tester.enterText(find.byType(TextField), '4111111111111111');
    await tester.pump();
    await tester.tap(find.text(XPLocalization.instance.locale.payment.create.manualEntrySubmitButton));
    await tester.pumpAndSettle();

    expect(find.byType(PaymentFailureSheetWidget), findsOneWidget);
    expect(recorder.isClosed, isFalse);
  });
}

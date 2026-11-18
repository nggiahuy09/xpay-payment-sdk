import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/src/base/domain/domain.dart';
import 'package:xpay_payment_sdk/src/base/localization/localization.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/create_payment_product_type_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_authorize_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_entry_mode_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_flow_outcome_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_order_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_session_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_trip_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_verification_recipient_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/repositories/payment_authorize_repo.dart';
import 'package:xpay_payment_sdk/src/core/presentation/payment/helpers/payment_authorize_idempotency_tracker.dart';
import 'package:xpay_payment_sdk/src/core/presentation/payment/views/xpay_payment_page.dart';
import 'package:xpay_payment_sdk/src/di/di.dart';
import 'package:xpay_payment_sdk/src/shared/business_logger/xp_business_logger.dart';
import 'package:xpay_payment_sdk/src/shared/snack_bar/snack_bar_manager.dart';

import '../../../../helpers/recording_authorize_repository.dart';

final _repository = RecordingAuthorizeRepository();

const _session = PaymentSessionEntity(
  entryModes: [PaymentEntryMode.manualPan],
  order: PaymentOrderEntity(productType: CreatePaymentProductType.taxiTrip, currency: 'VND', externalRef: 'ACME_1234', amount: 100000),
  trip: PaymentTripEntity(),
  sessionToken: 'rps_token',
);

final class _OutcomeRecorder {
  PaymentFlowOutcomeEntity? outcome;
  bool isCompleted = false;
}

Future<_OutcomeRecorder> _openManualEntry(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170.0, 2532.0);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final recorder = _OutcomeRecorder();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            recorder.outcome = await Navigator.of(context).push(
              MaterialPageRoute<PaymentFlowOutcomeEntity>(
                builder: (_) => const XPayPaymentPage(entryModes: [PaymentEntryMode.manualPan], session: _session),
              ),
            );
            recorder.isCompleted = true;
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

Future<void> _submitPan(WidgetTester tester, String pan) async {
  final viewLocale = XPLocalization.instance.locale.payment.create;
  await tester.enterText(find.byType(TextField), pan);
  await tester.pump();
  await tester.tap(find.text(viewLocale.manualEntrySubmitButton));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    XPLocalization.instance.changeLocale(XPLocale.en);
    getIt.registerSingleton<PaymentAuthorizeRepository>(_repository);
    getIt.registerSingleton(PaymentAuthorizeIdempotencyTracker());
    getIt.registerSingleton(const XPBusinessLogger(null));
    getIt.registerLazySingleton(SnackBarCubit.new);
  });

  tearDownAll(() => getIt.reset());

  setUp(() {
    _repository.clear();
    getIt.get<PaymentAuthorizeIdempotencyTracker>().release();
  });

  testWidgets('the manual entry screen opens first, and an approved PAN completes the flow with the authorization', (tester) async {
    _repository.nextAuthorize = const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.approved, authId: 'auth-1');
    final recorder = await _openManualEntry(tester);

    expect(find.text(XPLocalization.instance.locale.payment.create.manualEntryTitle), findsOneWidget);

    await _submitPan(tester, '4111111111111111');

    expect(recorder.isCompleted, isTrue);
    expect(
      recorder.outcome,
      isA<PaymentFlowAuthorizedOutcomeEntity>().having((o) => o.authorize.authId, 'authId', 'auth-1').having((o) => o.entryMode, 'entryMode', PaymentEntryMode.manualPan),
    );
    expect(_repository.cardTokens.single, '4111111111111111');
  });

  testWidgets('a request failure completes the flow as failed, carrying the error code', (tester) async {
    _repository.nextFailure = const XPApiException(errorCode: 'internal_error', statusCode: 500);
    final recorder = await _openManualEntry(tester);

    await _submitPan(tester, '4111111111111111');

    expect(recorder.outcome, isA<PaymentFlowFailedOutcomeEntity>().having((o) => o.errorCode, 'errorCode', 'internal_error'));
  });

  testWidgets('a 409 completes the flow as a conflict', (tester) async {
    _repository.nextFailure = const XPConflictException(errorCode: 'idempotency_key_reuse');
    final recorder = await _openManualEntry(tester);

    await _submitPan(tester, '4111111111111111');

    expect(recorder.outcome, isA<PaymentFlowConflictOutcomeEntity>());
  });

  testWidgets('going back from manual entry returns to the method list, and going back again cancels without authorizing', (tester) async {
    final recorder = await _openManualEntry(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(recorder.isCompleted, isFalse);
    expect(find.text(XPLocalization.instance.locale.payment.xpay.entryMethodsTitle.toUpperCase()), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(recorder.isCompleted, isTrue);
    expect(recorder.outcome, isA<PaymentFlowCancelledOutcomeEntity>().having((o) => o.authId, 'authId', isNull));
    expect(_repository.idempotencyKeys, isEmpty);
  });

  testWidgets('a manual PAN awaiting a recipient asks for one first, and dismissing it cancels while keeping the authorization', (tester) async {
    _repository.nextAuthorize = const PaymentAuthorizeEntity(
      status: PaymentAuthorizeStatus.pendingVerification,
      authId: 'auth-1',
      verification: PaymentAuthorizeVerificationEntity(
        recipients: [PaymentVerificationRecipientEntity(recipientId: 'r-1', phoneMasked: '+84 *** *** 123')],
        method: PaymentAuthorizeVerificationMethod.smsOtp,
        isRecipientRequired: true,
      ),
    );
    final verificationLocale = XPLocalization.instance.locale.payment.verification;
    final recorder = await _openManualEntry(tester);

    await _submitPan(tester, '4111111111111111');

    expect(find.text(verificationLocale.recipientPickerTitle), findsOneWidget);
    expect(recorder.isCompleted, isFalse);

    await tester.tap(find.text(verificationLocale.recipientCancelButton));
    await tester.pumpAndSettle();

    expect(recorder.outcome, isA<PaymentFlowCancelledOutcomeEntity>().having((o) => o.authId, 'authId', 'auth-1'));
  });
}

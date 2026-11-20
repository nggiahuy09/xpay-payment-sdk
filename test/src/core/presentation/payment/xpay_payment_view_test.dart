import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remixicon/remixicon.dart';
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
import 'package:xpay_payment_sdk/src/core/presentation/payment/helpers/payment_host_cancellation.dart';
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

Future<_OutcomeRecorder> _openMethodList(WidgetTester tester) async {
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
  return recorder;
}

Future<_OutcomeRecorder> _openManualEntry(WidgetTester tester) async {
  final recorder = await _openMethodList(tester);
  await tester.tap(find.text(XPLocalization.instance.locale.payment.xpay.methodManualPanTitle));
  await tester.pumpAndSettle();
  return recorder;
}

/// The loading overlay never settles while the gate holds the authorization.
Future<void> _submitPanAndHold(WidgetTester tester, String pan) async {
  final viewLocale = XPLocalization.instance.locale.payment.create;
  await tester.enterText(find.byType(TextField), pan);
  await tester.pump();
  await tester.tap(find.text(viewLocale.manualEntrySubmitButton));
  await tester.pump();
}

/// The verification countdown never settles.
Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  for (var elapsed = Duration.zero; elapsed < duration; elapsed += const Duration(milliseconds: 100)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

const _pinVerification = PaymentAuthorizeVerificationEntity(method: PaymentAuthorizeVerificationMethod.staticCode);

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
    getIt.registerSingleton(PaymentHostCancellation());
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

    expect(
      recorder.outcome,
      isA<PaymentFlowAuthorizeFailedOutcomeEntity>().having((o) => o.errorCode, 'errorCode', 'internal_error').having((o) => o.entryMode, 'entryMode', PaymentEntryMode.manualPan),
    );
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

  testWidgets('on iOS the method list has a back button that cancels without authorizing', (tester) async {
    final recorder = await _openMethodList(tester);

    await tester.tap(find.byIcon(Remix.arrow_left_line));
    await tester.pumpAndSettle();

    expect(recorder.isCompleted, isTrue);
    expect(recorder.outcome, isA<PaymentFlowCancelledOutcomeEntity>().having((o) => o.authId, 'authId', isNull));
    expect(_repository.idempotencyKeys, isEmpty);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('on Android the method list has no back button of its own', (tester) async {
    await _openMethodList(tester);

    expect(find.byIcon(Remix.arrow_left_line), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('a host cancel on the method list cancels at once, without an authorization', (tester) async {
    final recorder = await _openMethodList(tester);

    expect(getIt.get<PaymentHostCancellation>().request(), isTrue);
    await tester.pumpAndSettle();

    expect(recorder.outcome, isA<PaymentFlowCancelledOutcomeEntity>().having((o) => o.authId, 'authId', isNull));
    expect(_repository.idempotencyKeys, isEmpty);
  });

  testWidgets('a host cancel while the card is authorizing waits for the authorization and returns its outcome', (tester) async {
    final gate = Completer<void>();
    _repository.gate = gate;
    _repository.nextAuthorize = const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.approved, authId: 'auth-1');
    final recorder = await _openManualEntry(tester);
    await _submitPanAndHold(tester, '4111111111111111');

    expect(getIt.get<PaymentHostCancellation>().request(), isTrue);
    await tester.pump();

    expect(recorder.isCompleted, isFalse);

    gate.complete();
    await tester.pumpAndSettle();

    expect(
      recorder.outcome,
      isA<PaymentFlowAuthorizedOutcomeEntity>().having((o) => o.authorize.authId, 'authId', 'auth-1').having((o) => o.authorize.isApproved, 'isApproved', isTrue),
    );
  });

  testWidgets('a host cancel while authorizing a payment that then needs verification ends as cancelled with its authorization', (tester) async {
    final gate = Completer<void>();
    _repository.gate = gate;
    _repository.nextAuthorize = const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.pendingVerification, authId: 'auth-2', verification: _pinVerification);
    final recorder = await _openManualEntry(tester);
    await _submitPanAndHold(tester, '4111111111111111');

    getIt.get<PaymentHostCancellation>().request();
    gate.complete();
    await _pumpFor(tester, const Duration(seconds: 1));

    expect(recorder.outcome, isA<PaymentFlowCancelledOutcomeEntity>().having((o) => o.authId, 'authId', 'auth-2'));
    expect(find.text(XPLocalization.instance.locale.payment.verification.pinTitle), findsNothing);
  });

  testWidgets('a host cancel during verification keeps the authorization in the cancelled outcome', (tester) async {
    _repository.nextAuthorize = const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.pendingVerification, authId: 'auth-3', verification: _pinVerification);
    final recorder = await _openManualEntry(tester);
    await _submitPanAndHold(tester, '4111111111111111');
    await _pumpFor(tester, const Duration(seconds: 1));

    expect(find.text(XPLocalization.instance.locale.payment.verification.pinTitle), findsOneWidget);
    expect(recorder.isCompleted, isFalse);

    getIt.get<PaymentHostCancellation>().request();
    await _pumpFor(tester, const Duration(seconds: 1));

    expect(recorder.outcome, isA<PaymentFlowCancelledOutcomeEntity>().having((o) => o.authId, 'authId', 'auth-3'));
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

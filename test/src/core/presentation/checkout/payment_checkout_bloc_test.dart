import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:xpay_payment_sdk/src/base/domain/domain.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/create_payment_product_type_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_authorize_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_checkout_result_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_decline_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_failure_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_flow_outcome_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_method_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_order_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/ride_payment_status_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/repositories/ride_payment_repo.dart';
import 'package:xpay_payment_sdk/src/core/presentation/checkout/blocs/payment_checkout_bloc.dart';
import 'package:xpay_payment_sdk/src/core/presentation/payment/helpers/payment_authorize_idempotency_tracker.dart';
import 'package:xpay_payment_sdk/src/di/di.dart';
import 'package:xpay_payment_sdk/src/shared/business_logger/xp_business_logger.dart';

const _order = PaymentOrderEntity(productType: CreatePaymentProductType.taxiTrip, currency: 'VND', externalRef: 'XP-1048', amount: 138000);

const _openRide = RidePaymentStatusEntity(rideStatus: RideStatus.riding, externalRef: 'XP-1048');

const _paidByHotline = RidePaymentStatusEntity(
  payment: RidePaymentEntity(method: PaymentMethod.card, paidBy: RidePaymentPayer.cs, authId: 'auth-cs', amount: '138000.00'),
  rideStatus: RideStatus.completed,
  externalRef: 'XP-1048',
);

final _repository = _FakeRidePaymentRepository();

final class _FakeRidePaymentRepository extends RidePaymentRepository {
  final List<Either<XPException, RidePaymentStatusEntity>> _responses = [];

  int calls = 0;

  void reply(List<Either<XPException, RidePaymentStatusEntity>> responses) => _responses
    ..clear()
    ..addAll(responses);

  @override
  Future<Either<XPException, RidePaymentStatusEntity>> getStatus() async {
    calls++;
    return _responses.isEmpty ? const Right(_openRide) : _responses.removeAt(0);
  }
}

PaymentFlowAuthorizedOutcomeEntity _declined(String reason, String authId) =>
    PaymentFlowAuthorizedOutcomeEntity(PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.declined, authId: authId, declineReason: PaymentDeclineEntity.fromRemote(reason)));

Future<PaymentCheckoutBloc> _open({PaymentMethod method = PaymentMethod.card}) async {
  final bloc = PaymentCheckoutBloc(order: _order, method: method, canPayByCard: true);
  addTearDown(bloc.close);
  await pumpEventQueue();
  return bloc;
}

Future<void> _report(PaymentCheckoutBloc bloc, PaymentFlowOutcomeEntity outcome) async {
  bloc.add(PaymentCheckoutOutcomeReportedEvent(outcome));
  await pumpEventQueue();
}

Future<List<PaymentCheckoutState>> _reportAfterHostCancel(PaymentCheckoutBloc bloc, PaymentFlowOutcomeEntity outcome) async {
  final states = <PaymentCheckoutState>[];
  final subscription = bloc.stream.listen(states.add);
  addTearDown(subscription.cancel);
  bloc.add(PaymentCheckoutOutcomeReportedEvent(outcome, true));
  await pumpEventQueue();
  return states;
}

Future<PaymentCheckoutBloc> _waitForHotline(WidgetTester tester, PaymentFlowOutcomeEntity outcome) async {
  final bloc = PaymentCheckoutBloc(order: _order, method: PaymentMethod.card, canPayByCard: true);
  addTearDown(bloc.close);
  await tester.pump();
  bloc.add(PaymentCheckoutOutcomeReportedEvent(outcome));
  await tester.pump();
  bloc.add(const PaymentCheckoutHotlineConfirmedEvent());
  bloc.add(const PaymentCheckoutHotlinePayPressedEvent());
  await tester.pump();
  return bloc;
}

void main() {
  setUpAll(() {
    getIt.registerSingleton<RidePaymentRepository>(_repository);
    getIt.registerSingleton(const XPBusinessLogger(null));
    getIt.registerSingleton(PaymentAuthorizeIdempotencyTracker());
  });

  tearDownAll(() => getIt.reset());

  setUp(() {
    _repository.reply([]);
    _repository.calls = 0;
  });

  group('opening the module', () {
    test('an open ride goes straight to the method list', () async {
      final bloc = await _open();

      expect(bloc.state, isA<PaymentCheckoutCollectingState>().having((s) => s.attempt, 'attempt', 0));
      expect(_repository.calls, 1);
    });

    test('a ride the hotline already paid shows the success screen with what it charged', () async {
      _repository.reply([const Right(_paidByHotline)]);

      final bloc = await _open();

      expect(
        bloc.state,
        isA<PaymentCheckoutPaidState>()
            .having((s) => s.payment.paidBy, 'paidBy', RidePaymentPayer.cs)
            .having((s) => s.payment.amount, 'amount', '138000.00')
            .having((s) => s.payment.currency, 'currency', 'VND'),
      );
    });

    test('a ride closed without a payment, or cancelled, ends on screen D', () async {
      _repository.reply([const Right(RidePaymentStatusEntity(rideStatus: RideStatus.completed, externalRef: 'XP-1048'))]);
      final completed = await _open();
      expect(completed.state, isA<PaymentCheckoutRideClosedState>().having((s) => s.settlement, 'settlement', RideSettlement.closedWithoutPayment));

      _repository.reply([const Right(RidePaymentStatusEntity(rideStatus: RideStatus.cancelled, externalRef: 'XP-1048'))]);
      final cancelled = await _open();
      expect(cancelled.state, isA<PaymentCheckoutRideClosedState>().having((s) => s.settlement, 'settlement', RideSettlement.cancelled));
    });

    test('a failed status check does not block the payment', () async {
      _repository.reply([const Left(XPNetworkException.timeout())]);

      final bloc = await _open();

      expect(bloc.state, isA<PaymentCheckoutCollectingState>());
    });
  });

  group('retry in the SDK', () {
    test('a card decline offers a retry that rebuilds the method screen', () async {
      final bloc = await _open();

      await _report(bloc, _declined('insufficient_funds', 'auth-1'));
      expect(bloc.state, isA<PaymentCheckoutFailedState>().having((s) => s.failure.route, 'route', PaymentFailureRoute.retryInSdk));

      bloc.add(const PaymentCheckoutRetryPressedEvent());
      await pumpEventQueue();
      expect(bloc.state, isA<PaymentCheckoutCollectingState>().having((s) => s.attempt, 'attempt', 1));
    });

    test('the third failure in a row sends the driver to the hotline, and another method reports the last decline', () async {
      final bloc = await _open();

      for (var attempt = 1; attempt <= 2; attempt++) {
        await _report(bloc, _declined('insufficient_funds', 'auth-$attempt'));
        bloc.add(const PaymentCheckoutRetryPressedEvent());
        await pumpEventQueue();
      }
      await _report(bloc, _declined('card_expired', 'auth-3'));

      expect(bloc.state, isA<PaymentCheckoutFailedState>().having((s) => s.failure.kind, 'kind', PaymentFailureKind.retriesExhausted));

      bloc.add(const PaymentCheckoutHotlineConfirmedEvent());
      await pumpEventQueue();
      expect(bloc.state, isA<PaymentCheckoutOptionsState>().having((s) => s.keepsMethod, 'keepsMethod', isFalse));

      bloc.add(const PaymentCheckoutOtherMethodPressedEvent());
      await pumpEventQueue();
      expect(
        bloc.state,
        isA<PaymentCheckoutClosedState>().having(
          (s) => s.result,
          'result',
          isA<PaymentCheckoutOtherMethodResultEntity>().having((r) => r.failure.authId, 'authId', 'auth-3'),
        ),
      );
    });

    test('trying XPAY again after the hotline starts a fresh count', () async {
      final bloc = await _open();
      for (var attempt = 1; attempt <= 3; attempt++) {
        await _report(bloc, _declined('insufficient_funds', 'auth-$attempt'));
        if (attempt < 3) bloc.add(const PaymentCheckoutRetryPressedEvent());
        await pumpEventQueue();
      }
      bloc.add(const PaymentCheckoutHotlineConfirmedEvent());
      bloc.add(const PaymentCheckoutRetryXpayPressedEvent());
      await pumpEventQueue();

      await _report(bloc, _declined('insufficient_funds', 'auth-4'));

      expect(bloc.state, isA<PaymentCheckoutFailedState>().having((s) => s.failure.route, 'route', PaymentFailureRoute.retryInSdk));
    });
  });

  group('idempotency key on retry', () {
    test('a retry after a decline sends a new key, so the server decides again instead of replaying the decline', () async {
      final tracker = getIt.get<PaymentAuthorizeIdempotencyTracker>();
      final declinedKey = tracker.start('same-card-same-ride');
      final bloc = await _open();

      await _report(bloc, _declined('verification_expired', 'auth-1'));
      bloc.add(const PaymentCheckoutRetryPressedEvent());
      await pumpEventQueue();

      expect(tracker.start('same-card-same-ride'), isNot(declinedKey));
    });

    test('trying XPAY again after a system error keeps the key, so a payment that went through is replayed instead of charged twice', () async {
      final tracker = getIt.get<PaymentAuthorizeIdempotencyTracker>();
      final unknownKey = tracker.start('same-card-same-ride-2');
      final bloc = await _open();

      await _report(bloc, const PaymentFlowFailedOutcomeEntity(errorCode: 'internal_error'));
      bloc.add(const PaymentCheckoutHotlineConfirmedEvent());
      bloc.add(const PaymentCheckoutRetryXpayPressedEvent());
      await pumpEventQueue();

      expect(tracker.start('same-card-same-ride-2'), unknownKey);
    });
  });

  test('a verify failure keeps the transaction still waiting for its code for the partner to void', () async {
    final bloc = await _open();

    await _report(bloc, const PaymentFlowFailedOutcomeEntity(errorCode: 'internal_error', pendingAuthId: 'auth-pending'));
    bloc.add(const PaymentCheckoutHotlineConfirmedEvent());
    bloc.add(const PaymentCheckoutOtherMethodPressedEvent());
    await pumpEventQueue();

    expect(
      bloc.state,
      isA<PaymentCheckoutClosedState>().having(
        (s) => s.result,
        'result',
        isA<PaymentCheckoutOtherMethodResultEntity>().having((r) => r.failure.pendingAuthId, 'pendingAuthId', 'auth-pending'),
      ),
    );
  });

  group('retry in the partner app', () {
    test('a changed fare closes the module as retryable', () async {
      final bloc = await _open();

      await _report(bloc, const PaymentFlowFailedOutcomeEntity(errorCode: 'ride_payment_session_revoked'));
      expect(bloc.state, isA<PaymentCheckoutFailedState>().having((s) => s.failure.route, 'route', PaymentFailureRoute.retryInPartner));

      bloc.add(const PaymentCheckoutBackToPartnerPressedEvent());
      await pumpEventQueue();
      expect(
        bloc.state,
        isA<PaymentCheckoutClosedState>().having(
          (s) => s.result,
          'result',
          isA<PaymentCheckoutRetryInPartnerResultEntity>().having((r) => r.failure.kind, 'kind', PaymentFailureKind.fareChanged),
        ),
      );
    });
  });

  group('amount locked', () {
    test('a 409 on the locked amount is a changed fare reported as other', () async {
      final bloc = await _open();

      await _report(bloc, const PaymentFlowConflictOutcomeEntity(errorCode: 'amount_locked', pendingAuthId: 'auth-1'));

      expect(
        bloc.state,
        isA<PaymentCheckoutFailedState>().having((s) => s.failure.kind, 'kind', PaymentFailureKind.fareChanged).having((s) => s.failure.pendingAuthId, 'pendingAuthId', 'auth-1'),
      );
    });

    test('a 422 on the locked amount is an integration error reported as an SDK error', () async {
      final bloc = await _open();

      await _report(bloc, const PaymentFlowFailedOutcomeEntity(errorCode: 'amount_locked'));

      expect(
        bloc.state,
        isA<PaymentCheckoutFailedState>()
            .having((s) => s.failure.kind, 'kind', PaymentFailureKind.integrationError)
            .having((s) => s.failure.reason, 'reason', PaymentFailureReason.sdkError),
      );
    });
  });

  group('ride already settled', () {
    test('ride_already_paid shows the payment the ride already has instead of an error', () async {
      final bloc = await _open();
      _repository.reply([const Right(_paidByHotline)]);

      await _report(bloc, const PaymentFlowConflictOutcomeEntity(errorCode: 'ride_already_paid'));

      expect(bloc.state, isA<PaymentCheckoutPaidState>().having((s) => s.payment.authId, 'authId', 'auth-cs'));
    });

    test('when the ride shows no payment after all, the driver calls the hotline', () async {
      final bloc = await _open();

      await _report(bloc, const PaymentFlowFailedOutcomeEntity(errorCode: 'ride_already_paid'));

      expect(bloc.state, isA<PaymentCheckoutFailedState>().having((s) => s.failure.kind, 'kind', PaymentFailureKind.systemError));
    });
  });

  group('corporate wallet refused', () {
    test('the hotline keeps the code screen, and trying XPAY again returns to it', () async {
      final bloc = await _open(method: PaymentMethod.corporateWallet);

      await _report(bloc, const PaymentFlowWalletInterruptedOutcomeEntity('corporate_wallet_refused'));
      expect(bloc.state, isA<PaymentCheckoutFailedState>().having((s) => s.failure.route, 'route', PaymentFailureRoute.callHotline));

      bloc.add(const PaymentCheckoutHotlineConfirmedEvent());
      await pumpEventQueue();
      expect(bloc.state, isA<PaymentCheckoutOptionsState>().having((s) => s.keepsMethod, 'keepsMethod', isTrue));

      bloc.add(const PaymentCheckoutRetryXpayPressedEvent());
      await pumpEventQueue();
      expect(bloc.state, isA<PaymentCheckoutCollectingState>().having((s) => s.attempt, 'attempt', 0));
    });
  });

  group('corporate wallet unavailable', () {
    test('after the SDK retried the code, the driver calls the hotline and can return to the same code', () async {
      final bloc = await _open(method: PaymentMethod.corporateWallet);

      await _report(bloc, const PaymentFlowWalletInterruptedOutcomeEntity('corporate_wallet_unavailable'));
      expect(
        bloc.state,
        isA<PaymentCheckoutFailedState>()
            .having((s) => s.failure.kind, 'kind', PaymentFailureKind.systemError)
            .having((s) => s.failure.reason, 'reason', PaymentFailureReason.sdkError)
            .having((s) => s.failure.isResumable, 'isResumable', isTrue),
      );

      bloc.add(const PaymentCheckoutHotlineConfirmedEvent());
      await pumpEventQueue();
      expect(bloc.state, isA<PaymentCheckoutOptionsState>().having((s) => s.keepsMethod, 'keepsMethod', isTrue));
    });
  });

  group('waiting for the hotline', () {
    testWidgets('a payment found while polling ends on the success screen', (tester) async {
      final bloc = await _waitForHotline(tester, const PaymentFlowFailedOutcomeEntity(errorCode: 'internal_error'));
      expect(bloc.state, isA<PaymentCheckoutHotlineWaitingState>());

      _repository.reply([const Right(_openRide), const Right(_paidByHotline)]);
      await tester.pump(const Duration(seconds: 5));
      expect(bloc.state, isA<PaymentCheckoutHotlineWaitingState>());

      await tester.pump(const Duration(seconds: 7));
      expect(bloc.state, isA<PaymentCheckoutPaidState>().having((s) => s.payment.paidBy, 'paidBy', RidePaymentPayer.cs));
    });

    testWidgets('five minutes without a payment closes the module as pending on the hotline', (tester) async {
      final bloc = await _waitForHotline(tester, _declined('corporate_monthly_limit_exceeded', 'auth-1'));

      await tester.pump(const Duration(minutes: 4, seconds: 59));
      expect(bloc.state, isA<PaymentCheckoutHotlineWaitingState>());

      await tester.pump(const Duration(seconds: 1));
      expect(
        bloc.state,
        isA<PaymentCheckoutClosedState>().having(
          (s) => s.result,
          'result',
          isA<PaymentCheckoutHotlinePendingResultEntity>().having((r) => r.failure.authId, 'authId', 'auth-1'),
        ),
      );
    });

    test('a cancel from the code screen kept under the wait still closes as pending on the hotline', () async {
      final bloc = await _open(method: PaymentMethod.corporateWallet);
      await _report(bloc, const PaymentFlowWalletInterruptedOutcomeEntity('corporate_wallet_refused'));
      bloc.add(const PaymentCheckoutHotlineConfirmedEvent());
      bloc.add(const PaymentCheckoutHotlinePayPressedEvent());
      await pumpEventQueue();

      await _report(bloc, const PaymentFlowCancelledOutcomeEntity());

      expect(bloc.state, isA<PaymentCheckoutClosedState>().having((s) => s.result, 'result', isA<PaymentCheckoutHotlinePendingResultEntity>()));
    });

    test('leaving the wait closes the module as pending on the hotline', () async {
      final bloc = await _open();
      await _report(bloc, _declined('policy_violation', 'auth-1'));
      bloc.add(const PaymentCheckoutHotlineConfirmedEvent());
      bloc.add(const PaymentCheckoutHotlinePayPressedEvent());
      bloc.add(const PaymentCheckoutHotlineWaitLeftEvent());
      await pumpEventQueue();

      expect(bloc.state, isA<PaymentCheckoutClosedState>().having((s) => s.result, 'result', isA<PaymentCheckoutHotlinePendingResultEntity>()));
    });
  });

  group('app closed the SDK while a screen was still waiting on XPay', () {
    test('a decline closes the module as cancelled instead of showing the failure popup', () async {
      final bloc = await _open();

      final states = await _reportAfterHostCancel(bloc, _declined('insufficient_funds', 'auth-1'));

      expect(states.whereType<PaymentCheckoutFailedState>(), isEmpty);
      expect(bloc.state, isA<PaymentCheckoutClosedState>().having((s) => s.result, 'result', isA<PaymentCheckoutCancelledResultEntity>()));
    });

    test('an error keeps the transaction still waiting for its code', () async {
      final bloc = await _open();

      await _reportAfterHostCancel(bloc, const PaymentFlowConflictOutcomeEntity(errorCode: 'internal_error', pendingAuthId: 'auth-pending'));

      expect(
        bloc.state,
        isA<PaymentCheckoutClosedState>().having(
          (s) => s.result,
          'result',
          isA<PaymentCheckoutCancelledResultEntity>().having((r) => r.pendingAuthId, 'pendingAuthId', 'auth-pending'),
        ),
      );
    });

    test('an approved payment closes the module as paid without the success screen', () async {
      final bloc = await _open();
      const approved = PaymentFlowAuthorizedOutcomeEntity(PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.approved, authId: 'auth-1'));

      final states = await _reportAfterHostCancel(bloc, approved);

      expect(states.whereType<PaymentCheckoutPaidState>(), isEmpty);
      expect(
        bloc.state,
        isA<PaymentCheckoutClosedState>().having(
          (s) => s.result,
          'result',
          isA<PaymentCheckoutPaidResultEntity>().having((r) => r.payment.authId, 'authId', 'auth-1'),
        ),
      );
    });

    test('a ride already paid closes the module as paid with the payment the ride has', () async {
      final bloc = await _open();
      _repository.reply([const Right(_paidByHotline)]);

      await _reportAfterHostCancel(bloc, const PaymentFlowConflictOutcomeEntity(errorCode: 'ride_already_paid'));

      expect(
        bloc.state,
        isA<PaymentCheckoutClosedState>().having(
          (s) => s.result,
          'result',
          isA<PaymentCheckoutPaidResultEntity>().having((r) => r.payment.paidBy, 'paidBy', RidePaymentPayer.cs),
        ),
      );
    });

    test('a ride cancelled meanwhile closes the module as ride closed without screen D', () async {
      final bloc = await _open();
      _repository.reply([const Right(RidePaymentStatusEntity(rideStatus: RideStatus.cancelled, externalRef: 'XP-1048'))]);

      final states = await _reportAfterHostCancel(bloc, const PaymentFlowFailedOutcomeEntity(errorCode: 'ride_not_found'));

      expect(states.whereType<PaymentCheckoutRideClosedState>(), isEmpty);
      expect(
        bloc.state,
        isA<PaymentCheckoutClosedState>().having(
          (s) => s.result,
          'result',
          isA<PaymentCheckoutRideClosedResultEntity>().having((r) => r.settlement, 'settlement', RideSettlement.cancelled),
        ),
      );
    });

    test('a ride on the other method does not reopen the method screen', () async {
      final bloc = await _open();

      final states = await _reportAfterHostCancel(bloc, const PaymentFlowFailedOutcomeEntity(errorCode: 'ride_on_corporate_wallet'));

      expect(states.whereType<PaymentCheckoutCollectingState>(), isEmpty);
      expect(bloc.state, isA<PaymentCheckoutClosedState>().having((s) => s.result, 'result', isA<PaymentCheckoutCancelledResultEntity>()));
    });
  });

  test('a cancel keeps the transaction still waiting for its code', () async {
    final bloc = await _open();

    await _report(bloc, const PaymentFlowCancelledOutcomeEntity('auth-pending'));

    expect(
      bloc.state,
      isA<PaymentCheckoutClosedState>().having(
        (s) => s.result,
        'result',
        isA<PaymentCheckoutCancelledResultEntity>().having((r) => r.pendingAuthId, 'pendingAuthId', 'auth-pending'),
      ),
    );
  });
}

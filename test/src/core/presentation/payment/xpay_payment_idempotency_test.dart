import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:xpay_payment_sdk/src/base/domain/domain.dart';
import 'package:xpay_payment_sdk/src/core/data/datasources/remote/models/payment_authorize_request_model.dart';
import 'package:xpay_payment_sdk/src/core/data/repositories/payment_authorize_repo_mapper.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/create_payment_product_type_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_chip_tap_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_entry_mode_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_order_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/repositories/payment_authorize_repo.dart';
import 'package:xpay_payment_sdk/src/core/presentation/payment/blocs/xpay_payment_bloc.dart';
import 'package:xpay_payment_sdk/src/core/presentation/payment/helpers/payment_authorize_idempotency_tracker.dart';
import 'package:xpay_payment_sdk/src/core/presentation/payment/helpers/payment_host_cancellation.dart';
import 'package:xpay_payment_sdk/src/di/di.dart';
import 'package:xpay_payment_sdk/src/shared/business_logger/xp_business_logger.dart';

import '../../../../helpers/recording_authorize_repository.dart';

final _repository = RecordingAuthorizeRepository();

PaymentOrderEntity _order({
  DateTime? serviceDate,
  String currency = 'VND',
  String externalRef = 'ACME_1234',
  int amount = 100000,
}) => PaymentOrderEntity(
  productType: CreatePaymentProductType.taxiTrip,
  serviceDate: serviceDate,
  currency: currency,
  externalRef: externalRef,
  amount: amount,
);

PaymentAuthorizeRequestModel _manualPanRequest({String? serviceDate}) => PaymentAuthorizeRequestModel(
  cardToken: '4111111111111111',
  entryMode: PaymentEntryMode.manualPan.toRemote(),
  amount: '1000',
  currency: 'VND',
  externalRef: 'ACME_1234',
  serviceDate: serviceDate,
);

Future<XPayPaymentState> _settle(XPayPaymentBloc bloc, XPayPaymentEvent event) async {
  final settled = bloc.stream.firstWhere(
    (state) =>
        state is XPayPaymentAuthorizeDoneState || state is XPayPaymentAuthorizeErrorState || state is XPayPaymentAuthorizeConflictState || state is XPayPaymentInvalidQrState,
  );
  bloc.add(event);
  return settled;
}

Future<void> _authorizeOnce(PaymentOrderEntity order, XPayPaymentEvent event) async {
  final bloc = XPayPaymentBloc(order: order);
  await _settle(bloc, event);
  await bloc.close();
}

void main() {
  setUpAll(() {
    getIt.registerSingleton<PaymentAuthorizeRepository>(_repository);
    getIt.registerSingleton(PaymentAuthorizeIdempotencyTracker());
    getIt.registerSingleton(PaymentHostCancellation());
    getIt.registerSingleton(const XPBusinessLogger(null));
  });

  setUpAll(() => initializeDateFormatting());

  tearDownAll(() => getIt.reset());

  setUp(() {
    _repository.clear();
    getIt.get<PaymentAuthorizeIdempotencyTracker>().release();
  });

  group('order edits and the authorize idempotency key', () {
    test('the same order charged twice on the same card within one start reuses the key', () async {
      final bloc = XPayPaymentBloc(order: _order());
      await _settle(bloc, const XPayPanEnteredEvent('4111111111111111'));
      await _settle(bloc, const XPayPanEnteredEvent('4111111111111111'));
      await bloc.close();

      expect(_repository.idempotencyKeys, hasLength(2));
      expect(_repository.idempotencyKeys.first, _repository.idempotencyKeys.last, reason: 'nothing about the request changed, so the retry must deduplicate');
    });

    test('a retry through a new start with the same order and card reuses the key', () async {
      await _authorizeOnce(_order(), const XPayPanEnteredEvent('4111111111111111'));
      await _authorizeOnce(_order(), const XPayPanEnteredEvent('4111111111111111'));

      expect(_repository.idempotencyKeys.first, _repository.idempotencyKeys.last, reason: 'a host retrying after a timeout must not authorize the card twice');
    });

    test('changing the external reference, amount or currency starts a new key each time', () async {
      await _authorizeOnce(_order(), const XPayPanEnteredEvent('4111111111111111'));
      await _authorizeOnce(_order(externalRef: 'ACME_5678'), const XPayPanEnteredEvent('4111111111111111'));
      await _authorizeOnce(_order(amount: 120000), const XPayPanEnteredEvent('4111111111111111'));
      await _authorizeOnce(_order(currency: 'USD'), const XPayPanEnteredEvent('4111111111111111'));

      expect(_repository.idempotencyKeys.toSet(), hasLength(4));
    });

    test('a service date stamped later on the same day keeps the key', () async {
      await _authorizeOnce(_order(serviceDate: DateTime(2026, 9, 3, 8, 15)), const XPayPanEnteredEvent('4111111111111111'));
      await _authorizeOnce(_order(serviceDate: DateTime(2026, 9, 3, 23, 50)), const XPayPanEnteredEvent('4111111111111111'));

      expect(
        _repository.idempotencyKeys.first,
        _repository.idempotencyKeys.last,
        reason: 'service_date is sent as a calendar day, so the body is unchanged and the retry must deduplicate',
      );
    });

    test('a service date on another day starts a new key and sends the picked day', () async {
      await _authorizeOnce(_order(serviceDate: DateTime(2026, 9, 3, 23, 58)), const XPayPanEnteredEvent('4111111111111111'));
      await _authorizeOnce(_order(serviceDate: DateTime(2026, 9, 4, 0, 1)), const XPayPanEnteredEvent('4111111111111111'));

      expect(_repository.idempotencyKeys.first, isNot(_repository.idempotencyKeys.last), reason: 'service_date is part of the body, so a reused key would 409');
      expect(_repository.serviceDates.last, DateTime(2026, 9, 4, 0, 1));
      expect(DateTime(2026, 9, 3).toRemoteServiceDate(), '2026-09-03');
    });

    test('presenting a different card starts a new key', () async {
      await _authorizeOnce(_order(), const XPayPanEnteredEvent('4111111111111111'));
      await _authorizeOnce(_order(), const XPayPanEnteredEvent('5555555555554444'));

      expect(_repository.idempotencyKeys.first, isNot(_repository.idempotencyKeys.last));
    });
  });

  group('chip tap and the authorize idempotency key', () {
    test('a second tap of the same card starts a new key', () async {
      final bloc = XPayPaymentBloc(order: _order());
      await _settle(
        bloc,
        const XPayCardTappedEvent(
          chipTap: PaymentChipTapEntity(cryptogram: 'AAA', nonce: 'N1', counter: 1),
          cardToken: 'CTOK1',
        ),
      );
      await _settle(
        bloc,
        const XPayCardTappedEvent(
          chipTap: PaymentChipTapEntity(cryptogram: 'BBB', nonce: 'N2', counter: 2),
          cardToken: 'CTOK1',
        ),
      );
      await bloc.close();

      expect(_repository.idempotencyKeys.first, isNot(_repository.idempotencyKeys.last), reason: 'a new cryptogram is a new body, which a reused key would 409');
    });

    test('re-sending the very same tap evidence reuses the key', () async {
      final bloc = XPayPaymentBloc(order: _order());
      await _settle(
        bloc,
        const XPayCardTappedEvent(
          chipTap: PaymentChipTapEntity(cryptogram: 'AAA', nonce: 'N1', counter: 1),
          cardToken: 'CTOK1',
        ),
      );
      await _settle(
        bloc,
        const XPayCardTappedEvent(
          chipTap: PaymentChipTapEntity(cryptogram: 'AAA', nonce: 'N1', counter: 1),
          cardToken: 'CTOK1',
        ),
      );
      await bloc.close();

      expect(_repository.idempotencyKeys.first, _repository.idempotencyKeys.last, reason: 'an identical body is the transport-level retry the key exists for');
      expect(_repository.cardTokens, ['ctok1', 'ctok1']);
    });
  });

  group('a 409 from the gateway', () {
    test('releases the pinned key so the very next attempt carries a new one', () async {
      final bloc = XPayPaymentBloc(order: _order());
      _repository.nextFailure = const XPConflictException(errorCode: 'idempotency_key_reuse');
      await _settle(bloc, const XPayPanEnteredEvent('4111111111111111'));
      await _settle(bloc, const XPayPanEnteredEvent('4111111111111111'));
      await bloc.close();

      expect(_repository.idempotencyKeys.first, isNot(_repository.idempotencyKeys.last), reason: 'without releasing the key the retry would 409 again forever');
    });

    test('emits the conflict state rather than the generic error state', () async {
      final bloc = XPayPaymentBloc(order: _order());
      _repository.nextFailure = const XPConflictException(errorCode: 'idempotency_key_reuse');

      expect(await _settle(bloc, const XPayPanEnteredEvent('4111111111111111')), isA<XPayPaymentAuthorizeConflictState>());
      await bloc.close();
    });

    test('any other failure keeps the key pinned, so a plain retry still deduplicates', () async {
      _repository.nextFailure = const XPApiException(statusCode: 500);
      await _authorizeOnce(_order(), const XPayPanEnteredEvent('4111111111111111'));
      await _authorizeOnce(_order(), const XPayPanEnteredEvent('4111111111111111'));

      expect(_repository.idempotencyKeys.first, _repository.idempotencyKeys.last, reason: 'a 500 may have authorized, so the retry must stay deduplicable');
    });
  });

  test('every key sent is a UUID, which the endpoint declares as the header format', () async {
    await _authorizeOnce(_order(), const XPayPanEnteredEvent('4111111111111111'));

    expect(_repository.idempotencyKeys.single, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
  });

  test('the request body carries the service date as a calendar day and omits the key otherwise', () {
    expect(_manualPanRequest(serviceDate: '2026-09-03').toJson()['service_date'], '2026-09-03');
    expect(_manualPanRequest().toJson().containsKey('service_date'), isFalse);
  });
}

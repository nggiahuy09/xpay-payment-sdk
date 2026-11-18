import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/src/base/domain/domain.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/create_payment_product_type_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_authorize_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_decline_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_entry_mode_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_order_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/xpay_qr_prefix.dart';
import 'package:xpay_payment_sdk/src/core/domain/repositories/payment_authorize_repo.dart';
import 'package:xpay_payment_sdk/src/core/presentation/payment/blocs/xpay_payment_bloc.dart';
import 'package:xpay_payment_sdk/src/core/presentation/payment/helpers/payment_authorize_idempotency_tracker.dart';
import 'package:xpay_payment_sdk/src/di/di.dart';
import 'package:xpay_payment_sdk/src/shared/business_logger/xp_business_logger.dart';

import '../../../../helpers/recording_authorize_repository.dart';

final _repository = RecordingAuthorizeRepository();

const _order = PaymentOrderEntity(productType: CreatePaymentProductType.taxiTrip, currency: 'VND', externalRef: 'ACME_1234', amount: 100000);

Future<XPayPaymentState> _settle(XPayPaymentBloc bloc, XPayPaymentEvent event) async {
  final settled = bloc.stream.firstWhere(
    (state) =>
        state is XPayPaymentAuthorizeDoneState || state is XPayPaymentAuthorizeErrorState || state is XPayPaymentAuthorizeConflictState || state is XPayPaymentInvalidQrState,
  );
  bloc.add(event);
  return settled;
}

void main() {
  setUpAll(() {
    getIt.registerSingleton<PaymentAuthorizeRepository>(_repository);
    getIt.registerSingleton(PaymentAuthorizeIdempotencyTracker());
    getIt.registerSingleton(const XPBusinessLogger(null));
  });

  tearDownAll(() => getIt.reset());

  setUp(() {
    _repository.clear();
    getIt.get<PaymentAuthorizeIdempotencyTracker>().release();
  });

  group('QR scans', () {
    test('an XPCARD code authorizes as a card QR with auto capture, sending only the token', () async {
      final bloc = XPayPaymentBloc(order: _order);
      final state = await _settle(bloc, const XPayQrScannedEvent(prefix: XpayQrPrefix.xpCard, rawValue: 'XPCARD:ptok_123'));
      await bloc.close();

      expect(state, isA<XPayPaymentAuthorizeDoneState>().having((s) => s.entryMode, 'entryMode', PaymentEntryMode.cardQr));
      expect(_repository.cardTokens.single, 'ptok_123');
      expect(_repository.autoCaptures.single, isTrue);
    });

    test('an XTOK code authorizes as a token without auto capture', () async {
      final bloc = XPayPaymentBloc(order: _order);
      await _settle(bloc, const XPayQrScannedEvent(prefix: XpayQrPrefix.xTok, rawValue: 'XTOK:tok_456'));
      await bloc.close();

      expect(_repository.entryModes.single, PaymentEntryMode.token);
      expect(_repository.cardTokens.single, 'tok_456');
      expect(_repository.autoCaptures.single, isFalse);
    });

    test('an unknown prefix reports an invalid QR and authorizes nothing, so the scanner can stay open', () async {
      final bloc = XPayPaymentBloc(order: _order);
      final state = await _settle(bloc, const XPayQrScannedEvent(prefix: XpayQrPrefix.xpCard, rawValue: 'SOMETHING:abc'));
      await bloc.close();

      expect(state, isA<XPayPaymentInvalidQrState>());
      expect(_repository.idempotencyKeys, isEmpty);
    });

    test('a code of the other kind than the method picked reports an invalid QR and authorizes nothing', () async {
      final bloc = XPayPaymentBloc(order: _order);
      final state = await _settle(bloc, const XPayQrScannedEvent(prefix: XpayQrPrefix.xpCard, rawValue: 'XTOK:tok_456'));
      await bloc.close();

      expect(state, isA<XPayPaymentInvalidQrState>());
      expect(_repository.idempotencyKeys, isEmpty);
    });
  });

  group('linked card', () {
    test('charging the linked card authorizes as a ride card with auto capture, sending the ride order as the card token', () async {
      final bloc = XPayPaymentBloc(order: _order);
      final state = await _settle(bloc, const XPayRideCardChargedEvent('order-1'));
      await bloc.close();

      expect(state, isA<XPayPaymentAuthorizeDoneState>().having((s) => s.entryMode, 'entryMode', PaymentEntryMode.rideCard));
      expect(_repository.entryModes.single, PaymentEntryMode.rideCard);
      expect(_repository.cardTokens.single, 'order-1');
      expect(_repository.autoCaptures.single, isTrue);
    });
  });

  group('authorize outcomes', () {
    test('an approval, a capture, a decline and a pending verification all settle as done, carrying the entry mode', () async {
      final outcomes = [
        const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.approved, authId: 'auth-1'),
        const PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.captured, authId: 'auth-2', captureId: 'cap-2'),
        PaymentAuthorizeEntity(status: PaymentAuthorizeStatus.declined, declineReason: PaymentDeclineEntity.fromRemote('insufficient_funds')),
        const PaymentAuthorizeEntity(
          status: PaymentAuthorizeStatus.pendingVerification,
          authId: 'auth-3',
          verification: PaymentAuthorizeVerificationEntity(method: PaymentAuthorizeVerificationMethod.smsOtp),
        ),
      ];

      for (final authorize in outcomes) {
        _repository.nextAuthorize = authorize;
        final bloc = XPayPaymentBloc(order: _order);
        final state = await _settle(bloc, const XPayPanEnteredEvent('4111111111111111'));
        await bloc.close();

        expect(state, isA<XPayPaymentAuthorizeDoneState>().having((s) => s.authorize, 'authorize', authorize).having((s) => s.entryMode, 'entryMode', PaymentEntryMode.manualPan));
      }
    });

    test('a request failure surfaces its code and copy without the exception itself', () async {
      _repository.nextFailure = const XPApiException(errorCode: 'internal_error', statusCode: 500);
      final bloc = XPayPaymentBloc(order: _order);
      final state = await _settle(bloc, const XPayPanEnteredEvent('4111111111111111'));
      await bloc.close();

      expect(state, isA<XPayPaymentAuthorizeErrorState>().having((s) => s.errorCode, 'errorCode', 'internal_error'));
    });

    test('a network failure keeps the copy the exception carries', () async {
      _repository.nextFailure = const XPNetworkException.noConnection();
      final bloc = XPayPaymentBloc(order: _order);
      final state = await _settle(bloc, const XPayPanEnteredEvent('4111111111111111'));
      await bloc.close();

      expect(state, isA<XPayPaymentAuthorizeErrorState>().having((s) => s.displayMessage, 'displayMessage', const XPNetworkException.noConnection().displayMessage));
    });
  });

  test('a capture arriving while an authorization is in flight is dropped', () async {
    final gate = Completer<void>();
    _repository.gate = gate;
    final bloc = XPayPaymentBloc(order: _order);
    final settled = bloc.stream.firstWhere((state) => state is XPayPaymentAuthorizeDoneState);
    bloc.add(const XPayPanEnteredEvent('4111111111111111'));
    await bloc.stream.firstWhere((state) => state is XPayPaymentAuthorizingState);
    bloc.add(const XPayPanEnteredEvent('5555555555554444'));
    await Future<void>.delayed(Duration.zero);
    gate.complete();
    await settled;
    await bloc.close();

    expect(_repository.cardTokens, ['4111111111111111']);
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/src/api/mappers/xpay_payment_request_mapper.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/create_payment_product_type_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_entry_mode_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_request_reject_reason_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_ride_card_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_session_entity.dart';
import 'package:xpay_payment_sdk/xpay_payment_sdk.dart';

const _sessionResponse = '''
{
  "session_token": "rps_Zk3q9V1xN0bQe7mY2tHcR8uLwP4sJ6aD5fGiK1oT0vE",
  "expires_at": "2026-11-17T08:45:00.000Z",
  "order_id": "3f6c1b2a-8d4e-4f71-9a0b-5c2e7d9f1a34",
  "external_ref": "XP-1048",
  "amount": "138000.00",
  "entry_modes": ["ride_card", "card_qr", "manual_pan", "chip_tap", "token"],
  "ride_card": { "card_last4": "4821", "card_name": "Thẻ công tác UTS" },
  "estimate": "135000.00",
  "payment_template": {
    "amount": "138000.00",
    "currency": "VND",
    "external_ref": "XP-1048",
    "product_type": "taxi_trip",
    "enhanced_data": {
      "type": "taxi_trip",
      "pickup_location": "Sân bay Tân Sơn Nhất, Ga quốc nội",
      "destination": "Bitexco Financial Tower, 2 Hải Triều, Q.1",
      "plate_number": "51K-123.45",
      "fare": 128000,
      "sub_fee": 10000,
      "distance_km": 9.4
    }
  }
}
''';

String _sessionWith(Map<String, dynamic> overrides) => jsonEncode({...jsonDecode(_sessionResponse) as Map<String, dynamic>, ...overrides});

XPayPaymentRequest _request(String sessionJson) => XPayPaymentRequest.fromSession(sessionJson);

PaymentSessionEntity? _sessionOf(XPayPaymentRequest request) => request.toSession().toNullable();

PaymentRequestRejectReason? _rejectionOf(XPayPaymentRequest request) => request.toSession().getLeft().toNullable();

void main() {
  group('XPayPaymentRequest.toSession', () {
    test('the payment-session response maps to the token and the locked order', () {
      final session = _sessionOf(_request(_sessionResponse));

      expect(session?.sessionToken, 'rps_Zk3q9V1xN0bQe7mY2tHcR8uLwP4sJ6aD5fGiK1oT0vE');
      expect(session?.order.amount, 138000);
      expect(session?.order.externalRef, 'XP-1048');
      expect(session?.order.currency, 'VND');
      expect(session?.order.productType, CreatePaymentProductType.taxiTrip);
    });

    test('the entry modes, the linked card and the trip summary are read for the entry view', () {
      final session = _sessionOf(_request(_sessionResponse));

      expect(session?.entryModes, [
        PaymentEntryMode.rideCard,
        PaymentEntryMode.cardQr,
        PaymentEntryMode.manualPan,
        PaymentEntryMode.chipTap,
        PaymentEntryMode.token,
      ]);
      expect(session?.rideCard, const PaymentRideCardEntity(last4: '4821', name: 'Thẻ công tác UTS', token: '3f6c1b2a-8d4e-4f71-9a0b-5c2e7d9f1a34'));
      expect(session?.trip.pickupLocation, 'Sân bay Tân Sơn Nhất, Ga quốc nội');
      expect(session?.trip.destination, 'Bitexco Financial Tower, 2 Hải Triều, Q.1');
      expect(session?.trip.plateNumber, '51K-123.45');
    });

    test('unknown and repeated entry modes are dropped, keeping the order the server sent', () {
      final session = _sessionOf(
        _request(
          _sessionWith({
            'entry_modes': ['token', 'wallet', 'manual_pan', 'token'],
          }),
        ),
      );

      expect(session?.entryModes, [PaymentEntryMode.token, PaymentEntryMode.manualPan]);
    });

    test('the linked card is not offered without its last four digits or the ride order', () {
      final withoutCard = _sessionOf(_request(_sessionWith({'ride_card': null})));
      final withoutOrder = _sessionOf(_request(_sessionWith({'order_id': ' '})));

      expect(withoutCard?.rideCard, isNull);
      expect(withoutCard?.entryModes, isNot(contains(PaymentEntryMode.rideCard)));
      expect(withoutOrder?.rideCard, isNull);
      expect(withoutOrder?.entryModes, isNot(contains(PaymentEntryMode.rideCard)));
    });

    test('blank trip details are left out of the summary', () {
      final session = _sessionOf(
        _request(
          _sessionWith({
            'payment_template': {
              'currency': 'VND',
              'product_type': 'taxi_trip',
              'enhanced_data': {'pickup_location': ' ', 'destination': null},
            },
          }),
        ),
      );

      expect(session?.trip.pickupLocation, isNull);
      expect(session?.trip.destination, isNull);
      expect(session?.trip.plateNumber, isNull);
    });

    test('the service date is stamped when the session is read', () {
      final readAt = DateTime.now();
      final session = _sessionOf(const XPayPaymentRequest.fromSession(_sessionResponse));

      expect(session?.order.serviceDate?.isBefore(readAt), isFalse);
    });

    test('the template reference and currency are used when the top level has none', () {
      final session = _sessionOf(
        _request(
          jsonEncode({
            'session_token': 'token',
            'amount': '138000',
            'entry_modes': ['card_qr'],
            'payment_template': {'currency': 'vnd', 'external_ref': 'XP-2000', 'product_type': 'taxi_trip'},
          }),
        ),
      );

      expect(session?.order.externalRef, 'XP-2000');
      expect(session?.order.currency, 'VND');
    });

    test('a session without a template defaults to VND and leaves the product type to the gateway', () {
      final session = _sessionOf(
        _request(
          jsonEncode({
            'session_token': 'token',
            'amount': '138000',
            'external_ref': 'XP-1048',
            'entry_modes': ['card_qr'],
          }),
        ),
      );

      expect(session?.order.currency, 'VND');
      expect(session?.order.productType, CreatePaymentProductType.unknown);
      expect(session?.order.productType.toRemote(), isNull);
    });

    test('each rejected session reports why it was rejected', () {
      final rejections = {
        '': PaymentRequestRejectReason.invalidSessionJson,
        'not json': PaymentRequestRejectReason.invalidSessionJson,
        '{"session_token": "token", "amount": "138000"': PaymentRequestRejectReason.invalidSessionJson,
        '[]': PaymentRequestRejectReason.invalidSessionJson,
        _sessionWith({'amount': 138000}): PaymentRequestRejectReason.malformedSession,
        _sessionWith({'session_token': 42}): PaymentRequestRejectReason.malformedSession,
        _sessionWith({'payment_template': []}): PaymentRequestRejectReason.malformedSession,
        _sessionWith({'session_token': null}): PaymentRequestRejectReason.missingSessionToken,
        _sessionWith({'session_token': '   '}): PaymentRequestRejectReason.missingSessionToken,
        _sessionWith({'amount': null}): PaymentRequestRejectReason.invalidAmount,
        _sessionWith({'amount': '138000.50'}): PaymentRequestRejectReason.invalidAmount,
        _sessionWith({'amount': '-138000'}): PaymentRequestRejectReason.invalidAmount,
        _sessionWith({'amount': '1.2e5'}): PaymentRequestRejectReason.invalidAmount,
        _sessionWith({'amount': '999'}): PaymentRequestRejectReason.amountBelowMinimum,
        _sessionWith({
          'payment_template': {'currency': ' '},
        }): PaymentRequestRejectReason.missingCurrency,
        _sessionWith({'external_ref': null, 'payment_template': null}): PaymentRequestRejectReason.invalidExternalRef,
        _sessionWith({'external_ref': 'A' * 65}): PaymentRequestRejectReason.invalidExternalRef,
        _sessionWith({'entry_modes': null}): PaymentRequestRejectReason.missingEntryModes,
        _sessionWith({'entry_modes': []}): PaymentRequestRejectReason.missingEntryModes,
        _sessionWith({
          'entry_modes': ['wallet'],
        }): PaymentRequestRejectReason.missingEntryModes,
        _sessionWith({
          'entry_modes': ['ride_card'],
          'ride_card': null,
        }): PaymentRequestRejectReason.missingEntryModes,
        _sessionWith({
          'entry_modes': [42],
        }): PaymentRequestRejectReason.malformedSession,
      };

      for (final MapEntry(key: sessionJson, value: reason) in rejections.entries) {
        expect(_rejectionOf(_request(sessionJson)), reason, reason: sessionJson);
      }
    });

    test('an amount of exactly the minimum and an external reference of exactly 64 characters are accepted', () {
      expect(_sessionOf(_request(_sessionWith({'amount': '1000.00', 'external_ref': 'A' * 64}))), isNotNull);
    });
  });
}

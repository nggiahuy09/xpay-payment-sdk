import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/xpay_qr_prefix.dart';

void main() {
  group('XpayQrPrefix.resolve', () {
    test('recognizes a card QR and a token QR', () {
      expect(XpayQrPrefix.resolve('XPCARD:ptok_123'), XpayQrPrefix.xpCard);
      expect(XpayQrPrefix.resolve('XTOK:tok_456'), XpayQrPrefix.xTok);
    });

    test('rejects anything without a known prefix before the separator', () {
      for (final rawValue in ['', 'XPCARD', ':ptok_123', 'xpcard:ptok_123', 'OTHER:abc', 'https://example.com']) {
        expect(XpayQrPrefix.resolve(rawValue), isNull, reason: rawValue);
      }
    });
  });

  group('XpayQrPrefix.extractToken', () {
    test('strips only its own prefix', () {
      expect(XpayQrPrefix.xpCard.extractToken('XPCARD:ptok_123'), 'ptok_123');
      expect(XpayQrPrefix.xTok.extractToken('XTOK:tok:with:colons'), 'tok:with:colons');
      expect(XpayQrPrefix.xTok.extractToken('XPCARD:ptok_123'), 'XPCARD:ptok_123');
    });
  });
}

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/src/shared/helpers/helper_nfc.dart';

void main() {
  group('value blocks', () {
    test('a built block parses back to the same counter, including the unsigned upper range', () {
      for (final value in [0, 1, 41, 0x7fffffff, 0xfffffffe]) {
        expect(XPHelperNfc.parseValueBlock(XPHelperNfc.buildValueBlock(value, 9)), value, reason: '$value');
      }
    });

    test('the address bytes alternate with their complement', () {
      final block = XPHelperNfc.buildValueBlock(5, 9);

      expect(block.sublist(12), [9, 0xf6, 9, 0xf6]);
    });

    test('a block whose copies disagree is not a counter', () {
      final block = XPHelperNfc.buildValueBlock(5, 9)..[8] = 6;

      expect(XPHelperNfc.parseValueBlock(block), isNull);
      expect(XPHelperNfc.parseValueBlock(Uint8List(4)), isNull);
    });
  });

  group('hex', () {
    test('parses even-length hex and formats it back in lowercase', () {
      final bytes = XPHelperNfc.hexToBytes('A0B1C2D3E4F5');

      expect(bytes, [0xa0, 0xb1, 0xc2, 0xd3, 0xe4, 0xf5]);
      expect(XPHelperNfc.bytesToHex(bytes!), 'a0b1c2d3e4f5');
    });

    test('rejects odd-length, empty or non-hex input', () {
      for (final value in [null, '', 'ABC', 'ZZ']) {
        expect(XPHelperNfc.hexToBytes(value), isNull, reason: value);
      }
    });
  });
}

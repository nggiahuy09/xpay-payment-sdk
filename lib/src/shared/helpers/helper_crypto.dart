import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

final class XPHelperCryptography {
  const XPHelperCryptography._();

  static String generateRandomString({int minLength = 8, int maxLength = 16}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    final length = minLength + rand.nextInt(maxLength - minLength + 1);

    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  static String generateUuidV4() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (index) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  static String sha256Base64(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);

    return base64Encode(digest.bytes);
  }
}

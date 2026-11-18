import '../../../../shared/helpers/helpers.dart';

final class PaymentAuthorizeIdempotencyTracker {
  String _key = '';
  String? _operation;

  String start(String requestSignature) {
    final operation = XPHelperCryptography.sha256Base64(requestSignature);
    if (_operation != operation) {
      _operation = operation;
      _key = XPHelperCryptography.generateUuidV4();
    }

    return _key;
  }

  void release() {
    _operation = null;
    _key = '';
  }
}

/// Request body model for `POST /merchant/payments/authorize` (MerchantAuthorizeDto).
final class PaymentAuthorizeRequestModel {
  const PaymentAuthorizeRequestModel({
    required this.cardToken,
    required this.entryMode,
    required this.amount,
    required this.currency,
    required this.externalRef,
    this.chipTap,
    this.verificationCode,
    this.merchantId,
    this.mcc,
    this.otpRecipientId,
    this.productType,
    this.serviceDate,
    this.autoCapture = false,
  });

  final PaymentAuthorizeChipTapModel? chipTap;
  final String cardToken;
  final String entryMode;
  final String amount;
  final String currency;
  final String externalRef;
  final String? verificationCode;
  final String? merchantId;
  final String? mcc;
  final String? otpRecipientId;
  final String? productType;
  final String? serviceDate;
  final bool autoCapture;

  Map<String, dynamic> toJson() => {
    'card_token': cardToken,
    'entry_mode': entryMode,
    if (verificationCode != null) 'verification_code': verificationCode,
    'amount': amount,
    'auto_capture': autoCapture,
    'currency': currency,
    'external_ref': externalRef,
    if (merchantId != null) 'merchant_id': merchantId,
    if (mcc != null) 'mcc': mcc,
    if (otpRecipientId != null) 'otp_recipient_id': otpRecipientId,
    if (productType != null) 'product_type': productType,
    if (serviceDate != null) 'service_date': serviceDate,
    ...?chipTap?.toJson(),
  };
}

/// The chip-tap fields, flattened into the authorize body rather than nested — the endpoint expects them at the top level.
final class PaymentAuthorizeChipTapModel {
  const PaymentAuthorizeChipTapModel({required this.cryptogram, required this.nonce, required this.counter, this.keyVersion});

  final String cryptogram;
  final String nonce;
  final int counter;
  final int? keyVersion;

  Map<String, dynamic> toJson() => {
    'cryptogram': cryptogram,
    'nonce': nonce,
    'counter': counter,
    if (keyVersion != null) 'key_version': keyVersion,
  };
}

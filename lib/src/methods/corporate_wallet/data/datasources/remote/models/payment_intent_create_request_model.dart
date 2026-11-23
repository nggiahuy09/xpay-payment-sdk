final class PaymentIntentCreateRequestModel {
  const PaymentIntentCreateRequestModel({required this.amount, required this.currency, required this.externalRef, required this.productType});

  final String amount;
  final String currency;
  final String externalRef;
  final String productType;

  Map<String, dynamic> toJson() => {'amount': amount, 'currency': currency, 'external_ref': externalRef, 'product_type': productType};
}

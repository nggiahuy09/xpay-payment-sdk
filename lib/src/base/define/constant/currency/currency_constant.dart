final class XPCurrencyConstant {
  const XPCurrencyConstant._();

  /// ISO 4217 code the merchant transacts in: sent when authorizing a payment, and assumed for display when an amount arrives without a currency.
  static const String kDefaultCurrency = 'VND';
}

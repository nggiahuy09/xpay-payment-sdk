enum PaymentMethod {
  card,
  corporateWallet,
  unknown;

  static PaymentMethod fromRemote(String? value) => switch (value) {
    'card' => PaymentMethod.card,
    'corporate_wallet' => PaymentMethod.corporateWallet,
    _ => PaymentMethod.unknown,
  };

  bool get isCorporateWallet => this == PaymentMethod.corporateWallet;
}

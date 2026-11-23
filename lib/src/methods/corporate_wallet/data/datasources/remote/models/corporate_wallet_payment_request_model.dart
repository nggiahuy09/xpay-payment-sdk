final class CorporateWalletPaymentRequestModel {
  const CorporateWalletPaymentRequestModel(this.method, this.recipientId);

  final String method;
  final String recipientId;

  Map<String, dynamic> toJson() => {'method': method, 'recipient_id': recipientId};
}

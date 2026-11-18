final class PaymentResendVerificationRequestModel {
  const PaymentResendVerificationRequestModel(this.recipientId);

  final String? recipientId;

  Map<String, dynamic> toJson() => {if (recipientId != null) 'recipient_id': recipientId};
}

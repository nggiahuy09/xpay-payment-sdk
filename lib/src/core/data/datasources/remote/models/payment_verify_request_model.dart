/// Request body model for `POST /merchant/payments/{auth_id}/verify`.
final class PaymentVerifyRequestModel {
  const PaymentVerifyRequestModel({required this.code});

  final String code;

  Map<String, dynamic> toJson() => {'code': code};
}

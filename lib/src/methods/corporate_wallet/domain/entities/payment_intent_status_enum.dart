enum PaymentIntentStatus {
  requiresConfirmation,
  captured,
  declined,
  canceled,
  expired,
  unknown;

  static PaymentIntentStatus fromRemote(String? value) => switch (value) {
    'requires_confirmation' => PaymentIntentStatus.requiresConfirmation,
    'captured' => PaymentIntentStatus.captured,
    'declined' => PaymentIntentStatus.declined,
    'canceled' => PaymentIntentStatus.canceled,
    'expired' => PaymentIntentStatus.expired,
    _ => PaymentIntentStatus.unknown,
  };

  bool get isPending => this == PaymentIntentStatus.requiresConfirmation || this == PaymentIntentStatus.unknown;
}

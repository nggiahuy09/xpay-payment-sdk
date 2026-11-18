enum CreatePaymentProductType {
  taxiTrip,
  unknown;

  static CreatePaymentProductType fromRemote(String? value) => switch (value) {
    'taxi_trip' => CreatePaymentProductType.taxiTrip,
    _ => CreatePaymentProductType.unknown,
  };

  String? toRemote() => switch (this) {
    CreatePaymentProductType.taxiTrip => 'taxi_trip',
    CreatePaymentProductType.unknown => null,
  };
}

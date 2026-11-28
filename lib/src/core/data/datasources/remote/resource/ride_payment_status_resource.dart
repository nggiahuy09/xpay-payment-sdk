import '../../../../../base/gateway/api/api.dart';
import '../models/ride_payment_status_response_model.dart';

final class RidePaymentStatusResource extends XPResource<RidePaymentStatusResponseModel> {
  RidePaymentStatusResource() : super(description: 'Get ride payment status of the open session');

  @override
  XPHttpMethod get method => XPHttpMethod.get;

  @override
  Duration? get timeout => const Duration(seconds: 15);

  @override
  bool get retriesTransientFailures => false;

  @override
  String get path => '/merchant/ride-payment';

  @override
  RidePaymentStatusResponseModel parse(Object? data) => RidePaymentStatusResponseModel.fromJson(data as Map<String, dynamic>);
}

import '../../../../base/gateway/api/api_type.dart';
import '../../../../base/gateway/api/xp_rest_client.dart';
import '../../../../di/di.dart';
import 'models/ride_payment_status_response_model.dart';
import 'resource/ride_payment_status_resource.dart';

final class RidePaymentRemoteDatasource {
  final _client = getIt.get<XPRestClient>();

  Future<RidePaymentStatusResponseModel> getStatus() => _client.request(RidePaymentStatusResource(), type: APIType.user);
}

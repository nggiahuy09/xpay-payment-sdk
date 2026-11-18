import '../../../../../base/gateway/api/api_type.dart';
import '../../../../../base/gateway/api/xp_rest_client.dart';
import '../../../../../di/di.dart';
import 'models/chip_tap_cryptogram_request_model.dart';
import 'models/chip_tap_cryptogram_response_model.dart';
import 'models/chip_tap_prepare_request_model.dart';
import 'models/chip_tap_prepare_response_model.dart';
import 'resource/chip_tap_cryptogram_resource.dart';
import 'resource/chip_tap_prepare_resource.dart';

final class ChipTapRemoteDatasource {
  final _client = getIt.get<XPRestClient>();

  /// Deliberately uncached: the broker hands out live Crypto1 key material per tap, and a card re-personalized mid-session would otherwise keep serving stale
  /// keys and layout for the rest of the session.
  Future<ChipTapPrepareResponseModel> prepare({required ChipTapPrepareRequestModel request}) {
    return _client.request(ChipTapPrepareResource(request: request), type: APIType.user);
  }

  /// Never cached, and never retried with a stale counter: each call signs one specific counter value with a single-use nonce.
  Future<ChipTapCryptogramResponseModel> sign({required ChipTapCryptogramRequestModel request}) {
    return _client.request(ChipTapCryptogramResource(request: request), type: APIType.user);
  }
}

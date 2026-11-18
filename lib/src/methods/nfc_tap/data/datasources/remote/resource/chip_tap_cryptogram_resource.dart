import '../../../../../../base/gateway/api/api.dart';
import '../models/chip_tap_cryptogram_request_model.dart';
import '../models/chip_tap_cryptogram_response_model.dart';

final class ChipTapCryptogramResource extends XPResource<ChipTapCryptogramResponseModel> {
  // The chip UID is deliberately left out of the description: it is the card's persistent identifier and this description is logged on every call, which would
  // make taps correlatable per physical card. The counter carries the diagnostic value without identifying the card.
  ChipTapCryptogramResource({required ChipTapCryptogramRequestModel request}) : _request = request, super(description: 'Sign chip tap, counter=${request.counter}');

  final ChipTapCryptogramRequestModel _request;

  @override
  Object? get body => _request.toJson();

  @override
  XPHttpMethod get method => XPHttpMethod.post;

  @override
  String get path => '/merchant/chip/tap/cryptogram';

  @override
  ChipTapCryptogramResponseModel parse(Object? data) => ChipTapCryptogramResponseModel.fromJson(data as Map<String, dynamic>);
}

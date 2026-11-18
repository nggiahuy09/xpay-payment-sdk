import '../../../../../../base/gateway/api/api.dart';
import '../models/chip_tap_prepare_request_model.dart';
import '../models/chip_tap_prepare_response_model.dart';

final class ChipTapPrepareResource extends XPResource<ChipTapPrepareResponseModel> {
  // The chip UID is deliberately left out of the description: it is the card's persistent identifier and this description is logged on every call, which would
  // make taps correlatable per physical card.
  ChipTapPrepareResource({required ChipTapPrepareRequestModel request}) : _request = request, super(description: 'Prepare chip tap');

  final ChipTapPrepareRequestModel _request;

  @override
  Object? get body => _request.toJson();

  @override
  XPHttpMethod get method => XPHttpMethod.post;

  @override
  String get path => '/merchant/chip/tap/prepare';

  @override
  ChipTapPrepareResponseModel parse(Object? data) => ChipTapPrepareResponseModel.fromJson(data as Map<String, dynamic>);
}

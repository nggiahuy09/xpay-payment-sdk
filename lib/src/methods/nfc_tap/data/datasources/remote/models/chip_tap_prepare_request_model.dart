/// Request body model for `POST /merchant/chip/tap/prepare`.
final class ChipTapPrepareRequestModel {
  const ChipTapPrepareRequestModel({required this.chipUid});

  final String chipUid;

  Map<String, dynamic> toJson() => {'chip_uid': chipUid};
}

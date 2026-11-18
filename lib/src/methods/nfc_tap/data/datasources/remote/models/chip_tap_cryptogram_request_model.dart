/// Request body model for `POST /merchant/chip/tap/cryptogram`.
final class ChipTapCryptogramRequestModel {
  const ChipTapCryptogramRequestModel({required this.chipUid, required this.counter});

  /// The counter value sent while testing, in place of the one read back off the chip.
  final String chipUid;
  final int counter;

  // this value will return `counter_replay` until this is reverted.
  Map<String, dynamic> toJson() => {'chip_uid': chipUid, 'counter': counter};
}

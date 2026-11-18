import '../../../../base/localization/localization.dart';

/// The `/merchant/chip/tap/cryptogram` failures the broker names explicitly, resolved from `XPException.errorCode`.
///
/// Reaching any of these means the counter has already been advanced on the card, so the card is normally one ahead of the server — a harmless direction, since
/// the next tap reads the higher value and still exceeds the server's high-water mark.
///
/// [counterReplay] is the exception: it says the value presented did *not* exceed the last verified tap. The recovery is the same either way — read the counter
/// off the card again — but the copy differs, because nothing about the operator's tap was at fault.
enum ChipTapCryptogramFailureReason {
  counterReplay,
  unknown;

  static ChipTapCryptogramFailureReason fromErrorCode(String? value) => switch (value) {
    'counter_replay' => ChipTapCryptogramFailureReason.counterReplay,
    _ => ChipTapCryptogramFailureReason.unknown,
  };

  /// Both cases are retryable, but only by re-reading the counter off the chip.
  ///
  /// A `counter_replay` here means the value presented did not exceed the last verified tap. The counter must be read from the card again — never re-sent, and
  /// never forwarded to `authorize`, where the same value becomes `chip_counter_replay` and revokes the credential.
  bool get requiresRetap => true;

  String getTitle(XPLocaleBase locale, String fallback) {
    final viewLocale = locale.payment.xpay;
    return switch (this) {
      ChipTapCryptogramFailureReason.counterReplay => viewLocale.nfcVerifyFailedTitle,
      ChipTapCryptogramFailureReason.unknown => fallback,
    };
  }

  /// `counter_replay` gets its own copy rather than sharing the moved-card wording: the counter presented did not exceed the last verified tap, which is a
  /// synchronization problem between card and server, not something the operator did wrong. Telling them the card moved would send them chasing a tap technique
  /// that was never the issue. The recovery is still another tap, so the copy asks for one without assigning blame.
  String getBody(XPLocaleBase locale, String Function() onFallback) {
    final viewLocale = locale.payment.xpay;
    return switch (this) {
      ChipTapCryptogramFailureReason.counterReplay => viewLocale.nfcCounterOutOfSyncBody,
      ChipTapCryptogramFailureReason.unknown => onFallback.call(),
    };
  }
}

import '../../../../base/localization/localization.dart';

/// The outcome of comparing what was read off the chip against the issuer's record from `/merchant/chip/tap/prepare`.
///
/// Every non-[matched] value aborts the tap before anything is written, so the card is left untouched in all of them.
enum ChipTapVerification {
  matched,
  macMismatch,
  cardTokenMismatch,
  readFailed,
  incompleteLayout;

  /// Compares the chip's blocks against the issuer's record, case-insensitively.
  ///
  /// The broker returns Crypto1 key material uppercase while `card_token` is lowercase, and a block read off the chip is formatted independently of both — so
  /// casing carries no meaning here and comparing it would reject valid cards.
  ///
  /// The MAC is checked first because it is the integrity signal: the chip UID is inside the MAC message, so a payload copied from another card fails here even
  /// though its own token would look internally consistent.
  static ChipTapVerification resolve({String? expectedMac, String? actualMac, String? expectedCardToken, String? actualCardToken}) {
    if (expectedMac == null || actualMac == null || expectedCardToken == null || actualCardToken == null) return ChipTapVerification.readFailed;

    if (expectedMac.toLowerCase() != actualMac.toLowerCase()) return ChipTapVerification.macMismatch;

    if (expectedCardToken.toLowerCase() != actualCardToken.toLowerCase()) return ChipTapVerification.cardTokenMismatch;

    return ChipTapVerification.matched;
  }

  bool get isMatched => this == ChipTapVerification.matched;

  /// Whether re-tapping could plausibly succeed.
  ///
  /// A mismatch is a property of the card itself — not this card, or a tampered one — so retrying the same card is pointless. A failed read is different: the
  /// tag may simply have been moved away mid-sequence, which the operator can correct.
  bool get isRetryable => this == ChipTapVerification.readFailed;

  String getTitle(XPLocaleBase locale) {
    final viewLocale = locale.payment.xpay;
    return switch (this) {
      ChipTapVerification.matched => viewLocale.nfcTitle,
      ChipTapVerification.macMismatch => viewLocale.nfcNotSupportedCardTitle,
      ChipTapVerification.cardTokenMismatch => viewLocale.nfcNotSupportedCardTitle,
      ChipTapVerification.readFailed => viewLocale.nfcReadFailedTitle,
      ChipTapVerification.incompleteLayout => viewLocale.nfcReadFailedTitle,
    };
  }

  /// The mismatch cases deliberately share the invalid-card copy: to the operator both mean the same thing, and naming the cryptographic detail would only tell
  /// someone probing the terminal which check they tripped.
  String getBody(XPLocaleBase locale) {
    final viewLocale = locale.payment.xpay;
    return switch (this) {
      ChipTapVerification.matched => viewLocale.nfcHintBody,
      ChipTapVerification.macMismatch => viewLocale.nfcNotSupportedCardBody,
      ChipTapVerification.cardTokenMismatch => viewLocale.nfcNotSupportedCardBody,
      ChipTapVerification.readFailed => viewLocale.nfcReadRetryBody,
      ChipTapVerification.incompleteLayout => viewLocale.nfcReadFailedBody(null),
    };
  }
}

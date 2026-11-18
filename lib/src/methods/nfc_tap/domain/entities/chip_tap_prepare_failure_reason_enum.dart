import '../../../../base/localization/localization.dart';

/// The `/merchant/chip/tap/prepare` failures the broker names explicitly, resolved from `XPException.errorCode`.
///
/// Every one of these aborts the tap before anything has touched the chip, so none of them leaves the card in a partial state — the operator can simply be told
/// why and offered another card.
///
/// Only the codes the endpoint documents get their own value; everything else — including the network and session failures, which carry copy of their own —
/// stays [ChipTapPrepareFailureReason.unknown] so the caller's fallback chain keeps its more actionable wording.
enum ChipTapPrepareFailureReason {
  credentialUnknown,
  credentialRevoked,
  credentialNotActive,
  notClassic,
  unknown;

  /// `credential_unknown` (404) is what an unrecognized `chip_uid` returns: the chip was never personalized against this environment, or it is not an XPERISE
  /// card at all. Both are the same thing to the operator — the card in their hand cannot be charged — so they share the invalid-card copy.
  static ChipTapPrepareFailureReason fromErrorCode(String? value) => switch (value) {
    'credential_unknown' => ChipTapPrepareFailureReason.credentialUnknown,
    'credential_revoked' => ChipTapPrepareFailureReason.credentialRevoked,
    'credential_not_active' => ChipTapPrepareFailureReason.credentialNotActive,
    'not_classic' => ChipTapPrepareFailureReason.notClassic,
    _ => ChipTapPrepareFailureReason.unknown,
  };

  String getTitle(XPLocaleBase locale, String fallback) {
    final viewLocale = locale.payment.xpay;
    return switch (this) {
      ChipTapPrepareFailureReason.credentialUnknown => viewLocale.nfcNotSupportedCardTitle,
      ChipTapPrepareFailureReason.credentialRevoked => viewLocale.nfcCardRevokedTitle,
      ChipTapPrepareFailureReason.credentialNotActive => viewLocale.nfcCardNotActiveTitle,
      ChipTapPrepareFailureReason.notClassic => viewLocale.nfcNotSupportedCardTitle,
      ChipTapPrepareFailureReason.unknown => fallback,
    };
  }

  /// [onFallback] is only consulted for [ChipTapPrepareFailureReason.unknown], so a network or session failure keeps its own wording rather than degrading to
  /// generic card-error text.
  String getBody(XPLocaleBase locale, String Function() onFallback) {
    final viewLocale = locale.payment.xpay;
    return switch (this) {
      ChipTapPrepareFailureReason.credentialUnknown => viewLocale.nfcNotSupportedCardBody,
      ChipTapPrepareFailureReason.credentialRevoked => viewLocale.nfcCardRevokedBody,
      ChipTapPrepareFailureReason.credentialNotActive => viewLocale.nfcCardNotActiveBody,
      ChipTapPrepareFailureReason.notClassic => viewLocale.nfcNotClassicCardBody,
      ChipTapPrepareFailureReason.unknown => onFallback.call(),
    };
  }
}

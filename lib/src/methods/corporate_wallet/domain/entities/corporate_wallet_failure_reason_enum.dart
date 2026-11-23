import '../../../../base/domain/domain.dart';
import '../../../../base/localization/localization.dart';

enum CorporateWalletFailureReason {
  otpInvalid,
  otpExpired,
  otpLocked,
  otpVelocityExceeded,
  otpDeliveryFailed,
  otpRecipientUnavailable,
  walletRefused,
  walletUnavailable,
  amountLocked,
  rideNotFound,
  rideNotOnCorporateWallet,
  sessionRejected,
  unknown;

  static CorporateWalletFailureReason fromRemote(String? value) => switch (value) {
    'otp_invalid' => CorporateWalletFailureReason.otpInvalid,
    'otp_expired' => CorporateWalletFailureReason.otpExpired,
    'otp_locked' => CorporateWalletFailureReason.otpLocked,
    'otp_velocity_exceeded' => CorporateWalletFailureReason.otpVelocityExceeded,
    'otp_delivery_failed' => CorporateWalletFailureReason.otpDeliveryFailed,
    'otp_recipient_unavailable' => CorporateWalletFailureReason.otpRecipientUnavailable,
    'corporate_wallet_refused' => CorporateWalletFailureReason.walletRefused,
    'corporate_wallet_unavailable' => CorporateWalletFailureReason.walletUnavailable,
    'amount_locked' => CorporateWalletFailureReason.amountLocked,
    'ride_not_found' => CorporateWalletFailureReason.rideNotFound,
    'ride_not_on_corporate_wallet' => CorporateWalletFailureReason.rideNotOnCorporateWallet,
    _ => CorporateWalletFailureReason.unknown,
  };

  static CorporateWalletFailureReason fromException(XPException failure) =>
      failure.isSessionRejected ? CorporateWalletFailureReason.sessionRejected : fromRemote(failure.errorCode);

  bool get isCodeRejection => this == CorporateWalletFailureReason.otpInvalid || this == CorporateWalletFailureReason.otpExpired || this == CorporateWalletFailureReason.otpLocked;

  bool get isCodeUnusable => this == CorporateWalletFailureReason.otpExpired || this == CorporateWalletFailureReason.otpLocked;

  bool get isTerminal =>
      this == CorporateWalletFailureReason.amountLocked ||
      this == CorporateWalletFailureReason.rideNotFound ||
      this == CorporateWalletFailureReason.rideNotOnCorporateWallet ||
      this == CorporateWalletFailureReason.sessionRejected;

  String? getTitle(XPLocaleBase locale) {
    final walletLocale = locale.payment.wallet;
    return switch (this) {
      CorporateWalletFailureReason.otpInvalid => locale.payment.verification.otpInvalidTitle,
      CorporateWalletFailureReason.otpExpired => walletLocale.otpExpiredTitle,
      CorporateWalletFailureReason.otpLocked => walletLocale.otpLockedTitle,
      CorporateWalletFailureReason.otpVelocityExceeded => walletLocale.otpVelocityExceededTitle,
      CorporateWalletFailureReason.otpDeliveryFailed => walletLocale.otpDeliveryFailedTitle,
      CorporateWalletFailureReason.otpRecipientUnavailable => walletLocale.otpRecipientUnavailableTitle,
      CorporateWalletFailureReason.walletRefused => walletLocale.walletRefusedTitle,
      CorporateWalletFailureReason.walletUnavailable => walletLocale.walletUnavailableTitle,
      CorporateWalletFailureReason.amountLocked => walletLocale.amountLockedTitle,
      CorporateWalletFailureReason.rideNotFound => walletLocale.rideNotFoundTitle,
      CorporateWalletFailureReason.rideNotOnCorporateWallet => walletLocale.rideNotOnCorporateWalletTitle,
      CorporateWalletFailureReason.sessionRejected => null,
      CorporateWalletFailureReason.unknown => null,
    };
  }

  String? getBody(XPLocaleBase locale) {
    final walletLocale = locale.payment.wallet;
    return switch (this) {
      CorporateWalletFailureReason.otpInvalid => locale.payment.verification.otpInvalidBody,
      CorporateWalletFailureReason.otpExpired => walletLocale.otpExpiredBody,
      CorporateWalletFailureReason.otpLocked => walletLocale.otpLockedBody,
      CorporateWalletFailureReason.otpVelocityExceeded => walletLocale.otpVelocityExceededBody,
      CorporateWalletFailureReason.otpDeliveryFailed => walletLocale.otpDeliveryFailedBody,
      CorporateWalletFailureReason.otpRecipientUnavailable => walletLocale.otpRecipientUnavailableBody,
      CorporateWalletFailureReason.walletRefused => walletLocale.walletRefusedBody,
      CorporateWalletFailureReason.walletUnavailable => walletLocale.walletUnavailableBody,
      CorporateWalletFailureReason.amountLocked => walletLocale.amountLockedBody,
      CorporateWalletFailureReason.rideNotFound => walletLocale.rideNotFoundBody,
      CorporateWalletFailureReason.rideNotOnCorporateWallet => walletLocale.rideNotOnCorporateWalletBody,
      CorporateWalletFailureReason.sessionRejected => null,
      CorporateWalletFailureReason.unknown => null,
    };
  }
}

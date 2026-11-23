import 'package:flutter/widgets.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/localization/localization.dart';

enum CorporateWalletOtpMethod {
  smsOtp(Remix.smartphone_line, Remix.message_3_line, Remix.chat_check_line),
  emailOtp(Remix.mail_line, Remix.mail_line, Remix.mail_check_line),
  unknown(Remix.shield_keyhole_line, Remix.shield_keyhole_line, Remix.shield_keyhole_line);

  const CorporateWalletOtpMethod(this.channelIcon, this.methodIcon, this.sentIcon);

  final IconData channelIcon;
  final IconData methodIcon;
  final IconData sentIcon;

  static CorporateWalletOtpMethod fromRemote(String? value) => switch (value) {
    'sms_otp' => CorporateWalletOtpMethod.smsOtp,
    'email_otp' => CorporateWalletOtpMethod.emailOtp,
    _ => CorporateWalletOtpMethod.unknown,
  };

  bool get isSupported => this != CorporateWalletOtpMethod.unknown;

  String? getTitle(XPLocaleBase locale) {
    final viewLocale = locale.payment.wallet;
    return switch (this) {
      CorporateWalletOtpMethod.smsOtp => viewLocale.methodSmsTitle,
      CorporateWalletOtpMethod.emailOtp => viewLocale.methodEmailTitle,
      CorporateWalletOtpMethod.unknown => null,
    };
  }

  String getBody(XPLocaleBase locale, String destination) {
    final viewLocale = locale.payment.wallet;
    return switch (this) {
      CorporateWalletOtpMethod.smsOtp => viewLocale.otpSentSmsBody(destination),
      CorporateWalletOtpMethod.emailOtp => viewLocale.otpSentEmailBody(destination),
      CorporateWalletOtpMethod.unknown => locale.payment.verification.otpSentBody,
    };
  }

  String? getLabel(XPLocaleBase locale) {
    final viewLocale = locale.payment.wallet;
    return switch (this) {
      CorporateWalletOtpMethod.smsOtp => viewLocale.channelSmsLabel,
      CorporateWalletOtpMethod.emailOtp => viewLocale.channelEmailLabel,
      CorporateWalletOtpMethod.unknown => null,
    };
  }

  String? toRemote() => switch (this) {
    CorporateWalletOtpMethod.smsOtp => 'sms_otp',
    CorporateWalletOtpMethod.emailOtp => 'email_otp',
    CorporateWalletOtpMethod.unknown => null,
  };
}

import 'package:flutter/widgets.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';

/// Real-time validation status of the manually entered card number (PAN).
///
/// [empty] carries no feedback (neutral); [valid] and [invalid] expose the
/// icon, color and localized message the UI renders under the PAN field.
enum CardManualPanStatus {
  empty(null, null),
  valid(Remix.checkbox_circle_line, XPColorText.success),
  invalid(Remix.error_warning_line, XPColorText.danger);

  const CardManualPanStatus(this.icon, this.color);

  final IconData? icon;
  final Color? color;

  bool get isEmpty => this == CardManualPanStatus.empty;

  String? getMessage(XPLocaleBase locale) {
    final viewLocale = locale.payment.create;
    return switch (this) {
      CardManualPanStatus.empty => null,
      CardManualPanStatus.valid => viewLocale.manualEntryPanValid,
      CardManualPanStatus.invalid => viewLocale.manualEntryPanInvalid,
    };
  }
}

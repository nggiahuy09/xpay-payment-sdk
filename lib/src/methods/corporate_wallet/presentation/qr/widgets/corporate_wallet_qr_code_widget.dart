import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../../base/define/constant/constant.dart';
import '../../../../../base/localization/localization.dart';
import '../../../../../shared/widgets/widgets.dart';

final class CorporateWalletQrCodeWidget extends StatelessWidget {
  const CorporateWalletQrCodeWidget({super.key, required this.qrPayload});

  static const double dimension = 208.0;

  static const PrettyQrDecoration _decoration = PrettyQrDecoration(background: XPColorSurface.defaultColor, quietZone: PrettyQrQuietZone.standard, shape: PrettyQrSquaresSymbol());

  final String qrPayload;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.wallet;

    return SizedBox.square(
      dimension: dimension,
      child: PrettyQrView.data(
        data: qrPayload,
        errorCorrectLevel: QrErrorCorrectLevel.Q,
        decoration: _decoration,
        errorBuilder: (_, _, _) => Center(
          child: Column(
            spacing: 8.0,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Remix.loop_left_line, size: 24.0, color: XPColorIcon.defaultColor),
              XPTextBodyWidget.extraSmall(viewLocale.qrRenderFailed, color: XPColorText.danger, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

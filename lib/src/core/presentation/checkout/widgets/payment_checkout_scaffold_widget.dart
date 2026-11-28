import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../shared/views/views.dart';
import '../../../../shared/widgets/widgets.dart';

final class PaymentCheckoutScaffoldWidget extends StatelessWidget {
  const PaymentCheckoutScaffoldWidget({super.key, required this.body, this.footer, required this.onBackPressed});

  final Widget body;
  final Widget? footer;
  final void Function() onBackPressed;

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;

    return Scaffold(
      backgroundColor: XPColorSurface.defaultColor,
      appBar: defaultTargetPlatform == TargetPlatform.iOS
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: XPAppBarWidget(onBackPressed: onBackPressed),
            )
          : null,
      body: XPPlatformSafeAreaView(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: body),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: footer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../../base/define/constant/constant.dart';
import '../../../../../base/localization/localization.dart';
import '../../../../../core/domain/entities/payment_order_entity.dart';
import '../../../../../core/presentation/verification/widgets/verification_icon_widget.dart';
import '../../../../../shared/helpers/helpers.dart';
import '../../../../../shared/loading/loading.dart';
import '../../../../../shared/views/views.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/payment_intent_entity.dart';
import '../blocs/payment_intent_bloc.dart';
import '../widgets/corporate_wallet_qr_code_widget.dart';

final class CorporateWalletQrView extends StatelessWidget {
  const CorporateWalletQrView({super.key, required this.order});

  final PaymentOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.wallet;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.read<PaymentIntentBloc>().add(const PaymentIntentCancelEvent());
      },
      child: Scaffold(
        backgroundColor: XPColorSurface.defaultColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: XPAppBarWidget(titleLabel: viewLocale.qrTitle, onBackPressed: () => Navigator.of(context).maybePop()),
        ),
        body: XPPlatformSafeAreaView(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8.0),
                const Center(child: VerificationIconWidget(icon: Remix.qr_code_line)),
                const SizedBox(height: 16.0),
                XPTextHeadingWidget.large(viewLocale.qrHeading, textAlign: TextAlign.center),
                const SizedBox(height: 8.0),
                XPTextBodyWidget.medium(viewLocale.qrBody, color: XPColorText.subtle, textAlign: TextAlign.center),
                const SizedBox(height: 24.0),
                BlocBuilder<PaymentIntentBloc, PaymentIntentState>(
                  builder: (_, state) => switch (state) {
                    PaymentIntentPendingState(intent: PaymentIntentEntity(qrPayload: final String qrPayload)) ||
                    PaymentIntentCancelErrorState(intent: PaymentIntentEntity(qrPayload: final String qrPayload)) => Center(
                      child: CorporateWalletQrCodeWidget(qrPayload: qrPayload),
                    ),
                    PaymentIntentCreateErrorState _ => _CorporateWalletQrErrorWidget(
                      errorCode: state.errorCode,
                      errorMessage: state.errorMessage,
                      onRetry: () => context.read<PaymentIntentBloc>().add(const PaymentIntentCreateEvent()),
                    ),
                    _ => const Center(
                      child: SizedBox.square(
                        dimension: CorporateWalletQrCodeWidget.dimension,
                        child: Center(child: XPCupertinoLoadingWidget()),
                      ),
                    ),
                  },
                ),
                const SizedBox(height: 24.0),
                DecoratedBox(
                  decoration: const BoxDecoration(color: XPColorSurface.secondary, borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded16))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      spacing: 12.0,
                      children: [
                        Expanded(child: XPTextBodyWidget.small(viewLocale.qrAmountLabel, color: XPColorText.subtle)),
                        XPTextHighlightWidget.small(XPHelperCurrencyFormat.format(order.amount, currency: order.currency)),
                      ],
                    ),
                  ),
                ),
                BlocSelector<PaymentIntentBloc, PaymentIntentState, bool>(
                  selector: (state) => state is PaymentIntentPendingState || state is PaymentIntentCancelErrorState,
                  builder: (_, isPending) => isPending
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            spacing: 8.0,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const XPCupertinoLoadingWidget(radius: 8.0),
                              XPTextBodyWidget.small(viewLocale.qrWaiting, color: XPColorText.subtle),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _CorporateWalletQrErrorWidget extends StatelessWidget {
  const _CorporateWalletQrErrorWidget({this.errorCode, this.errorMessage, required this.onRetry});

  final String? errorCode;
  final String? errorMessage;
  final void Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.wallet;

    return Column(
      spacing: 12.0,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        XPInlineMessageWidget.danger(title: viewLocale.qrCreateFailedTitle, body: errorMessage ?? locale.payment.xpay.resultGenericError(errorCode)),
        XPButtonFilled.medium(
          leadingIcon: const Icon(Remix.refresh_line, size: 20.0, color: XPColorIcon.defaultColor),
          backgroundColor: XPColorSurface.state,
          labelColor: XPColorText.defaultColor,
          label: locale.payment.xpay.retry,
          onPressed: onRetry,
        ),
      ],
    );
  }
}

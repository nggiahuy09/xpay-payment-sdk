import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../core/presentation/payment/widgets/xpay_payment_method_tile_widget.dart';
import '../../../../shared/loading/loading.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/corporate_wallet_otp_channel_entity.dart';
import '../blocs/corporate_wallet_bloc.dart';

final class CorporateWalletMethodsWidget extends StatelessWidget {
  const CorporateWalletMethodsWidget({super.key, required this.onQrSelected, required this.onChannelSelected});

  final void Function() onQrSelected;
  final void Function(CorporateWalletOtpChannelEntity channel) onChannelSelected;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.wallet;

    return Column(
      spacing: 12.0,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        XPayPaymentMethodTileWidget(icon: Remix.qr_code_line, subtitle: viewLocale.methodQrBody, title: viewLocale.methodQrTitle, onTap: onQrSelected),
        BlocBuilder<CorporateWalletBloc, CorporateWalletState>(
          builder: (_, state) => switch (state) {
            CorporateWalletInitState _ || CorporateWalletChannelsLoadingState _ => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(child: XPCupertinoLoadingWidget()),
            ),
            CorporateWalletChannelsLoadErrorState _ => _CorporateWalletChannelsErrorWidget(
              onRetry: () => context.read<CorporateWalletBloc>().add(const CorporateWalletLoadChannelsEvent()),
            ),
            _ => Column(
              spacing: 12.0,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final channel in state.channels)
                  XPayPaymentMethodTileWidget(
                    icon: channel.method.methodIcon,
                    subtitle: channel.summary,
                    title: channel.method.getTitle(locale) ?? channel.destinationMasked,
                    onTap: () => onChannelSelected.call(channel),
                  ),
              ],
            ),
          },
        ),
      ],
    );
  }
}

final class _CorporateWalletChannelsErrorWidget extends StatelessWidget {
  const _CorporateWalletChannelsErrorWidget({required this.onRetry});

  final void Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.wallet;

    return Column(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        XPInlineMessageWidget.danger(title: viewLocale.recipientsLoadFailedTitle, body: viewLocale.recipientsLoadFailedBody),
        XPTextButton.small(
          leadingIcon: const Icon(Remix.refresh_line, size: 18.0, color: XPColorIcon.primary),
          label: locale.payment.xpay.retry,
          onPressed: onRetry,
        ),
      ],
    );
  }
}

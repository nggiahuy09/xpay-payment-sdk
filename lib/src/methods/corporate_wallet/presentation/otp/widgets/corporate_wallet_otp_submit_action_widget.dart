import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../../base/define/constant/constant.dart';
import '../../../../../base/localization/localization.dart';
import '../../../../../core/domain/entities/payment_order_entity.dart';
import '../../../../../shared/helpers/helpers.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../blocs/corporate_wallet_otp_bloc.dart';

final class CorporateWalletOtpSubmitActionWidget extends StatelessWidget {
  const CorporateWalletOtpSubmitActionWidget({super.key, required this.order});

  final PaymentOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.verification;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: BlocBuilder<CorporateWalletOtpBloc, CorporateWalletOtpState>(
        buildWhen: (prev, next) => prev.canSubmit != next.canSubmit || (prev is CorporateWalletOtpSubmitLoadingState) != (next is CorporateWalletOtpSubmitLoadingState),
        builder: (_, state) {
          final isLoading = state is CorporateWalletOtpSubmitLoadingState;

          return XPButtonFilled.medium(
            leadingIcon: Icon(Remix.shield_check_line, size: 20.0, color: state.canSubmit && !isLoading ? XPColorIcon.inversed : XPColorIcon.subtle),
            label: '${viewLocale.verifyAndPayButton} · ${XPHelperCurrencyFormat.format(order.amount, currency: order.currency)}',
            enabled: state.canSubmit,
            loading: isLoading,
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              context.read<CorporateWalletOtpBloc>().add(const CorporateWalletOtpSubmitEvent());
            },
          );
        },
      ),
    );
  }
}

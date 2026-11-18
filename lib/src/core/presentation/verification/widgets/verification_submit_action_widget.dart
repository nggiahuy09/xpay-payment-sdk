import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../shared/helpers/helpers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../blocs/verification_bloc.dart';

final class VerificationSubmitActionWidget extends StatelessWidget {
  const VerificationSubmitActionWidget({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: BlocBuilder<VerificationBloc, VerificationState>(
        buildWhen: (prev, next) {
          return prev.canSubmit != next.canSubmit || prev.amount != next.amount || (prev is VerificationSubmitLoadingState) != (next is VerificationSubmitLoadingState);
        },
        builder: (context, state) => XPButtonFilled.medium(
          leadingIcon: Icon(Remix.shield_check_line, size: 20.0, color: state.canSubmit && state is! VerificationSubmitLoadingState ? XPColorIcon.inversed : XPColorIcon.subtle),
          label: '$label · ${XPHelperCurrencyFormat.format(state.amount)}',
          enabled: state.canSubmit,
          loading: state is VerificationSubmitLoadingState,
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            context.read<VerificationBloc>().add(const VerificationSubmitEvent());
          },
        ),
      ),
    );
  }
}

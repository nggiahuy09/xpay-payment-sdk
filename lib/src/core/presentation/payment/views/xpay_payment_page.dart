import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../methods/corporate_wallet/presentation/views/corporate_wallet_payment_page.dart';
import '../../../domain/entities/payment_entry_mode_enum.dart';
import '../../../domain/entities/payment_flow_outcome_entity.dart';
import '../../../domain/entities/payment_method_enum.dart';
import '../../../domain/entities/payment_session_entity.dart';
import '../blocs/xpay_payment_bloc.dart';
import 'xpay_payment_view.dart';

final class XPayPaymentPage extends StatelessWidget {
  const XPayPaymentPage({super.key, required this.entryModes, required this.session, required this.method, required this.onOutcome});

  final List<PaymentEntryMode> entryModes;
  final PaymentSessionEntity session;
  final PaymentMethod method;
  final void Function(PaymentFlowOutcomeEntity outcome) onOutcome;

  @override
  Widget build(BuildContext context) => switch (method) {
    PaymentMethod.corporateWallet => CorporateWalletPaymentPage(session: session, onOutcome: onOutcome),
    PaymentMethod.card || PaymentMethod.unknown => BlocProvider<XPayPaymentBloc>(
      create: (_) => XPayPaymentBloc(order: session.order),
      child: XPayPaymentView(entryModes: entryModes, session: session, onOutcome: onOutcome),
    ),
  };
}

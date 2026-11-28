import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/payment_flow_outcome_entity.dart';
import '../../../../core/domain/entities/payment_session_entity.dart';
import '../blocs/corporate_wallet_bloc.dart';
import '../qr/blocs/payment_intent_bloc.dart';
import 'corporate_wallet_payment_view.dart';

final class CorporateWalletPaymentPage extends StatelessWidget {
  const CorporateWalletPaymentPage({super.key, required this.session, required this.onOutcome});

  final PaymentSessionEntity session;
  final void Function(PaymentFlowOutcomeEntity outcome) onOutcome;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<CorporateWalletBloc>(create: (_) => CorporateWalletBloc()),
      BlocProvider<PaymentIntentBloc>(create: (_) => PaymentIntentBloc(order: session.order)),
    ],
    child: CorporateWalletPaymentView(session: session, onOutcome: onOutcome),
  );
}

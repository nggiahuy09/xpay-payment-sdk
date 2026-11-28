import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/payment_entry_mode_enum.dart';
import '../../../domain/entities/payment_session_entity.dart';
import '../blocs/payment_checkout_bloc.dart';
import 'payment_checkout_view.dart';

final class PaymentCheckoutPage extends StatelessWidget {
  const PaymentCheckoutPage({super.key, required this.entryModes, required this.session});

  final List<PaymentEntryMode> entryModes;
  final PaymentSessionEntity session;

  @override
  Widget build(BuildContext context) => BlocProvider<PaymentCheckoutBloc>(
    create: (_) => PaymentCheckoutBloc(order: session.order, method: session.method, canPayByCard: entryModes.isNotEmpty),
    child: PaymentCheckoutView(entryModes: entryModes, session: session),
  );
}

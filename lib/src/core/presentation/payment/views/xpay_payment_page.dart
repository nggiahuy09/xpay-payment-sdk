import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/payment_entry_mode_enum.dart';
import '../../../domain/entities/payment_session_entity.dart';
import '../blocs/xpay_payment_bloc.dart';
import 'xpay_payment_view.dart';

final class XPayPaymentPage extends StatelessWidget {
  const XPayPaymentPage({super.key, required this.entryModes, required this.session});

  final List<PaymentEntryMode> entryModes;
  final PaymentSessionEntity session;

  @override
  Widget build(BuildContext context) => BlocProvider<XPayPaymentBloc>(
    create: (_) => XPayPaymentBloc(order: session.order),
    child: XPayPaymentView(entryModes: entryModes, session: session),
  );
}

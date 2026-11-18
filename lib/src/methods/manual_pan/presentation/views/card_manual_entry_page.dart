import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/card_manual_entry_bloc.dart';
import 'card_manual_entry_view.dart';

/// Collects the card number (PAN) manually, then hands the raw PAN (digits only) to [onSubmitted] so the caller can authorize the payment while this page stays open.
final class CardManualEntryPage extends StatelessWidget {
  const CardManualEntryPage({super.key, required this.amount, required this.onSubmitted});

  final double amount;
  final void Function(String pan) onSubmitted;

  @override
  Widget build(BuildContext context) => BlocProvider<CardManualEntryBloc>(
    create: (_) => CardManualEntryBloc(),
    child: CardManualEntryView(amount: amount, onSubmitted: onSubmitted),
  );
}

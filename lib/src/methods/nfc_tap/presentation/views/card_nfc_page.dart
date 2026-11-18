import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/card_nfc_bloc.dart';
import 'card_nfc_view.dart';

final class CardNfcPage extends StatelessWidget {
  const CardNfcPage({super.key, required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CardNfcBloc(),
      child: CardNfcView(amount: amount),
    );
  }
}

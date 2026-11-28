import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/domain/entities/payment_order_entity.dart';
import '../../../domain/entities/corporate_wallet_challenge_entity.dart';
import '../../../domain/entities/corporate_wallet_otp_channel_entity.dart';
import '../../../domain/entities/corporate_wallet_payment_entity.dart';
import '../blocs/corporate_wallet_otp_bloc.dart';
import 'corporate_wallet_otp_view.dart';

final class CorporateWalletOtpPage extends StatelessWidget {
  const CorporateWalletOtpPage({
    super.key,
    required this.channels,
    required this.challenge,
    required this.order,
    required this.onSubmittingChanged,
    required this.onVerified,
    required this.onInterrupted,
    required this.onFailed,
  });

  final List<CorporateWalletOtpChannelEntity> channels;
  final CorporateWalletChallengeEntity challenge;
  final PaymentOrderEntity order;
  final void Function(bool isSubmitting) onSubmittingChanged;
  final void Function(CorporateWalletPaymentEntity payment) onVerified;
  final void Function(String? errorCode) onInterrupted;
  final void Function(String? errorCode, bool isConflict) onFailed;

  @override
  Widget build(BuildContext context) => BlocProvider<CorporateWalletOtpBloc>(
    create: (_) => CorporateWalletOtpBloc(channels: channels, challenge: challenge),
    child: CorporateWalletOtpView(order: order, onSubmittingChanged: onSubmittingChanged, onVerified: onVerified, onInterrupted: onInterrupted, onFailed: onFailed),
  );
}

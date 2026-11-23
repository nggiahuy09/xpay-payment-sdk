import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../base/localization/localization.dart';
import 'corporate_wallet_otp_method_enum.dart';

@immutable
final class CorporateWalletOtpChannelEntity with Equatable {
  const CorporateWalletOtpChannelEntity({required this.method, required this.destinationMasked, this.name, required this.recipientId});

  final CorporateWalletOtpMethod method;
  final String destinationMasked;
  final String? name;
  final String recipientId;

  String get summary => switch (name) {
    final String value => '$value · $destinationMasked',
    _ => destinationMasked,
  };

  String getLabel(XPLocaleBase locale) {
    final methodLabel = method.getLabel(locale) ?? '';
    return switch (name) {
      final String value when methodLabel.isEmpty => value,
      final String value => '$value · $methodLabel',
      _ => methodLabel,
    };
  }

  bool isSameAs({required CorporateWalletOtpMethod method, required String recipientId}) => this.method == method && this.recipientId == recipientId;

  @override
  List<Object?> get props => [method, destinationMasked, name, recipientId];
}

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class CorporateWalletOtpErrorDetailsEntity with Equatable {
  const CorporateWalletOtpErrorDetailsEntity({this.attemptsRemaining});

  final int? attemptsRemaining;

  @override
  List<Object?> get props => [attemptsRemaining];
}

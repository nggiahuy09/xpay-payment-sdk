import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../base/extensions/extensions.dart';
import '../../../base/localization/localization.dart';
import 'payment_decline_reason.dart';
import 'payment_entry_mode_enum.dart';

@immutable
final class PaymentDeclineEntity with Equatable {
  const PaymentDeclineEntity._(this.reason, this._rawErrorCode);

  /// The raw code is normalised here rather than at each mapper: a payload carrying an empty or whitespace-only `decline_reason` must read as "no code given" so the
  /// message falls back to plain generic copy instead of a dangling `Error code:` line.
  factory PaymentDeclineEntity.fromRemote(String? value) => PaymentDeclineEntity._(PaymentDeclineReason.fromRemote(value), value?.nullIfEmpty());

  final PaymentDeclineReason reason;
  final String? _rawErrorCode;

  String? get rawErrorCode => _rawErrorCode;

  bool get isExpired => reason.isExpired;

  bool get isServiceError => reason.isServiceError;

  String getMessage(XPLocaleBase locale, {PaymentEntryMode? entryMode, bool canTapCard = false}) {
    return reason.getMessage(locale, entryMode: entryMode, canTapCard: canTapCard, errorCode: () => _rawErrorCode);
  }

  @override
  List<Object?> get props => [reason, _rawErrorCode];
}

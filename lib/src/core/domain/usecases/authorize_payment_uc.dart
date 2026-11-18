import 'package:fpdart/fpdart.dart';

import '../../../base/domain/domain.dart';
import '../../../shared/helpers/helpers.dart';
import '../entities/create_payment_product_type_enum.dart';
import '../entities/payment_authorize_entity.dart';
import '../entities/payment_chip_tap_entity.dart';
import '../entities/payment_entry_mode_enum.dart';
import '../repositories/payment_authorize_repo.dart';

final class AuthorizePaymentUseCase with XPUseCase<AuthorizePaymentInput, PaymentAuthorizeEntity> {
  const AuthorizePaymentUseCase(this._repository);

  final PaymentAuthorizeRepository _repository;

  @override
  Future<Either<XPException, PaymentAuthorizeEntity>> execute(AuthorizePaymentInput input) {
    return _repository.authorize(
      cardToken: input.cardToken,
      entryMode: input.entryMode,
      amount: input.amount,
      currency: input.currency,
      externalRef: input.externalRef,
      idempotencyKey: input.idempotencyKey,
      chipTap: input.chipTap,
      productType: input.productType,
      serviceDate: input.serviceDate,
      verificationCode: input.verificationCode,
      merchantId: input.merchantId,
      mcc: input.mcc,
      otpRecipientId: input.otpRecipientId,
      autoCapture: input.autoCapture,
    );
  }
}

final class AuthorizePaymentInput implements XPLoggable {
  const AuthorizePaymentInput({
    required this.cardToken,
    required this.entryMode,
    required this.amount,
    required this.currency,
    required this.externalRef,
    required this.idempotencyKey,
    this.chipTap,
    this.productType,
    this.serviceDate,
    this.verificationCode,
    this.merchantId,
    this.mcc,
    this.otpRecipientId,
    this.autoCapture = false,
  });

  /// Required when [entryMode] is [PaymentEntryMode.chipTap] and meaningless otherwise — the endpoint rejects a chip tap without it.
  final PaymentChipTapEntity? chipTap;
  final PaymentEntryMode entryMode;
  final CreatePaymentProductType? productType;
  final DateTime? serviceDate;
  final String cardToken;
  final String amount;
  final String currency;
  final String externalRef;

  /// Supplied by the caller so a retry of the same logical authorization reuses it, which is what makes the server-side deduplication effective.
  final String idempotencyKey;
  final String? verificationCode;
  final String? merchantId;
  final String? mcc;
  final String? otpRecipientId;
  final bool autoCapture;

  @override
  Map<String, dynamic> toLog() => {
    'entry_mode': entryMode.name,
    'amount': amount,
    'currency': currency,
    'external_ref': externalRef,
    if (productType != null) 'product_type': productType?.toRemote(),
    if (serviceDate != null) 'service_date': XPHelperDateTime.format(serviceDate, format: XPDateTimeFormat.yearMonthDay),
    if (merchantId != null) 'merchant_id': merchantId,
    if (mcc != null) 'mcc': mcc,
    if (otpRecipientId != null) 'otp_recipient_id': otpRecipientId,
    'auto_capture': autoCapture,
  };
}

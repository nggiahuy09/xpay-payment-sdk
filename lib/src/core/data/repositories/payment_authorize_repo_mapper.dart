import '../../../base/extensions/extensions.dart';
import '../../../shared/helpers/helpers.dart';
import '../../domain/entities/payment_authorize_entity.dart';
import '../../domain/entities/payment_chip_tap_entity.dart';
import '../../domain/entities/payment_decline_entity.dart';
import '../datasources/remote/models/payment_authorize_request_model.dart';
import '../datasources/remote/models/payment_authorize_response_model.dart';
import 'payment_status_mapper.dart';
import 'payment_verification_recipient_mapper.dart';

extension PaymentAuthorizeResponseModelMapper on PaymentAuthorizeResponseModel {
  PaymentAuthorizeEntity toEntity() => PaymentAuthorizeEntity(
    status: paymentStatusFromRemote(status),
    verification: verification?.toEntity(),
    declineReason: declineReason != null ? PaymentDeclineEntity.fromRemote(declineReason) : null,
    holdExpiresAt: DateTime.tryParse(holdExpiresAt ?? '')?.toLocal(),
    createdAt: DateTime.tryParse(createdAt ?? '')?.toLocal(),
    authId: authId,
    captureId: captureId,
    externalRef: externalRef,
    amount: amount,
    currency: currency,
  );
}

extension PaymentChipTapEntityMapper on PaymentChipTapEntity {
  PaymentAuthorizeChipTapModel toModel() => PaymentAuthorizeChipTapModel(cryptogram: cryptogram, nonce: nonce, counter: counter, keyVersion: keyVersion);
}

extension PaymentAuthorizeServiceDateMapper on DateTime {
  String toRemoteServiceDate() => XPHelperDateTime.format(this, format: XPDateTimeFormat.yearMonthDay);
}

extension PaymentAuthorizeVerificationRemoteModelMapper on PaymentAuthorizeVerificationRemoteModel {
  PaymentAuthorizeVerificationEntity toEntity() => PaymentAuthorizeVerificationEntity(
    recipients: recipients?.mapNotNull((e) => e.toEntity()).toList() ?? const [],
    method: paymentVerificationMethodFromRemote(method),
    expiresAt: DateTime.tryParse(expiresAt ?? '')?.toLocal(),
    verificationDeadline: DateTime.tryParse(verificationDeadline ?? '')?.toLocal(),
    canResendAt: DateTime.tryParse(canResendAt ?? '')?.toLocal(),
    attemptsRemaining: attemptsRemaining,
    resendsRemaining: resendsRemaining,
    phoneMasked: phoneMasked,
    isRecipientRequired: recipientRequired ?? false,
  );
}

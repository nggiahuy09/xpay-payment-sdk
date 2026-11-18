import '../../../base/extensions/extensions.dart';
import '../../domain/entities/payment_authorize_entity.dart';
import '../../domain/entities/payment_decline_entity.dart';
import '../../domain/entities/payment_verify_entity.dart';
import '../datasources/remote/models/payment_verify_response_model.dart';
import 'payment_status_mapper.dart';
import 'payment_verification_recipient_mapper.dart';

extension PaymentVerifyResponseModelMapper on PaymentVerifyResponseModel {
  PaymentVerifyEntity toEntity() => PaymentVerifyEntity(
    status: paymentStatusFromRemote(status),
    verification: verification?.toEntity(),
    attribution: attribution?.toEntity(),
    declineReason: declineReason != null ? PaymentDeclineEntity.fromRemote(declineReason) : null,
    holdExpiresAt: DateTime.tryParse(holdExpiresAt ?? '')?.toLocal(),
    createdAt: DateTime.tryParse(createdAt ?? '')?.toLocal(),
    authId: authId,
    captureId: captureId,
    cardId: cardId,
    corporateId: corporateId,
    bookingRef: bookingRef,
    externalRef: externalRef,
    policyCheck: policyCheck,
    amount: amount,
    currency: currency,
  );
}

extension PaymentVerifyVerificationRemoteModelMapper on PaymentVerifyVerificationRemoteModel {
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

extension PaymentVerifyAttributionRemoteModelMapper on PaymentVerifyAttributionRemoteModel {
  PaymentVerifyAttributionEntity toEntity() => PaymentVerifyAttributionEntity(
    userId: userId,
    corporateId: corporateId,
    costCenterId: costCenterId,
    department: department,
    tripId: tripId,
    tripMatch: tripMatch,
  );
}

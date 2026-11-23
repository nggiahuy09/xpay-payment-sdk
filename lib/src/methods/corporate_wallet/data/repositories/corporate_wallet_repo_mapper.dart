import '../../../../base/extensions/extensions.dart';
import '../../domain/entities/corporate_wallet_challenge_entity.dart';
import '../../domain/entities/corporate_wallet_otp_channel_entity.dart';
import '../../domain/entities/corporate_wallet_otp_error_details_entity.dart';
import '../../domain/entities/corporate_wallet_otp_method_enum.dart';
import '../../domain/entities/corporate_wallet_payment_entity.dart';
import '../../domain/entities/payment_intent_entity.dart';
import '../../domain/entities/payment_intent_status_enum.dart';
import '../datasources/remote/models/corporate_wallet_payment_models.dart';
import '../datasources/remote/models/corporate_wallet_recipient_model.dart';
import '../datasources/remote/models/payment_intent_response_model.dart';

extension CorporateWalletRecipientModelsMapper on List<CorporateWalletRecipientModel> {
  List<CorporateWalletOtpChannelEntity> toChannels() => [for (final recipient in this) ...recipient._toChannels()];
}

extension on CorporateWalletRecipientModel {
  List<CorporateWalletOtpChannelEntity> _toChannels() {
    final id = recipientId?.nullIfEmpty((value) => value.trim());
    if (id == null) return const [];

    final displayName = name?.nullIfEmpty((value) => value.trim());
    final phone = phoneMasked?.nullIfEmpty((value) => value.trim());
    final email = emailMasked?.nullIfEmpty((value) => value.trim());
    return [
      if (phone != null) CorporateWalletOtpChannelEntity(method: CorporateWalletOtpMethod.smsOtp, destinationMasked: phone, name: displayName, recipientId: id),
      if (email != null) CorporateWalletOtpChannelEntity(method: CorporateWalletOtpMethod.emailOtp, destinationMasked: email, name: displayName, recipientId: id),
    ];
  }
}

extension CorporateWalletChallengeModelMapper on CorporateWalletChallengeModel {
  CorporateWalletChallengeEntity? toEntity() {
    final id = walletPaymentId?.nullIfEmpty((value) => value.trim());
    final destination = verification?.destinationMasked?.nullIfEmpty((value) => value.trim());
    final recipient = verification?.recipientId?.nullIfEmpty((value) => value.trim());
    if (id == null || destination == null || recipient == null) return null;

    return CorporateWalletChallengeEntity(
      method: CorporateWalletOtpMethod.fromRemote(verification?.method),
      expiresAt: DateTime.tryParse(verification?.expiresAt ?? '')?.toLocal(),
      destinationMasked: destination,
      recipientId: recipient,
      walletPaymentId: id,
      attemptsRemaining: verification?.attemptsRemaining,
    );
  }
}

extension CorporateWalletPaymentResponseModelMapper on CorporateWalletPaymentResponseModel {
  CorporateWalletPaymentEntity toEntity() => CorporateWalletPaymentEntity(currency: currency, externalRef: externalRef, walletPaymentId: walletPaymentId, amount: amount);
}

extension CorporateWalletOtpErrorDetailsModelMapper on CorporateWalletOtpErrorDetailsModel {
  CorporateWalletOtpErrorDetailsEntity toEntity() => CorporateWalletOtpErrorDetailsEntity(attemptsRemaining: attemptsRemaining);
}

extension PaymentIntentResponseModelMapper on PaymentIntentResponseModel {
  PaymentIntentEntity? toEntity() {
    final id = intentId?.nullIfEmpty((value) => value.trim());
    if (id == null) return null;

    return PaymentIntentEntity(
      status: PaymentIntentStatus.fromRemote(status),
      createdAt: DateTime.tryParse(createdAt ?? '')?.toLocal(),
      authId: authId,
      currency: currency,
      externalRef: externalRef,
      intentId: id,
      qrPayload: qrPayload?.nullIfEmpty(),
      amount: amount,
    );
  }
}

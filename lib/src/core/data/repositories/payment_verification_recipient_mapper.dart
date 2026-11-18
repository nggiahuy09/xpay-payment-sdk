import '../../../base/extensions/extensions.dart';
import '../../domain/entities/payment_verification_recipient_entity.dart';
import '../datasources/remote/models/payment_verification_recipient_model.dart';

extension PaymentVerificationRecipientModelMapper on PaymentVerificationRecipientModel {
  PaymentVerificationRecipientEntity? toEntity() {
    final id = recipientId?.nullIfEmpty();
    if (id == null) return null;

    return PaymentVerificationRecipientEntity(recipientId: id, phoneMasked: phoneMasked ?? '');
  }
}

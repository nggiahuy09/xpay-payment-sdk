import '../../domain/entities/payment_method_enum.dart';
import '../../domain/entities/ride_payment_status_entity.dart';
import '../datasources/remote/models/ride_payment_status_response_model.dart';

extension RidePaymentStatusResponseModelMapper on RidePaymentStatusResponseModel {
  RidePaymentStatusEntity toEntity() => RidePaymentStatusEntity(payment: payment?.toEntity(), rideStatus: RideStatus.fromRemote(rideStatus), externalRef: externalRef ?? '');
}

extension RidePaymentStatusPaymentModelMapper on RidePaymentStatusPaymentModel {
  RidePaymentEntity toEntity() => RidePaymentEntity(method: PaymentMethod.fromRemote(paymentMethod), paidBy: RidePaymentPayer.fromRemote(paidBy), authId: authId, amount: amount);
}

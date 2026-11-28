import 'package:get_it/get_it.dart';

import '../api/xpay_log_event.dart';
import '../base/gateway/api/api.dart';
import '../core/data/datasources/remote/payment_authorize_remote_datasrc.dart';
import '../core/data/datasources/remote/ride_payment_remote_datasrc.dart';
import '../core/data/repositories/payment_authorize_repo_impl.dart';
import '../core/data/repositories/ride_payment_repo_impl.dart';
import '../core/domain/repositories/payment_authorize_repo.dart';
import '../core/domain/repositories/ride_payment_repo.dart';
import '../core/presentation/payment/helpers/payment_authorize_idempotency_tracker.dart';
import '../core/presentation/payment/helpers/payment_host_cancellation.dart';
import '../methods/corporate_wallet/data/datasources/remote/corporate_wallet_remote_datasrc.dart';
import '../methods/corporate_wallet/data/repositories/corporate_wallet_repo_impl.dart';
import '../methods/corporate_wallet/domain/repositories/corporate_wallet_repo.dart';
import '../methods/nfc_tap/data/datasources/remote/chip_tap_remote_datasrc.dart';
import '../methods/nfc_tap/data/repositories/chip_tap_repo_impl.dart';
import '../methods/nfc_tap/domain/repositories/chip_tap_repo.dart';
import '../shared/business_logger/xp_business_logger.dart';
import '../shared/snack_bar/snack_bar_manager.dart';

final GetIt getIt = GetIt.asNewInstance();

const Duration _kConnectTimeout = Duration(seconds: 30);
const Duration _kReceiveTimeout = Duration(seconds: 30);

Future<void> configureDependencies({required XPTokenProvider tokenProvider, required String baseUrl, void Function(XPayLogEvent event)? onLog}) async {
  if (getIt.isRegistered<PaymentAuthorizeIdempotencyTracker>() == false) getIt.registerSingleton(PaymentAuthorizeIdempotencyTracker());
  if (getIt.isRegistered<PaymentHostCancellation>() == false) getIt.registerSingleton(PaymentHostCancellation());

  await _unregisterIfPresent<XPBusinessLogger>();
  await _unregisterIfPresent<XPRestClient>();
  await _unregisterIfPresent<SnackBarCubit>();
  await _unregisterIfPresent<PaymentAuthorizeRemoteDatasource>();
  await _unregisterIfPresent<PaymentAuthorizeRepository>();
  await _unregisterIfPresent<RidePaymentRemoteDatasource>();
  await _unregisterIfPresent<RidePaymentRepository>();
  await _unregisterIfPresent<ChipTapRemoteDatasource>();
  await _unregisterIfPresent<ChipTapRepository>();
  await _unregisterIfPresent<CorporateWalletRemoteDatasource>();
  await _unregisterIfPresent<CorporateWalletRepository>();

  getIt.registerSingleton(XPBusinessLogger(onLog));
  getIt.registerSingleton(XPRestClient(tokenProvider: tokenProvider, connectTimeout: _kConnectTimeout, receiveTimeout: _kReceiveTimeout, baseUrl: baseUrl));
  getIt.registerLazySingleton(SnackBarCubit.new, dispose: (cubit) => cubit.close());
  getIt.registerLazySingleton(PaymentAuthorizeRemoteDatasource.new);
  getIt.registerLazySingleton<PaymentAuthorizeRepository>(PaymentAuthorizeRepositoryImpl.new);
  getIt.registerLazySingleton(RidePaymentRemoteDatasource.new);
  getIt.registerLazySingleton<RidePaymentRepository>(RidePaymentRepositoryImpl.new);
  getIt.registerLazySingleton(ChipTapRemoteDatasource.new);
  getIt.registerLazySingleton<ChipTapRepository>(ChipTapRepositoryImpl.new);
  getIt.registerLazySingleton(CorporateWalletRemoteDatasource.new);
  getIt.registerLazySingleton<CorporateWalletRepository>(CorporateWalletRepositoryImpl.new);
}

Future<void> _unregisterIfPresent<T extends Object>() async {
  if (getIt.isRegistered<T>()) await getIt.unregister<T>();
}

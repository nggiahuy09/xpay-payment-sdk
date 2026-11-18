import 'package:get_it/get_it.dart';

import '../api/xpay_log_event.dart';
import '../base/gateway/api/api.dart';
import '../core/data/datasources/remote/payment_authorize_remote_datasrc.dart';
import '../core/data/repositories/payment_authorize_repo_impl.dart';
import '../core/domain/repositories/payment_authorize_repo.dart';
import '../core/presentation/payment/helpers/payment_authorize_idempotency_tracker.dart';
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

  await _unregisterIfPresent<XPBusinessLogger>();
  await _unregisterIfPresent<XPRestClient>();
  await _unregisterIfPresent<SnackBarCubit>();
  await _unregisterIfPresent<PaymentAuthorizeRemoteDatasource>();
  await _unregisterIfPresent<PaymentAuthorizeRepository>();
  await _unregisterIfPresent<ChipTapRemoteDatasource>();
  await _unregisterIfPresent<ChipTapRepository>();

  getIt.registerSingleton(XPBusinessLogger(onLog));
  getIt.registerSingleton(XPRestClient(tokenProvider: tokenProvider, connectTimeout: _kConnectTimeout, receiveTimeout: _kReceiveTimeout, baseUrl: baseUrl));
  getIt.registerLazySingleton(SnackBarCubit.new, dispose: (cubit) => cubit.close());
  getIt.registerLazySingleton(PaymentAuthorizeRemoteDatasource.new);
  getIt.registerLazySingleton<PaymentAuthorizeRepository>(PaymentAuthorizeRepositoryImpl.new);
  getIt.registerLazySingleton(ChipTapRemoteDatasource.new);
  getIt.registerLazySingleton<ChipTapRepository>(ChipTapRepositoryImpl.new);
}

Future<void> _unregisterIfPresent<T extends Object>() async {
  if (getIt.isRegistered<T>()) await getIt.unregister<T>();
}

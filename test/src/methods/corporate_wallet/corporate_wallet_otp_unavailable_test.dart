import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:xpay_payment_sdk/src/base/domain/domain.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/create_payment_product_type_enum.dart';
import 'package:xpay_payment_sdk/src/methods/corporate_wallet/domain/entities/corporate_wallet_challenge_entity.dart';
import 'package:xpay_payment_sdk/src/methods/corporate_wallet/domain/entities/corporate_wallet_failure_reason_enum.dart';
import 'package:xpay_payment_sdk/src/methods/corporate_wallet/domain/entities/corporate_wallet_otp_channel_entity.dart';
import 'package:xpay_payment_sdk/src/methods/corporate_wallet/domain/entities/corporate_wallet_otp_method_enum.dart';
import 'package:xpay_payment_sdk/src/methods/corporate_wallet/domain/entities/corporate_wallet_payment_entity.dart';
import 'package:xpay_payment_sdk/src/methods/corporate_wallet/domain/entities/payment_intent_entity.dart';
import 'package:xpay_payment_sdk/src/methods/corporate_wallet/domain/repositories/corporate_wallet_repo.dart';
import 'package:xpay_payment_sdk/src/methods/corporate_wallet/presentation/otp/blocs/corporate_wallet_otp_bloc.dart';
import 'package:xpay_payment_sdk/src/di/di.dart';
import 'package:xpay_payment_sdk/src/shared/business_logger/xp_business_logger.dart';

const _unavailable = XPApiException(errorCode: 'corporate_wallet_unavailable', statusCode: 503);

final _repository = _VerifyRepository();

final class _VerifyRepository extends CorporateWalletRepository {
  final List<Either<XPException, CorporateWalletPaymentEntity>> _replies = [];
  final List<String> codes = [];

  void reply(List<Either<XPException, CorporateWalletPaymentEntity>> replies) => _replies
    ..clear()
    ..addAll(replies);

  @override
  Future<Either<XPException, CorporateWalletPaymentEntity>> verifyOtp({required String walletPaymentId, required String code}) async {
    codes.add(code);
    return _replies.isEmpty ? const Left(_unavailable) : _replies.removeAt(0);
  }

  @override
  Future<Either<XPException, List<CorporateWalletOtpChannelEntity>>> getOtpChannels() async => throw UnimplementedError();

  @override
  Future<Either<XPException, CorporateWalletChallengeEntity>> requestOtp(CorporateWalletOtpMethod method, String recipientId) async => throw UnimplementedError();

  @override
  Future<Either<XPException, PaymentIntentEntity>> createIntent({
    required CreatePaymentProductType productType,
    required String currency,
    required String externalRef,
    required String idempotencyKey,
    required int amount,
  }) async => throw UnimplementedError();

  @override
  Future<Either<XPException, PaymentIntentEntity>> getIntent(String intentId) async => throw UnimplementedError();

  @override
  Future<Either<XPException, PaymentIntentEntity>> cancelIntent(String intentId) async => throw UnimplementedError();
}

Future<CorporateWalletOtpBloc> _submit(WidgetTester tester) async {
  final bloc = CorporateWalletOtpBloc(
    channels: const [],
    challenge: const CorporateWalletChallengeEntity(method: CorporateWalletOtpMethod.smsOtp, destinationMasked: '***789', recipientId: 'r-1', walletPaymentId: 'wp-1'),
  );
  addTearDown(bloc.close);
  bloc.add(const CorporateWalletOtpChangeCodeEvent('123456'));
  bloc.add(const CorporateWalletOtpSubmitEvent());
  await tester.pump();
  return bloc;
}

void main() {
  setUpAll(() {
    getIt.registerSingleton<CorporateWalletRepository>(_repository);
    getIt.registerSingleton(const XPBusinessLogger(null));
  });

  tearDownAll(() => getIt.reset());

  setUp(() {
    _repository.codes.clear();
    _repository.reply([]);
  });

  testWidgets('a wallet that answers on a retry captures the payment without showing an error', (tester) async {
    _repository.reply([const Left(_unavailable), const Right(CorporateWalletPaymentEntity(walletPaymentId: 'wp-1', amount: '138000.00'))]);

    final bloc = await _submit(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(_repository.codes, ['123456', '123456']);
    expect(bloc.state, isA<CorporateWalletOtpVerifiedState>());
  });

  testWidgets('a wallet still unavailable after three tries with the same code hands the failure on', (tester) async {
    final bloc = await _submit(tester);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(_repository.codes, ['123456', '123456', '123456']);
    expect(bloc.state, isA<CorporateWalletOtpVerifyErrorState>().having((s) => s.reason, 'reason', CorporateWalletFailureReason.walletUnavailable));
    expect(CorporateWalletFailureReason.walletUnavailable.needsHotline, isTrue);
  });

  testWidgets('a code the wallet no longer waits for asks for a new code, like an expired one', (tester) async {
    _repository.reply([const Left(XPApiException(errorCode: 'otp_not_pending', statusCode: 422))]);

    final bloc = await _submit(tester);

    expect(bloc.state, isA<CorporateWalletOtpRejectedState>().having((s) => s.rejection, 'rejection', CorporateWalletFailureReason.otpNotPending));
    expect(CorporateWalletFailureReason.otpNotPending.isCodeUnusable, isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:xpay_payment_sdk/src/base/domain/domain.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/create_payment_product_type_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_authorize_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_chip_tap_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_decline_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_entry_mode_enum.dart';
import 'package:xpay_payment_sdk/src/core/domain/entities/payment_verify_entity.dart';
import 'package:xpay_payment_sdk/src/core/domain/repositories/payment_authorize_repo.dart';
import 'package:xpay_payment_sdk/src/core/presentation/verification/blocs/verification_bloc.dart';
import 'package:xpay_payment_sdk/src/di/di.dart';
import 'package:xpay_payment_sdk/src/shared/business_logger/xp_business_logger.dart';

const _notPending = XPApiException(errorCode: 'verification_not_pending', statusCode: 422);

final _repository = _NotPendingRepository();

final class _NotPendingRepository extends PaymentAuthorizeRepository {
  final List<String> paymentLookups = [];

  int resendCalls = 0;

  Either<XPException, PaymentVerifyEntity> nextPayment = const Left(XPNetworkException.timeout());

  XPException verifyFailure = _notPending;

  @override
  Future<Either<XPException, PaymentAuthorizeEntity>> authorize({
    required String cardToken,
    required PaymentEntryMode entryMode,
    required String amount,
    required String currency,
    required String externalRef,
    required String idempotencyKey,
    PaymentChipTapEntity? chipTap,
    CreatePaymentProductType? productType,
    DateTime? serviceDate,
    String? verificationCode,
    String? merchantId,
    String? mcc,
    String? otpRecipientId,
    bool autoCapture = false,
  }) async => throw UnimplementedError();

  @override
  Future<Either<XPException, PaymentVerifyEntity>> verify({required String authId, required String code, required String idempotencyKey}) async => Left(verifyFailure);

  @override
  Future<Either<XPException, PaymentVerifyEntity>> resendVerification({required String authId, String? recipientId}) async {
    resendCalls++;
    return const Left(XPNetworkException.timeout());
  }

  @override
  Future<Either<XPException, PaymentVerifyEntity>> getPayment(String authId) async {
    paymentLookups.add(authId);
    return nextPayment;
  }
}

Future<VerificationBloc> _submit() async {
  final bloc = VerificationBloc(
    verification: PaymentAuthorizeVerificationEntity(method: PaymentAuthorizeVerificationMethod.smsOtp, verificationDeadline: DateTime.now().add(const Duration(minutes: 5))),
    amount: 138000.0,
    authId: 'auth-1',
  );
  addTearDown(bloc.close);
  bloc.add(const VerificationChangeCodeEvent('123456'));
  bloc.add(const VerificationSubmitEvent());
  await pumpEventQueue();
  return bloc;
}

void main() {
  setUpAll(() {
    getIt.registerSingleton<PaymentAuthorizeRepository>(_repository);
    getIt.registerSingleton(const XPBusinessLogger(null));
  });

  tearDownAll(() => getIt.reset());

  setUp(() {
    _repository.paymentLookups.clear();
    _repository.resendCalls = 0;
    _repository.nextPayment = const Left(XPNetworkException.timeout());
    _repository.verifyFailure = _notPending;
  });

  test('a payment captured meanwhile completes the verification as approved', () async {
    _repository.nextPayment = const Right(PaymentVerifyEntity(status: PaymentAuthorizeStatus.captured, authId: 'auth-1', captureId: 'cap-1'));

    final bloc = await _submit();

    expect(_repository.paymentLookups, ['auth-1']);
    expect(bloc.state, isA<VerificationApprovedState>().having((s) => s.result.captureId, 'captureId', 'cap-1'));
  });

  test('a payment declined meanwhile completes the verification as declined, keeping its reason', () async {
    _repository.nextPayment = Right(PaymentVerifyEntity(status: PaymentAuthorizeStatus.declined, declineReason: PaymentDeclineEntity.fromRemote('insufficient_funds')));

    final bloc = await _submit();

    expect(bloc.state, isA<VerificationDeclinedState>().having((s) => s.result.declineReason?.rawErrorCode, 'declineReason', 'insufficient_funds'));
  });

  test('a payment voided or expired meanwhile ends the verification session', () async {
    for (final status in [PaymentAuthorizeStatus.voided, PaymentAuthorizeStatus.expired]) {
      _repository.nextPayment = Right(PaymentVerifyEntity(status: status));

      final bloc = await _submit();

      expect(bloc.state, isA<VerificationSessionExpiredState>(), reason: status.name);
    }
  });

  test('a payment still pending keeps the merchant on the code screen with the error', () async {
    _repository.nextPayment = const Right(PaymentVerifyEntity(status: PaymentAuthorizeStatus.pendingVerification));

    final bloc = await _submit();

    expect(bloc.state, isA<VerificationErrorState>().having((s) => s.failure?.errorCode, 'errorCode', 'verification_not_pending'));
  });

  test('a lookup that fails hands the failure to the checkout', () async {
    final bloc = await _submit();

    expect(bloc.state, isA<VerificationFailedState>().having((s) => s.errorCode, 'errorCode', 'verification_not_pending'));
  });

  test('other verify errors leave the code screen for the checkout without looking the payment up', () async {
    for (final code in ['internal_error', 'amount_locked', 'ride_already_paid', 'ride_payment_session_revoked']) {
      _repository.verifyFailure = XPApiException(errorCode: code, statusCode: 409);

      final bloc = await _submit();

      expect(bloc.state, isA<VerificationFailedState>().having((s) => s.errorCode, 'errorCode', code), reason: code);
    }
    expect(_repository.paymentLookups, isEmpty);
  });

  test('a recipient the server still needs keeps the merchant on the code screen', () async {
    _repository.verifyFailure = const XPApiException(errorCode: 'otp_recipient_required', statusCode: 422);

    final bloc = await _submit();

    expect(bloc.state, isA<VerificationErrorState>());
  });

  test('an expired code is resent on its own, keeping the authorization', () async {
    _repository.verifyFailure = const XPApiException(errorCode: 'otp_expired', statusCode: 422);

    await _submit();

    expect(_repository.resendCalls, 1);
  });
}

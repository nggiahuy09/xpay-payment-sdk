import 'dart:async';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../api/xpay_log_event.dart';
import '../../../../base/extensions/extensions.dart';
import '../../../../di/di.dart';
import '../../../../shared/business_logger/xp_business_logger.dart';
import '../../../domain/entities/payment_checkout_result_entity.dart';
import '../../../domain/entities/payment_decline_entity.dart';
import '../../../domain/entities/payment_decline_reason.dart';
import '../../../domain/entities/payment_failure_entity.dart';
import '../../../domain/entities/payment_flow_outcome_entity.dart';
import '../../../domain/entities/payment_method_enum.dart';
import '../../../domain/entities/payment_order_entity.dart';
import '../../../domain/entities/ride_payment_status_entity.dart';
import '../../../domain/repositories/ride_payment_repo.dart';
import '../../../domain/usecases/get_ride_payment_status_uc.dart';
import '../../payment/helpers/payment_authorize_idempotency_tracker.dart';

part 'payment_checkout_event.dart';

part 'payment_checkout_state.dart';

final class PaymentCheckoutBloc extends Bloc<PaymentCheckoutEvent, PaymentCheckoutState> {
  PaymentCheckoutBloc({required PaymentOrderEntity order, required PaymentMethod method, required bool canPayByCard})
    : _order = order,
      _method = method,
      _canPayByCard = canPayByCard,
      super(PaymentCheckoutCheckingState(method)) {
    on<_CheckRideEvent>(_checkRideHandler);
    on<_PollHotlineEvent>(_pollHotlineHandler);
    on<_HotlineTimedOutEvent>(_hotlineTimedOutHandler);
    on<PaymentCheckoutOutcomeReportedEvent>(_outcomeReportedHandler);
    on<PaymentCheckoutRetryPressedEvent>(_retryPressedHandler);
    on<PaymentCheckoutBackToPartnerPressedEvent>(_backToPartnerPressedHandler);
    on<PaymentCheckoutHotlineConfirmedEvent>(_hotlineConfirmedHandler);
    on<PaymentCheckoutRetryXpayPressedEvent>(_retryXpayPressedHandler);
    on<PaymentCheckoutOtherMethodPressedEvent>(_otherMethodPressedHandler);
    on<PaymentCheckoutHotlinePayPressedEvent>(_hotlinePayPressedHandler);
    on<PaymentCheckoutHotlineWaitLeftEvent>(_hotlineWaitLeftHandler);
    on<PaymentCheckoutPaidDismissedEvent>(_paidDismissedHandler);
    on<PaymentCheckoutRideClosedDismissedEvent>(_rideClosedDismissedHandler);
    on<PaymentCheckoutCancelledEvent>(_cancelledHandler);
    add(const _CheckRideEvent());
  }

  final _getRidePaymentStatus = GetRidePaymentStatusUseCase(getIt.get<RidePaymentRepository>());
  final _idempotency = getIt.get<PaymentAuthorizeIdempotencyTracker>();
  final _logger = getIt.get<XPBusinessLogger>();

  final PaymentOrderEntity _order;
  final bool _canPayByCard;

  static const int _kRetryInSdkLimit = 3;
  static const int _kMinPollSeconds = 5;
  static const int _kMaxPollSeconds = 15;
  static const int _kPollStepSeconds = 2;

  static const Duration _kHotlineWaitLimit = Duration(minutes: 5);

  static const String _kUnexpectedResponseCode = 'sdk_unexpected_response';

  PaymentFailureEntity? _failure;
  PaymentMethod _method;
  Timer? _hotlineTimer;
  Timer? _pollTimer;
  String? _declinedAuthId;
  String? _pendingAuthId;
  int _attempt = 0;
  int _pollCount = 0;
  int _retryInSdkCount = 0;
  bool _isFinished = false;
  bool _isHostCancelled = false;
  bool _isHotlineWaiting = false;

  PaymentFailureEntity get _trailedFailure =>
      (_failure ?? const PaymentFailureEntity(kind: PaymentFailureKind.systemError)).withTrail(declinedAuthId: _declinedAuthId, pendingAuthId: _pendingAuthId);

  bool get _keepsMethod => _failure?.isResumable ?? false;

  @override
  Future<void> close() {
    _stopHotlineWait();
    return super.close();
  }

  Future<void> _checkRideHandler(_CheckRideEvent event, Emitter<PaymentCheckoutState> emit) async {
    final status = (await _getRidePaymentStatus.execute(null)).getOrNull();
    if (isClosed || _isFinished) return;
    if (status != null && _emitSettled(emit, status)) return;

    emit(PaymentCheckoutCollectingState(method: _method, attempt: _attempt));
  }

  Future<void> _pollHotlineHandler(_PollHotlineEvent event, Emitter<PaymentCheckoutState> emit) async {
    if (_isHotlineWaiting == false || _isFinished) return;

    final status = (await _getRidePaymentStatus.execute(null)).getOrNull();
    if (isClosed || _isFinished || _isHotlineWaiting == false) return;
    if (status != null && _emitSettled(emit, status)) return;

    _schedulePoll();
  }

  void _hotlineTimedOutHandler(_HotlineTimedOutEvent event, Emitter<PaymentCheckoutState> emit) {
    if (_isHotlineWaiting == false) return;

    _finish(emit, PaymentCheckoutHotlinePendingResultEntity(_trailedFailure));
  }

  Future<void> _outcomeReportedHandler(PaymentCheckoutOutcomeReportedEvent event, Emitter<PaymentCheckoutState> emit) async {
    if (_isFinished) return;

    _isHostCancelled = _isHostCancelled || event.isHostCancelled;
    final outcome = event.outcome;
    switch (outcome) {
      case PaymentFlowAuthorizedOutcomeEntity(:final authorize):
        final decline = authorize.declineReason;
        if (authorize.isApproved || authorize.isCaptured) {
          return _emitPaid(
            emit,
            PaymentCheckoutPaymentEntity(
              paidBy: RidePaymentPayer.partner,
              createdAt: authorize.createdAt,
              authId: authorize.authId,
              captureId: authorize.captureId,
              currency: authorize.currency,
              externalRef: authorize.externalRef,
              amount: authorize.amount,
            ),
          );
        }
        if (authorize.isDeclined) return _fail(emit, _declined(decline, authorize.authId));

        return _fail(emit, PaymentFailureEntity(kind: PaymentFailureKind.systemError, authId: authorize.authId, errorCode: _kUnexpectedResponseCode));
      case PaymentFlowVerifiedOutcomeEntity(:final verify):
        final authId = verify.authId ?? outcome.authId;
        if (outcome.result.outcome.isDeclined) return _fail(emit, _declined(verify.declineReason, authId));

        return _emitPaid(
          emit,
          PaymentCheckoutPaymentEntity(
            paidBy: RidePaymentPayer.partner,
            createdAt: verify.createdAt,
            authId: authId,
            captureId: verify.captureId,
            currency: verify.currency,
            externalRef: verify.externalRef,
            amount: verify.amount,
          ),
        );
      case PaymentFlowWalletCapturedOutcomeEntity _:
        return _emitPaid(
          emit,
          PaymentCheckoutPaymentEntity(
            paidBy: RidePaymentPayer.partner,
            createdAt: outcome.createdAt,
            authId: outcome.authId,
            currency: outcome.currency,
            externalRef: outcome.externalRef,
            amount: outcome.amount,
          ),
        );
      case PaymentFlowWalletDeclinedOutcomeEntity _:
        return _fail(emit, const PaymentFailureEntity(kind: PaymentFailureKind.corporatePolicyRejected));
      case PaymentFlowWalletInterruptedOutcomeEntity _:
        return _fail(emit, PaymentFailureEntity(kind: PaymentFailureKind.fromErrorCode(outcome.errorCode), errorCode: outcome.errorCode, isResumable: true));
      case PaymentFlowExpiredOutcomeEntity _:
        return _fail(emit, const PaymentFailureEntity(kind: PaymentFailureKind.verificationExpired));
      case PaymentFlowQrExpiredOutcomeEntity _:
        return _fail(emit, const PaymentFailureEntity(kind: PaymentFailureKind.qrExpired));
      case PaymentFlowCancelledOutcomeEntity _ when _isHotlineWaiting:
        return _finish(emit, PaymentCheckoutHotlinePendingResultEntity(_trailedFailure));
      case PaymentFlowCancelledOutcomeEntity _:
        return _finish(emit, PaymentCheckoutCancelledResultEntity(outcome.authId ?? _pendingAuthId));
      case PaymentFlowConflictOutcomeEntity _:
        return _fail(
          emit,
          PaymentFailureEntity(kind: PaymentFailureKind.fromConflictCode(outcome.errorCode), errorCode: outcome.errorCode, pendingAuthId: outcome.pendingAuthId),
        );
      case PaymentFlowFailedOutcomeEntity _:
        return _fail(
          emit,
          PaymentFailureEntity(kind: PaymentFailureKind.fromErrorCode(outcome.errorCode), errorCode: outcome.errorCode, pendingAuthId: outcome.pendingAuthId),
        );
    }
  }

  void _retryPressedHandler(PaymentCheckoutRetryPressedEvent event, Emitter<PaymentCheckoutState> emit) {
    if (_isFinished) return;

    _releaseSettledAuthorization();
    _attempt++;
    emit(PaymentCheckoutCollectingState(method: _method, attempt: _attempt));
  }

  void _backToPartnerPressedHandler(PaymentCheckoutBackToPartnerPressedEvent event, Emitter<PaymentCheckoutState> emit) {
    _finish(emit, PaymentCheckoutRetryInPartnerResultEntity(_trailedFailure));
  }

  void _hotlineConfirmedHandler(PaymentCheckoutHotlineConfirmedEvent event, Emitter<PaymentCheckoutState> emit) {
    if (_isFinished) return;

    emit(PaymentCheckoutOptionsState(method: _method, attempt: _attempt, keepsMethod: _keepsMethod));
  }

  void _retryXpayPressedHandler(PaymentCheckoutRetryXpayPressedEvent event, Emitter<PaymentCheckoutState> emit) {
    if (_isFinished) return;

    _retryInSdkCount = 0;
    _releaseSettledAuthorization();
    if (_keepsMethod == false) _attempt++;
    emit(PaymentCheckoutCollectingState(method: _method, attempt: _attempt));
  }

  void _otherMethodPressedHandler(PaymentCheckoutOtherMethodPressedEvent event, Emitter<PaymentCheckoutState> emit) {
    _finish(emit, PaymentCheckoutOtherMethodResultEntity(_trailedFailure));
  }

  void _hotlinePayPressedHandler(PaymentCheckoutHotlinePayPressedEvent event, Emitter<PaymentCheckoutState> emit) {
    if (_isFinished) return;

    _stopHotlineWait();
    _isHotlineWaiting = true;
    _pollCount = 0;
    _hotlineTimer = Timer(_kHotlineWaitLimit, () => maybeAdd(const _HotlineTimedOutEvent()));
    emit(PaymentCheckoutHotlineWaitingState(method: _method, attempt: _attempt, keepsMethod: _keepsMethod, deadline: DateTime.now().add(_kHotlineWaitLimit)));
    _schedulePoll();
  }

  void _hotlineWaitLeftHandler(PaymentCheckoutHotlineWaitLeftEvent event, Emitter<PaymentCheckoutState> emit) {
    _finish(emit, PaymentCheckoutHotlinePendingResultEntity(_trailedFailure));
  }

  void _paidDismissedHandler(PaymentCheckoutPaidDismissedEvent event, Emitter<PaymentCheckoutState> emit) {
    _finish(emit, PaymentCheckoutPaidResultEntity(event.payment));
  }

  void _rideClosedDismissedHandler(PaymentCheckoutRideClosedDismissedEvent event, Emitter<PaymentCheckoutState> emit) {
    _finish(emit, PaymentCheckoutRideClosedResultEntity(event.settlement));
  }

  void _cancelledHandler(PaymentCheckoutCancelledEvent event, Emitter<PaymentCheckoutState> emit) {
    _finish(emit, PaymentCheckoutCancelledResultEntity(event.pendingAuthId ?? _pendingAuthId));
  }

  Future<void> _fail(Emitter<PaymentCheckoutState> emit, PaymentFailureEntity failure) async {
    _declinedAuthId = failure.authId ?? _declinedAuthId;
    _pendingAuthId = failure.pendingAuthId ?? _pendingAuthId;
    _logFailure(failure);

    switch (failure.route) {
      case PaymentFailureRoute.switchMethod:
        final method = _getSwitchedMethod(failure.kind);
        if (method == null) return _fail(emit, PaymentFailureEntity(kind: PaymentFailureKind.integrationError, errorCode: failure.errorCode));
        if (_isHostCancelled) return _finish(emit, PaymentCheckoutCancelledResultEntity(_pendingAuthId));

        _method = method;
        _attempt++;
        emit(PaymentCheckoutCollectingState(method: _method, attempt: _attempt));
        break;
      case PaymentFailureRoute.checkRide:
        emit(PaymentCheckoutSettlingState(method: _method, attempt: _attempt));
        final status = (await _getRidePaymentStatus.execute(null)).getOrNull();
        if (isClosed || _isFinished) return;
        if (status != null && _emitSettled(emit, status)) return;

        _showFailure(emit, PaymentFailureEntity(kind: PaymentFailureKind.systemError, errorCode: failure.errorCode, pendingAuthId: failure.pendingAuthId));
        break;
      case PaymentFailureRoute.retryInSdk:
        _retryInSdkCount++;
        _showFailure(emit, _retryInSdkCount >= _kRetryInSdkLimit ? failure.toRetriesExhausted() : failure);
        break;
      case PaymentFailureRoute.retryInPartner:
      case PaymentFailureRoute.callHotline:
        _showFailure(emit, failure);
        break;
    }
  }

  void _showFailure(Emitter<PaymentCheckoutState> emit, PaymentFailureEntity failure) {
    _failure = failure;
    if (_isHostCancelled) return _finish(emit, PaymentCheckoutCancelledResultEntity(_pendingAuthId));

    emit(PaymentCheckoutFailedState(method: _method, attempt: _attempt, failure: failure));
  }

  void _emitPaid(Emitter<PaymentCheckoutState> emit, PaymentCheckoutPaymentEntity payment) {
    _stopHotlineWait();
    if (_isHostCancelled) return _finish(emit, PaymentCheckoutPaidResultEntity(payment));

    emit(PaymentCheckoutPaidState(method: _method, attempt: _attempt, payment: payment));
  }

  bool _emitSettled(Emitter<PaymentCheckoutState> emit, RidePaymentStatusEntity status) {
    final payment = status.payment;
    if (payment != null) {
      _emitPaid(
        emit,
        PaymentCheckoutPaymentEntity(
          paidBy: payment.paidBy,
          authId: payment.authId,
          currency: _order.currency,
          externalRef: status.externalRef.isEmpty ? _order.externalRef : status.externalRef,
          amount: payment.amount,
        ),
      );
      return true;
    }

    final settlement = status.settlement;
    if (settlement.isSettled == false) return false;

    _stopHotlineWait();
    if (_isHostCancelled) {
      _finish(emit, PaymentCheckoutRideClosedResultEntity(settlement));
    } else {
      emit(PaymentCheckoutRideClosedState(method: _method, attempt: _attempt, settlement: settlement));
    }
    return true;
  }

  void _finish(Emitter<PaymentCheckoutState> emit, PaymentCheckoutResultEntity result) {
    if (_isFinished) return;

    _isFinished = true;
    _stopHotlineWait();
    emit(PaymentCheckoutClosedState(method: _method, attempt: _attempt, result: result));
  }

  void _releaseSettledAuthorization() {
    if (_failure?.reason != PaymentFailureReason.sdkError) _idempotency.release();
  }

  void _schedulePoll() {
    final seconds = math.min(_kMinPollSeconds + _pollCount * _kPollStepSeconds, _kMaxPollSeconds);
    _pollCount++;
    _pollTimer?.cancel();
    _pollTimer = Timer(Duration(seconds: seconds), () => maybeAdd(const _PollHotlineEvent()));
  }

  void _stopHotlineWait() {
    _isHotlineWaiting = false;
    _hotlineTimer?.cancel();
    _hotlineTimer = null;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  PaymentMethod? _getSwitchedMethod(PaymentFailureKind kind) => switch (kind) {
    PaymentFailureKind.rideOnCorporateWallet => PaymentMethod.corporateWallet,
    PaymentFailureKind.rideNotOnCorporateWallet when _canPayByCard => PaymentMethod.card,
    _ => null,
  };

  PaymentFailureEntity _declined(PaymentDeclineEntity? decline, String? authId) => PaymentFailureEntity(
    kind: PaymentFailureKind.fromDecline(decline?.reason),
    authId: authId,
    detail: decline?.reason == PaymentDeclineReason.unknown ? decline?.rawErrorCode : null,
    errorCode: decline?.rawErrorCode,
  );

  void _logFailure(PaymentFailureEntity failure) {
    _logger.logBusiness(
      input: {
        'route': failure.route.name,
        'kind': failure.kind.name,
        'error_code': failure.errorCode,
        'auth_id': failure.authId,
        'attempt': _attempt,
        'retry_in_sdk_count': _retryInSdkCount,
      },
      category: XPayLogCategory.behavior,
      level: XPayLogLevel.warn,
      action: 'checkout_failure',
      feature: 'payment',
      reason: failure.kind.name,
    );
  }
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../api/xpay_log_event.dart';
import '../../../../../base/domain/domain.dart';
import '../../../../../base/extensions/extensions.dart';
import '../../../../../core/domain/entities/payment_order_entity.dart';
import '../../../../../di/di.dart';
import '../../../../../shared/business_logger/xp_business_logger.dart';
import '../../../../../shared/helpers/helpers.dart';
import '../../../domain/entities/payment_intent_entity.dart';
import '../../../domain/entities/payment_intent_status_enum.dart';
import '../../../domain/repositories/corporate_wallet_repo.dart';
import '../../../domain/usecases/cancel_payment_intent_uc.dart';
import '../../../domain/usecases/create_payment_intent_uc.dart';
import '../../../domain/usecases/get_payment_intent_uc.dart';

part 'payment_intent_event.dart';

part 'payment_intent_state.dart';

final class PaymentIntentBloc extends Bloc<PaymentIntentEvent, PaymentIntentState> {
  PaymentIntentBloc({required PaymentOrderEntity order}) : _order = order, super(const PaymentIntentInitState()) {
    on<PaymentIntentCreateEvent>(_createHandler);
    on<PaymentIntentCancelEvent>(_cancelHandler);
    on<_PaymentIntentPollEvent>(_pollHandler);
  }

  static const Duration _pollInterval = Duration(seconds: 3);

  final _cancelIntent = CancelPaymentIntentUseCase(getIt.get<CorporateWalletRepository>());
  final _createIntent = CreatePaymentIntentUseCase(getIt.get<CorporateWalletRepository>());
  final _getIntent = GetPaymentIntentUseCase(getIt.get<CorporateWalletRepository>());
  final _logger = getIt.get<XPBusinessLogger>();

  final PaymentOrderEntity _order;

  Timer? _pollTimer;
  String? _intentId;
  bool _isCancelRequested = false;
  bool _isCreating = false;

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }

  Future<void> _createHandler(PaymentIntentCreateEvent event, Emitter<PaymentIntentState> emit) async {
    if (_isCreating || _intentId != null) return;

    _isCreating = true;
    _isCancelRequested = false;
    emit(const PaymentIntentCreateLoadingState());

    final order = _order;
    final input = CreatePaymentIntentInput(
      productType: order.productType,
      currency: order.currency,
      externalRef: order.externalRef,
      idempotencyKey: XPHelperCryptography.generateUuidV4(),
      amount: order.amount,
    );
    final result = await _createIntent.execute(input);
    _isCreating = false;
    if (isClosed) return;

    switch (result) {
      case Left(value: final failure):
        if (_isCancelRequested) {
          _isCancelRequested = false;
          emit(const PaymentIntentCancelledState());
          return;
        }

        _logger.logBusiness(input: input.toLog(), exception: failure, action: 'create_intent', feature: 'corporate_wallet');
        if (failure.isSessionRejected) {
          emit(PaymentIntentFailedState(errorCode: failure.errorCode, errorMessage: failure.displayMessage, isSessionExpired: false));
          return;
        }

        emit(PaymentIntentCreateErrorState(errorCode: failure.errorCode, errorMessage: failure.displayMessage));
      case Right(value: final intent):
        _intentId = intent.intentId;
        if (_isCancelRequested) return _cancel(emit, intent.intentId);

        _emitIntent(emit, intent);
    }
  }

  Future<void> _cancelHandler(PaymentIntentCancelEvent event, Emitter<PaymentIntentState> emit) async {
    _isCancelRequested = true;
    _stopPolling();
    if (_isCreating) {
      emit(const PaymentIntentCancelLoadingState());
      return;
    }

    final intentId = _intentId;
    if (intentId == null) {
      _isCancelRequested = false;
      emit(const PaymentIntentCancelledState());
      return;
    }

    await _cancel(emit, intentId);
  }

  Future<void> _pollHandler(_PaymentIntentPollEvent event, Emitter<PaymentIntentState> emit) async {
    if (_isCancelRequested || _intentId != event.intentId) return;

    final result = await _getIntent.execute(event.intentId);
    if (isClosed || _isCancelRequested || _intentId != event.intentId) return;

    switch (result) {
      case Left(value: final failure) when _isTransient(failure):
        _schedulePoll(event.intentId);
      case Left(value: final failure):
        _intentId = null;
        _logger.logBusiness(input: {'intent_id': event.intentId}, exception: failure, action: 'poll_intent', feature: 'corporate_wallet');
        emit(PaymentIntentFailedState(errorCode: failure.errorCode, errorMessage: failure.displayMessage, isSessionExpired: failure is XPUnauthorizedException));
      case Right(value: final intent):
        _emitIntent(emit, intent);
    }
  }

  bool _isTransient(XPException failure) => failure.isNetworkError || (failure is XPApiException && (failure.statusCode ?? 0) >= 500);

  Future<void> _cancel(Emitter<PaymentIntentState> emit, String intentId) async {
    emit(const PaymentIntentCancelLoadingState());

    final result = await _cancelIntent.execute(intentId);
    if (isClosed) return;

    final cancelFailure = result.getLeftOrNull();
    var intent = result.getOrNull();
    if (intent == null) {
      _logger.logBusiness(input: {'intent_id': intentId}, exception: cancelFailure, action: 'cancel_intent', feature: 'corporate_wallet');
      intent = (await _getIntent.execute(intentId)).getOrNull();
      if (isClosed) return;
    }

    _isCancelRequested = false;
    if (intent == null || intent.status.isPending) {
      _logger.logBusiness(input: {'intent_id': intentId}, action: 'cancel_intent', feature: 'corporate_wallet', reason: 'cancel_unconfirmed');
      emit(PaymentIntentCancelErrorState(intent: intent, errorCode: cancelFailure?.errorCode, errorMessage: cancelFailure?.displayMessage));
      _schedulePoll(intentId);
      return;
    }

    _intentId = null;
    if (intent.status == PaymentIntentStatus.captured) {
      _logCaptured(intent);
      emit(PaymentIntentCapturedState(intent));
      return;
    }

    emit(const PaymentIntentCancelledState());
  }

  void _emitIntent(Emitter<PaymentIntentState> emit, PaymentIntentEntity intent) {
    switch (intent.status) {
      case PaymentIntentStatus.requiresConfirmation:
      case PaymentIntentStatus.unknown:
        emit(PaymentIntentPendingState(intent));
        _schedulePoll(intent.intentId);
      case PaymentIntentStatus.captured:
        _intentId = null;
        _logCaptured(intent);
        emit(PaymentIntentCapturedState(intent));
      case PaymentIntentStatus.declined:
      case PaymentIntentStatus.canceled:
      case PaymentIntentStatus.expired:
        _intentId = null;
        _logger.logBusiness(
          input: {'intent_id': intent.intentId},
          level: XPayLogLevel.warn,
          action: 'intent_ended',
          feature: 'corporate_wallet',
          reason: intent.status.name,
        );
        emit(PaymentIntentEndedState(intent));
    }
  }

  void _logCaptured(PaymentIntentEntity intent) {
    _logger.logBusiness(input: {'intent_id': intent.intentId}, level: XPayLogLevel.info, action: 'intent_captured', feature: 'corporate_wallet');
  }

  void _schedulePoll(String intentId) {
    _pollTimer?.cancel();
    _pollTimer = Timer(_pollInterval, () => maybeAdd(_PaymentIntentPollEvent(intentId)));
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}

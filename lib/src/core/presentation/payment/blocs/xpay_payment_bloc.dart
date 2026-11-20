import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../api/xpay_log_event.dart';
import '../../../../di/di.dart';
import '../../../../shared/business_logger/xp_business_logger.dart';
import '../../../domain/entities/create_payment_authorize_failure_reason_enum.dart';
import '../../../domain/entities/payment_authorize_entity.dart';
import '../../../domain/entities/payment_chip_tap_entity.dart';
import '../../../domain/entities/payment_entry_mode_enum.dart';
import '../../../domain/entities/payment_order_entity.dart';
import '../../../domain/entities/xpay_qr_prefix.dart';
import '../../../domain/repositories/payment_authorize_repo.dart';
import '../../../domain/usecases/authorize_payment_uc.dart';
import '../helpers/payment_authorize_idempotency_tracker.dart';

part 'xpay_payment_event.dart';

part 'xpay_payment_state.dart';

final class XPayPaymentBloc extends Bloc<XPayPaymentEvent, XPayPaymentState> {
  XPayPaymentBloc({required PaymentOrderEntity order}) : _order = order, super(const XPayPaymentInitState()) {
    on<XPayQrScannedEvent>(_qrScannedHandler);
    on<XPayPanEnteredEvent>(_panEnteredHandler);
    on<XPayCardTappedEvent>(_cardTappedHandler);
    on<XPayRideCardChargedEvent>(_rideCardChargedHandler);
  }

  final _authorizePayment = AuthorizePaymentUseCase(getIt.get<PaymentAuthorizeRepository>());
  final _idempotency = getIt.get<PaymentAuthorizeIdempotencyTracker>();
  final _logger = getIt.get<XPBusinessLogger>();

  final PaymentOrderEntity _order;

  int _authorizeAttempt = 0;

  bool _isAuthorizing = false;

  Future<void> _authorize(
    Emitter<XPayPaymentState> emit, {
    required PaymentChipTapEntity? chipTap,
    required PaymentEntryMode entryMode,
    required String action,
    required String cardToken,
  }) async {
    final order = _order;
    final signature = jsonEncode([cardToken, entryMode.toRemote(), order.idempotencySignature, chipTap?.idempotencySignature]);
    final idempotencyKey = _idempotency.start(signature);

    _authorizeAttempt++;
    _isAuthorizing = true;

    emit(XPayPaymentAuthorizingState(_authorizeAttempt));

    final input = AuthorizePaymentInput(
      cardToken: cardToken,
      entryMode: entryMode,
      amount: order.amount.toString(),
      currency: order.currency,
      externalRef: order.externalRef,
      idempotencyKey: idempotencyKey,
      chipTap: chipTap,
      productType: order.productType,
      serviceDate: order.serviceDate,
      autoCapture: entryMode.autoCapture,
    );
    final result = await _authorizePayment.execute(input);
    _isAuthorizing = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        _logger.logBusiness(input: input.toLog(), exception: failure, action: action, feature: 'payment');
        if (failure.isConflict) {
          _idempotency.release();
          emit(XPayPaymentAuthorizeConflictState(_authorizeAttempt));
          return;
        }

        emit(XPayPaymentAuthorizeErrorState(entryMode: entryMode, displayMessage: failure.displayMessage, errorCode: failure.errorCode, attempt: _authorizeAttempt));
      },
      (authorize) {
        _logAuthorizeOutcome(authorize, entryMode);
        emit(XPayPaymentAuthorizeDoneState(authorize: authorize, entryMode: entryMode));
      },
    );
  }

  void _logAuthorizeOutcome(PaymentAuthorizeEntity authorize, PaymentEntryMode entryMode) {
    final String action;
    final XPayLogLevel level;
    final XPayLogCategory category;
    final Map<String, dynamic> input = {'entry_mode': entryMode.name};

    if (authorize.isApproved || authorize.isCaptured) {
      action = 'authorize_approved';
      level = XPayLogLevel.info;
      category = XPayLogCategory.api;
      input['auth_id'] = authorize.authId;
    } else if (authorize.isDeclined) {
      action = 'authorize_declined';
      level = XPayLogLevel.warn;
      category = XPayLogCategory.api;
      input['decline_reason'] = authorize.declineReason?.reason.name;
    } else if (authorize.canPresentVerification) {
      action = 'authorize_verification';
      level = XPayLogLevel.info;
      category = XPayLogCategory.api;
      input['auth_id'] = authorize.authId;
      input['verification_method'] = authorize.verification?.method.name;
    } else {
      action = 'authorize_incomplete';
      level = XPayLogLevel.error;
      category = XPayLogCategory.error;
    }

    _logger.logBusiness(input: input, category: category, level: level, action: action, feature: 'payment');
  }

  Future<void> _qrScannedHandler(XPayQrScannedEvent event, Emitter<XPayPaymentState> emit) async {
    if (_isAuthorizing) return;

    final prefix = XpayQrPrefix.resolve(event.rawValue);
    if (prefix == null || prefix != event.prefix) {
      emit(const XPayPaymentInvalidQrState());
      return;
    }

    await _authorize(emit, chipTap: null, entryMode: prefix.toEntryMode(), action: 'authorize_qr', cardToken: prefix.extractToken(event.rawValue));
  }

  Future<void> _panEnteredHandler(XPayPanEnteredEvent event, Emitter<XPayPaymentState> emit) async {
    if (_isAuthorizing) return;

    await _authorize(emit, chipTap: null, entryMode: PaymentEntryMode.manualPan, action: 'authorize_manual', cardToken: event.pan);
  }

  Future<void> _cardTappedHandler(XPayCardTappedEvent event, Emitter<XPayPaymentState> emit) async {
    if (_isAuthorizing) return;

    await _authorize(emit, chipTap: event.chipTap, entryMode: PaymentEntryMode.chipTap, action: 'authorize_chip_tap', cardToken: event.cardToken.toLowerCase());
  }

  Future<void> _rideCardChargedHandler(XPayRideCardChargedEvent event, Emitter<XPayPaymentState> emit) async {
    if (_isAuthorizing) return;

    await _authorize(emit, chipTap: null, entryMode: PaymentEntryMode.rideCard, action: 'authorize_ride_card', cardToken: event.cardToken);
  }
}

extension on XpayQrPrefix {
  PaymentEntryMode toEntryMode() => switch (this) {
    XpayQrPrefix.xpCard => PaymentEntryMode.cardQr,
    XpayQrPrefix.xTok => PaymentEntryMode.token,
  };
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../base/define/logging/logger.dart';
import '../base/gateway/api/xp_token_provider.dart';
import '../base/localization/localization.dart';
import '../core/domain/entities/payment_entry_mode_enum.dart';
import '../core/domain/entities/payment_flow_outcome_entity.dart';
import '../core/domain/entities/payment_request_reject_reason_enum.dart';
import '../core/domain/entities/payment_session_entity.dart';
import '../core/presentation/payment/views/xpay_payment_page.dart';
import '../di/di.dart';
import '../shared/business_logger/xp_business_logger.dart';
import '../shared/helpers/helper_nfc.dart';
import 'mappers/xpay_payment_request_mapper.dart';
import 'mappers/xpay_payment_result_mapper.dart';
import 'xpay_config.dart';
import 'xpay_log_event.dart';
import 'xpay_payment_request.dart';
import 'xpay_payment_result.dart';

abstract final class XPayPayment {
  static final _XPaySessionTokenProvider _sessionTokenProvider = _XPaySessionTokenProvider();
  static bool _isInitialized = false;
  static bool _isInitializing = false;
  static bool _isRunning = false;

  static bool get _isMobile => defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

  static Future<void> initialize(XPayConfig config) async {
    if (_isRunning) throw StateError('XPayPayment.initialize cannot be called while a payment is open. Wait for XPayPayment.start to return first.');
    if (_isInitializing) throw StateError('XPayPayment.initialize is already running. Await the previous call before calling it again.');

    _isInitializing = true;
    _isInitialized = false;
    try {
      await initializeDateFormatting();
      XPLocalization.instance.changeLocale(config.language.toLocale());
      await configureDependencies(tokenProvider: _sessionTokenProvider, baseUrl: config.environment.baseUrl, onLog: config.onLog);
      _isInitialized = true;
    } finally {
      _isInitializing = false;
    }
  }

  static Future<XPayPaymentResult> start(BuildContext context, XPayPaymentRequest request) async {
    if (_isInitialized == false) return _resolve(const PaymentFlowFailedOutcomeEntity(errorCode: XPayErrorCode.notInitialized));
    if (_isRunning) return _resolve(const PaymentFlowFailedOutcomeEntity(errorCode: XPayErrorCode.busy));

    final PaymentSessionEntity session;
    switch (request.toSession()) {
      case Left(value: final reason):
        _logRejectedRequest(request, reason);
        return _resolve(const PaymentFlowFailedOutcomeEntity(errorCode: XPayErrorCode.invalidRequest));
      case Right(:final value):
        session = value;
    }

    _isRunning = true;
    _sessionTokenProvider.open(session.sessionToken);
    try {
      final isCorporateWallet = session.method.isCorporateWallet;
      final entryModes = isCorporateWallet ? session.entryModes : await _resolveSupportedEntryModes(session.entryModes);
      if (entryModes.isEmpty && !isCorporateWallet) return _resolve(const PaymentFlowUnsupportedOutcomeEntity());
      if (context.mounted == false) return _resolve(const PaymentFlowCancelledOutcomeEntity());

      final route = MaterialPageRoute<PaymentFlowOutcomeEntity>(
        builder: (_) => XPayPaymentPage(entryModes: entryModes, session: session),
      );
      final outcome = await Navigator.of(context, rootNavigator: true).push(route);
      return _resolve(outcome ?? const PaymentFlowCancelledOutcomeEntity());
    } finally {
      _sessionTokenProvider.close();
      _isRunning = false;
    }
  }

  // TODO(sdk-nfc): Also require the `com.nxp.mifare` system feature once the SDK ships native code, so a handset whose NFC controller cannot run Crypto1 is ruled out before the tap screen opens.
  static Future<List<PaymentEntryMode>> _resolveSupportedEntryModes(List<PaymentEntryMode> entryModes) async {
    if (_isMobile == false) return const [];
    if (entryModes.contains(PaymentEntryMode.chipTap) == false) return entryModes;

    final canTapCard = defaultTargetPlatform == TargetPlatform.android && await _isNfcSupported();
    return entryModes.where((mode) => mode != PaymentEntryMode.chipTap || canTapCard).toList();
  }

  static Future<bool> _isNfcSupported() async {
    try {
      return await XPHelperNfc.isSupported();
    } catch (e, stackTrace) {
      XPLogger.error(error: e, stackTrace: stackTrace, message: 'NFC availability check failed, leaving chip tap out of the method list');
      return false;
    }
  }

  static void _logRejectedRequest(XPayPaymentRequest request, PaymentRequestRejectReason reason) {
    getIt.get<XPBusinessLogger>().logBusiness(
      input: {'session_json_length': request.sessionJson.length},
      category: XPayLogCategory.error,
      action: 'start_payment',
      feature: 'payment',
      reason: reason.code,
    );
  }

  static XPayPaymentResult _resolve(PaymentFlowOutcomeEntity outcome) {
    return outcome.toResult(XPLocalization.instance.locale, canTapCard: defaultTargetPlatform == TargetPlatform.android);
  }
}

final class _XPaySessionTokenProvider implements XPTokenProvider {
  String? _sessionToken;

  @override
  Future<String?> getSessionToken() async => _sessionToken;

  void open(String sessionToken) => _sessionToken = sessionToken;

  void close() => _sessionToken = null;
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../base/define/constant/constant.dart';
import '../base/define/logging/logger.dart';
import '../base/extensions/extensions.dart';
import '../base/gateway/api/xp_token_provider.dart';
import '../base/localization/localization.dart';
import '../core/domain/entities/payment_checkout_result_entity.dart';
import '../core/domain/entities/payment_entry_mode_enum.dart';
import '../core/domain/entities/payment_request_reject_reason_enum.dart';
import '../core/domain/entities/payment_session_entity.dart';
import '../core/presentation/checkout/views/payment_checkout_page.dart';
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
  static const String supportHotline = XPSupportConstant.hotline;

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
    if (_isInitialized == false) return const PaymentCheckoutUnavailableResultEntity(XPayErrorCode.notInitialized).toResult();
    if (_isRunning) return const PaymentCheckoutUnavailableResultEntity(XPayErrorCode.busy).toResult();

    final PaymentSessionEntity session;
    switch (request.toSession()) {
      case Left(value: final reason):
        _logRejectedRequest(request, reason);
        return const PaymentCheckoutUnavailableResultEntity(XPayErrorCode.invalidRequest).toResult();
      case Right(:final value):
        session = value;
    }

    _isRunning = true;
    _sessionTokenProvider.open(session, request.fetchSession);
    try {
      final entryModes = await _resolveSupportedEntryModes(session.entryModes);
      if (entryModes.isEmpty && session.method.isCorporateWallet == false) return const PaymentCheckoutUnavailableResultEntity(XPayErrorCode.unsupported).toResult();
      if (context.mounted == false) return const PaymentCheckoutCancelledResultEntity().toResult();

      final route = MaterialPageRoute<PaymentCheckoutResultEntity>(
        builder: (_) => PaymentCheckoutPage(entryModes: entryModes, session: session),
      );
      final result = await Navigator.of(context, rootNavigator: true).push(route);
      return (result ?? const PaymentCheckoutCancelledResultEntity()).toResult();
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
}

final class _XPaySessionTokenProvider implements XPTokenProvider {
  static const Duration _kFetchSessionTimeout = Duration(seconds: 15);

  Future<XPSessionRenewal>? _renewal;
  PaymentSessionEntity? _session;
  String? _sessionToken;
  Future<String> Function()? _fetchSession;

  @override
  Future<String?> getSessionToken() async => _sessionToken;

  @override
  Future<XPSessionRenewal> renewSessionToken() => _renewal ??= _renew().whenComplete(() => _renewal = null);

  void open(PaymentSessionEntity session, Future<String> Function()? fetchSession) {
    _session = session;
    _sessionToken = session.sessionToken;
    _fetchSession = fetchSession;
  }

  void close() {
    _session = null;
    _sessionToken = null;
    _fetchSession = null;
  }

  Future<XPSessionRenewal> _renew() async {
    final session = _session;
    final fetchSession = _fetchSession;
    if (session == null || fetchSession == null) return XPSessionRenewal.failed;

    try {
      final renewed = XPayPaymentRequest.fromSession(await fetchSession.call().timeout(_kFetchSessionTimeout)).toSession().getOrNull();
      if (_session != session) return XPSessionRenewal.failed;
      if (renewed == null || renewed.order.externalRef != session.order.externalRef) {
        XPLogger.warning('fetchSession returned no session of this ride, keeping the expired one', name: 'XPayPayment');
        return XPSessionRenewal.failed;
      }
      if (renewed.order.amount != session.order.amount) return XPSessionRenewal.amountChanged;

      _sessionToken = renewed.sessionToken;
      return XPSessionRenewal.renewed;
    } catch (e, stackTrace) {
      XPLogger.error(error: e, stackTrace: stackTrace, message: 'fetchSession failed, the payment session cannot be renewed');
      return XPSessionRenewal.failed;
    }
  }
}

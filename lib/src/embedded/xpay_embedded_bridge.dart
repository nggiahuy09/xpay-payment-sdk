import 'dart:async';

import 'package:flutter/widgets.dart';

import '../api/xpay_config.dart';
import '../api/xpay_log_event.dart';
import '../api/xpay_payment.dart';
import '../api/xpay_payment_result.dart';
import '../core/presentation/payment/helpers/payment_host_cancellation.dart';
import '../di/di.dart';
import '../shared/loading/loading.dart';
import 'mappers/xpay_embedded_message_mapper.dart';
import 'xpay_embedded_api.g.dart';

final class XPayEmbeddedBridge extends NavigatorObserver implements XPayEmbeddedFlutterApi {
  XPayEmbeddedBridge(this._navigatorKey, this._hostApi);

  final GlobalKey<NavigatorState> _navigatorKey;
  final XPayEmbeddedHostApi _hostApi;

  final Set<int> _cancelledGenerations = {};
  final Set<int> _pendingGenerations = {};
  int? _runningGeneration;
  int _generation = 0;

  @override
  Future<void> initialize(XPayEmbeddedConfigMessage config) => XPayPayment.initialize(
    XPayConfig(
      environment: XPayEnvironment(baseUrl: config.baseUrl),
      language: config.language.toLanguage(),
      onLog: _onLog,
    ),
  );

  @override
  Future<XPayEmbeddedResultMessage> start(XPayEmbeddedRequestMessage request) async {
    final generation = ++_generation;
    _pendingGenerations.add(generation);
    try {
      if (_navigatorKey.currentContext == null) await WidgetsBinding.instance.endOfFrame;

      final context = _navigatorKey.currentContext;
      if (_cancelledGenerations.contains(generation) || context == null || context.mounted == false) {
        return const XPayPaymentResult(status: XPayPaymentStatus.cancelled).toMessage();
      }

      _runningGeneration ??= generation;
      final result = await XPayPayment.start(context, request.toRequest(_hostApi));
      return result.toMessage();
    } finally {
      _pendingGenerations.remove(generation);
      _cancelledGenerations.remove(generation);
      if (_runningGeneration == generation) _runningGeneration = null;
    }
  }

  @override
  Future<void> cancel() async {
    if (_pendingGenerations.contains(_generation)) _cancelledGenerations.add(_generation);
    if (getIt.isRegistered<PaymentHostCancellation>() && getIt.get<PaymentHostCancellation>().request()) return;

    XPLoadingManager.hideDefaultOverlay();
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final runningGeneration = _runningGeneration;
    if (previousRoute == null || runningGeneration == null || _cancelledGenerations.contains(runningGeneration) == false) return;

    scheduleMicrotask(() => _removeIfActive(route));
  }

  void _removeIfActive(Route<dynamic> route) {
    if (route.isActive) route.navigator?.removeRoute(route);
  }

  void _onLog(XPayLogEvent event) => _hostApi.onLog(event.toMessage()).ignore();
}

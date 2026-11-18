import 'package:flutter/material.dart';
import 'package:xpay_payment_sdk/xpay_payment_sdk.dart';

import 'xpay_demo_widgets.dart';

final class XPayDemoPage extends StatefulWidget {
  const XPayDemoPage({super.key});

  @override
  State<XPayDemoPage> createState() => _XPayDemoPageState();
}

final class _XPayDemoPageState extends State<XPayDemoPage> {
  static const int _maxLogEvents = 30;

  final List<XPayLogEvent> _logEvents = [];
  final TextEditingController _baseUrlController = TextEditingController(text: const String.fromEnvironment('XPAY_BASE_URL'));
  final TextEditingController _sessionJsonController = TextEditingController(text: const String.fromEnvironment('XPAY_SESSION_JSON'));

  XPayPaymentResult? _lastResult;
  XPayLanguage _language = XPayLanguage.vi;
  String? _appliedConfigSignature;
  bool _isPaying = false;

  String get _configSignature => '${_baseUrlController.text.trim()}|${_language.name}';

  @override
  void dispose() {
    _baseUrlController.dispose();
    _sessionJsonController.dispose();
    super.dispose();
  }

  Future<void> _applyConfigIfChanged() async {
    final signature = _configSignature;
    if (signature == _appliedConfigSignature) return;

    await XPayPayment.initialize(
      XPayConfig(
        environment: XPayEnvironment(baseUrl: _baseUrlController.text.trim()),
        language: _language,
        onLog: _handleLog,
      ),
    );
    _appliedConfigSignature = signature;
  }

  void _handleLog(XPayLogEvent event) {
    if (mounted == false) return;

    setState(() {
      _logEvents.insert(0, event);
      if (_logEvents.length > _maxLogEvents) _logEvents.removeLast();
    });
  }

  Future<void> _handlePay() async {
    setState(() => _isPaying = true);
    await _applyConfigIfChanged();
    if (mounted == false) return;

    final result = await XPayPayment.start(context, XPayPaymentRequest.fromSession(_sessionJsonController.text));
    if (mounted == false) return;

    setState(() {
      _isPaying = false;
      _lastResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lastResult = _lastResult;

    return Scaffold(
      appBar: AppBar(title: const Text('XPay SDK Demo')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const XPayDemoSectionTitle('Environment'),
            TextField(
              controller: _baseUrlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Base URL', hintText: 'https://sandbox-api.example.com'),
            ),
            const SizedBox(height: 12.0),
            SegmentedButton<XPayLanguage>(
              segments: const [
                ButtonSegment(value: XPayLanguage.vi, label: Text('Tiếng Việt')),
                ButtonSegment(value: XPayLanguage.en, label: Text('English')),
              ],
              selected: {_language},
              onSelectionChanged: (selection) => setState(() => _language = selection.first),
            ),
            const SizedBox(height: 24.0),
            const XPayDemoSectionTitle('Payment'),
            TextField(
              controller: _sessionJsonController,
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Session JSON',
                helperText: 'The whole payment-session response from your backend. Valid for 15 minutes, one ride only.',
              ),
            ),
            const SizedBox(height: 12.0),
            FilledButton(
              onPressed: _isPaying ? null : _handlePay,
              child: Text(_isPaying ? 'Paying…' : 'Pay'),
            ),
            if (lastResult != null) ...[
              const SizedBox(height: 24.0),
              const XPayDemoSectionTitle('Last result'),
              XPayDemoResultCard(result: lastResult),
            ],
            if (_logEvents.isNotEmpty) ...[
              const SizedBox(height: 24.0),
              const XPayDemoSectionTitle('SDK events'),
              for (final event in _logEvents) XPayDemoLogTile(event: event),
            ],
          ],
        ),
      ),
    );
  }
}

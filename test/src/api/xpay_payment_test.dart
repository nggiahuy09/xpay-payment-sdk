import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/xpay_payment_sdk.dart';

const _sessionToken = 'rps_secret_token';

final List<XPayLogEvent> _events = [];

Future<BuildContext> _pumpHost(WidgetTester tester) async {
  late BuildContext hostContext;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          hostContext = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return hostContext;
}

void main() {
  setUp(() async {
    _events.clear();
    await XPayPayment.initialize(
      XPayConfig(
        environment: const XPayEnvironment(baseUrl: 'https://xpay.test'),
        onLog: _events.add,
      ),
    );
  });

  group('XPayPayment.start with a rejected session', () {
    testWidgets('fails with sdk_invalid_request, logs the reason once and opens nothing', (tester) async {
      final context = await _pumpHost(tester);

      final result = await XPayPayment.start(context, const XPayPaymentRequest.fromSession('not json'));
      await tester.pump();

      expect(result.status, XPayPaymentStatus.failed);
      expect(result.errorCode, XPayErrorCode.invalidRequest);
      expect(_events, hasLength(1));
      expect(_events.single.level, XPayLogLevel.error);
      expect(_events.single.category, XPayLogCategory.error);
      expect(_events.single.reason, 'invalid_session_json');
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('never logs the session JSON or its token', (tester) async {
      final context = await _pumpHost(tester);

      await XPayPayment.start(
        context,
        const XPayPaymentRequest.fromSession('{"session_token": "$_sessionToken", "amount": "999", "external_ref": "XP-1"}'),
      );

      expect(_events.single.reason, 'amount_below_minimum');
      expect(_events.single.input.toString(), isNot(contains(_sessionToken)));
    });
  });
}

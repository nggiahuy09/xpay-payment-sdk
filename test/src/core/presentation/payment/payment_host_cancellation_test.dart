import 'package:flutter_test/flutter_test.dart';
import 'package:xpay_payment_sdk/src/core/presentation/payment/helpers/payment_host_cancellation.dart';

void main() {
  test('without an open payment flow the request is left to the caller', () {
    expect(PaymentHostCancellation().request(), isFalse);
  });

  test('the attached flow receives the request until it detaches', () {
    final cancellation = PaymentHostCancellation();
    var calls = 0;
    void onCancel() => calls++;

    cancellation.attach(onCancel);
    expect(cancellation.request(), isTrue);
    expect(calls, 1);

    cancellation.detach(onCancel);
    expect(cancellation.request(), isFalse);
    expect(calls, 1);
  });

  test('a flow that is no longer attached cannot detach the open one', () {
    final cancellation = PaymentHostCancellation();
    var openCalls = 0;
    void closedFlow() {}
    void openFlow() => openCalls++;

    cancellation.attach(closedFlow);
    cancellation.attach(openFlow);
    cancellation.detach(closedFlow);

    expect(cancellation.request(), isTrue);
    expect(openCalls, 1);
  });

  test('a request is remembered for the open payment until the next payment resets it', () {
    final cancellation = PaymentHostCancellation();
    void flow() {}

    cancellation.request();
    expect(cancellation.isRequested, isFalse);

    cancellation.attach(flow);
    cancellation.request();
    expect(cancellation.isRequested, isTrue);

    cancellation.detach(flow);
    expect(cancellation.isRequested, isTrue);

    cancellation.reset();
    expect(cancellation.isRequested, isFalse);
  });

  test('a screen nested in the flow takes the request first, and the flow gets it back once the screen detaches', () {
    final cancellation = PaymentHostCancellation();
    var flowCalls = 0;
    var screenCalls = 0;
    void flow() => flowCalls++;
    void screen() => screenCalls++;

    cancellation.attach(flow);
    cancellation.attach(screen);
    cancellation.request();
    expect((flowCalls, screenCalls), (0, 1));

    cancellation.detach(screen);
    cancellation.request();
    expect((flowCalls, screenCalls), (1, 1));
  });
}

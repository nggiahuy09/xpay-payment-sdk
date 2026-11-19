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
}

/// Forwards a host cancellation (the app closed the SDK screens) to the open payment flow, which decides how it ends.
final class PaymentHostCancellation {
  final List<void Function()> _handlers = [];

  /// Whether the app closed the SDK screens during the open payment, so an outcome a screen still reports afterwards ends the flow instead of showing more screens.
  bool get isRequested => _isRequested;
  bool _isRequested = false;

  /// The latest attached handler takes the cancellation, so a screen nested in the flow handles it before the flow around it.
  void attach(void Function() onCancel) => _handlers
    ..remove(onCancel)
    ..add(onCancel);

  void detach(void Function() onCancel) => _handlers.remove(onCancel);

  /// Returns `false` when no payment flow is open.
  bool request() {
    if (_handlers.isEmpty) return false;

    _isRequested = true;
    _handlers.last.call();
    return true;
  }

  /// Clears [isRequested] for a new payment.
  void reset() => _isRequested = false;
}

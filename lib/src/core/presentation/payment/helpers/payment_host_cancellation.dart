/// Forwards a host cancellation (the app closed the SDK screens) to the open payment flow, which decides how it ends.
final class PaymentHostCancellation {
  void Function()? _onCancel;

  void attach(void Function() onCancel) => _onCancel = onCancel;

  void detach(void Function() onCancel) {
    if (_onCancel == onCancel) _onCancel = null;
  }

  /// Returns `false` when no payment flow is open.
  bool request() {
    final onCancel = _onCancel;
    if (onCancel == null) return false;

    onCancel.call();
    return true;
  }
}

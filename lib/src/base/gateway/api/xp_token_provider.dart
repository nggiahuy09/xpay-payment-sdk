/// Supplies auth tokens to `XPRestClient` so datasources never read or attach
/// tokens themselves.
abstract interface class XPTokenProvider {
  const XPTokenProvider();

  /// Ride payment session token for `APIType.user` requests, sent as `X-Ride-Payment`. Null when no payment is open.
  Future<String?> getSessionToken();
}

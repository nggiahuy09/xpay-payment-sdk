/// Supplies auth tokens to `XPRestClient` so datasources never read or attach
/// tokens themselves.
abstract interface class XPTokenProvider {
  const XPTokenProvider();

  /// Ride payment session token for `APIType.user` requests, sent as `X-Ride-Payment`. Null when no payment is open.
  Future<String?> getSessionToken();

  /// Asks the host app for a new session of the same ride after the server rejected the current one as expired; [XPSessionRenewal.renewed] once the new token is in place.
  Future<XPSessionRenewal> renewSessionToken();
}

enum XPSessionRenewal { renewed, amountChanged, failed }

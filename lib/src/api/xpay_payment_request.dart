final class XPayPaymentRequest {
  const XPayPaymentRequest.fromSession(this.sessionJson, [this.fetchSession]);

  final String sessionJson;
  final Future<String> Function()? fetchSession;
}

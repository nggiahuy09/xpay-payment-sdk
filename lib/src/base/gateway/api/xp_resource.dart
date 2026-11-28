import 'xp_http_method.dart';

/// Request definition wrapping exactly one REST endpoint: the HTTP method, the relative path, query parameters/body, optional extra headers, and how to
/// parse the raw response into a model.
///
/// One resource class per endpoint. `path` is relative; `XPRestClient` prefixes the base URL it was built with. Do not map models to domain entities here — that
/// is the repository's job.
abstract class XPResource<T> {
  const XPResource({required this.description});

  final String description;

  Object? get body => null;

  Map<String, dynamic>? get headers => null;

  Map<String, dynamic>? get queryParameters => null;

  /// Longest the whole request may take, replays included; null keeps the client's connect and receive timeouts.
  Duration? get timeout => null;

  /// Whether `XPTransientRetryInterceptor` may replay this request after a timeout, a lost connection or a 5xx.
  bool get retriesTransientFailures => true;

  XPHttpMethod get method;

  String get path;

  T parse(Object? data);
}

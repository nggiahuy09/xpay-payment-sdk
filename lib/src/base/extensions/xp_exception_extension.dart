import '../domain/exceptions/xp_exception.dart';

/// Declared on the nullable type so a state that only sometimes carries a failure — a request that succeeded but returned nothing reportable — resolves its copy through the same chain
/// instead of repeating each fallback on both sides of a `??`.
extension XPExceptionDisplayExtension on XPException? {
  /// The title to show for this failure, preferring the copy the exception carries.
  ///
  /// The network and session factories set their own [XPException.displayTitle] ("No internet connection", "Sign in required"), which names an actionable cause; [fallback] covers the
  /// API failures that carry no copy of their own, and the no-failure case.
  String getTitle(String fallback) => this?.displayTitle ?? fallback;

  /// The body to show for this failure, preferring the copy the exception carries.
  ///
  /// [onFallback] receives [XPException.errorCode] so a failure with no copy of its own still
  /// renders the raw code for traceability. It is only consulted when [XPException.displayMessage]
  /// is absent, so a network failure keeps its own wording rather than degrading to generic text
  /// plus a code. With no failure at all there is no code to quote, so it receives null.
  String getBody(String Function(String? errorCode) onFallback) => this?.displayMessage ?? onFallback.call(this?.errorCode);
}

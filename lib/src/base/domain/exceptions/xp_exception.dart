import 'package:equatable/equatable.dart';

/// Base type for all domain-facing errors.
///
/// Repositories return `Either<XPException, T>`; the gateway layer maps every
/// Dio failure into one of the subtypes below before it leaves `XPRestClient`.
sealed class XPException with Equatable {
  const XPException({this.details, this.error, this.displayMessage, this.displayTitle, this.errorCode, this.serverMessage});

  final Object? details;
  final Object? error;
  final String? displayMessage;
  final String? displayTitle;
  final String? errorCode;
  final String? serverMessage;

  /// If this exception is because network issues, example: connection issue, server issues, etc.
  bool get isNetworkError => false;

  /// Whether the server rejected the request as conflicting with one it already holds — see [XPConflictException].
  ///
  /// Exposed as a getter rather than left to a type check so callers can branch on the meaning without importing the gateway's status codes, the same way [isNetworkError] works.
  bool get isConflict => false;

  @override
  List<Object?> get props => [details, error, displayMessage, displayTitle, errorCode, serverMessage];

  @override
  String toString() {
    return '$runtimeType(details: $details, error: $error, displayMessage: $displayMessage, displayTitle: $displayTitle, errorCode: $errorCode, serverMessage: $serverMessage)';
  }
}

/// No connection, timeout, or cancelled request.
final class XPNetworkException extends XPException {
  const XPNetworkException({super.details, super.error, super.displayMessage, super.displayTitle, super.errorCode});

  const XPNetworkException.noConnection({super.error})
    : super(displayMessage: 'Check your internet connection and try again.', displayTitle: 'No internet connection', errorCode: 'no_connection');

  const XPNetworkException.noHost({super.error})
    : super(displayMessage: 'The server is unavailable. Please try again later.', displayTitle: 'Unable to connect to server', errorCode: 'no_host');

  const XPNetworkException.timeout({super.error})
    : super(displayMessage: 'The server took too long to respond. Please try again.', displayTitle: 'Request timed out', errorCode: 'timeout');

  @override
  bool get isNetworkError => true;
}

/// HTTP 401 — token invalid or expired.
final class XPUnauthorizedException extends XPException {
  const XPUnauthorizedException({super.details, super.error, super.displayMessage, super.displayTitle, super.errorCode});

  const XPUnauthorizedException.tokenExpired({super.error})
    : super(displayMessage: 'Your session has expired. Please sign in again.', displayTitle: 'Sign in required', errorCode: 'token_expired');

  const XPUnauthorizedException.tokenNotFound({super.error})
    : super(displayMessage: 'Your session is unavailable. Please sign in again.', displayTitle: 'Sign in required', errorCode: 'token_not_found');
}

/// HTTP 409 — the request conflicts with one the server already holds.
///
/// Reached above all through `Idempotency-Key`: every idempotent endpoint answers a reused key carrying a *different* body with 409 instead of replaying the
/// earlier decision. The caller must not simply resend, because a request under that key may already have succeeded.
final class XPConflictException extends XPException {
  const XPConflictException({super.details, super.error, super.displayMessage, super.displayTitle, super.errorCode, super.serverMessage});

  @override
  bool get isConflict => true;
}

/// Any other non-2xx response. Carries the HTTP status code and raw payload.
final class XPApiException extends XPException {
  const XPApiException({super.details, super.error, super.displayMessage, super.displayTitle, super.errorCode, super.serverMessage, this.data, this.statusCode});

  final Map<String, dynamic>? data;
  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode, data];

  @override
  String toString() {
    return 'XPApiException(error: $error, displayMessage: $displayMessage, displayTitle: $displayTitle, serverMessage: $serverMessage, errorCode: $errorCode, data: $data, statusCode: $statusCode)';
  }

  XPApiException withDetails(Object? details) => XPApiException(
    details: details,
    error: error,
    displayMessage: displayMessage,
    displayTitle: displayTitle,
    errorCode: errorCode,
    serverMessage: serverMessage,
    data: data,
    statusCode: statusCode,
  );
}

/// Fallback for unexpected non-network, non-API failures (parsing, null fields,
/// business validation on a successful response).
final class XPUnknownException extends XPException {
  const XPUnknownException({super.details, super.error, super.displayMessage, super.displayTitle, super.errorCode});
}

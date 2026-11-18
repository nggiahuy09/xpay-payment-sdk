import 'package:dio/dio.dart';

import 'string_extension.dart';

extension ResponseStatusExtension on Response {
  bool get success => ((statusCode ?? 0) ~/ 100) == 2;
}

extension ResponseDataExtension on Response {
  Map<String, dynamic>? get mapData => data is Map<String, dynamic> ? data as Map<String, dynamic> : null;

  /// Both normalise an empty or whitespace-only value to null, so callers can treat "absent" and "present but blank" alike — a `displayMessage ?? fallback` chain
  /// would otherwise select the blank string and render an empty error body.
  String? get errorCode => success ? null : (mapData?['code'] as String?)?.nullIfEmpty();

  String? get errorMessage => success ? null : (mapData?['message'] as String?)?.nullIfEmpty();

  Map<String, dynamic>? get errorDetails => success ? null : mapData?['details'] as Map<String, dynamic>?;
}

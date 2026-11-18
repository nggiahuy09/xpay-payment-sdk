import 'dart:ui';
import 'package:diacritic/diacritic.dart';

import 'iterable_extension.dart';

extension StringFormatExtension on String {
  /// Capitalizes first character of the string. Returns empty string for null/empty input
  String toSentenceCase() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Returns the string if it is not empty after trimming, otherwise returns the default value.
  ///
  /// If [onElse] is not null, it will be called with the original string to transform the value, if the trimmed string is not empty.
  String defaultIfEmpty(String Function() onEmpty, [String Function(String s)? onElse]) => trim().isEmpty ? onEmpty.call() : onElse?.call(this) ?? this;

  /// Returns the string if it is not empty after trimming, otherwise returns null.
  ///
  /// If [onElse] is not null, it will be called with the original string to transform the value, if the trimmed string is not empty.
  String? nullIfEmpty([String Function(String s)? onElse]) => trim().isEmpty ? null : onElse?.call(this) ?? this;

  /// Splits the string into chunks of [groupSize] characters, joined by [separator]. Optionally limits to [maxSegments]. You can customize each segment using [builder].
  ///
  /// If [forceSeparator] is true, [separator] will be used even if [builder] is not null.
  ///
  /// Example:
  /// ```dart
  /// '913249234'.grouped();
  /// // => '913 249 234'
  ///
  /// '913249234'.grouped(maxSegments: 2);
  /// // => '913 249234'
  ///
  /// '913249234'.grouped(groupSize: 2, separator: '-');
  /// // => '91-32-49-23-4'
  ///
  /// '913249234'.grouped(builder: (s, i) => '[${i + 1}]$s');
  /// // => '[1]913 [2]249 [3]234'
  /// ```
  String grouped({String separator = ' ', int? maxSegments, int segmentSize = 3, bool forceSeparator = false, String Function(String segment, int index)? builder}) {
    if (isEmpty || segmentSize <= 0) return this;

    final groups = <String>[];
    for (var i = 0; i < length; i += segmentSize) {
      if (maxSegments != null && groups.length >= maxSegments - 1) {
        final remaining = substring(i);
        final built = builder?.call(remaining, groups.length) ?? remaining;
        groups.add(built);
        break;
      }
      final segment = substring(i, (i + segmentSize).clamp(0, length).toInt());
      groups.add(builder?.call(segment, groups.length) ?? segment);
    }

    final useSeparator = forceSeparator || builder == null;
    return useSeparator ? groups.join(separator) : groups.join();
  }
}

extension StringDiacriticExtension on String {
  static final RegExp _whitespace = RegExp(r'\s+');

  String get _withoutDiacritics => removeDiacritics(this).toLowerCase();

  /// Ranges matching [query] while ignoring case and diacritics (`le loi` matches `Lê Lợi`): the whole query when it occurs, otherwise each of its words.
  List<TextRange> findDiacriticInsensitiveMatches(String query) {
    final normalizedQuery = query._withoutDiacritics.trim();
    if (normalizedQuery.isEmpty) return const [];

    final sourceIndexes = <int>[];
    final normalized = StringBuffer();
    for (var index = 0; index < length; index++) {
      final unit = this[index]._withoutDiacritics;
      normalized.write(unit);
      sourceIndexes.addAll(List.filled(unit.length, index));
    }
    final normalizedText = normalized.toString();

    final wholeMatch = normalizedText._findMatch(normalizedQuery, sourceIndexes);
    if (wholeMatch != null) return [wholeMatch];

    final wordMatches = normalizedQuery.split(_whitespace).mapNotNull((word) => normalizedText._findMatch(word, sourceIndexes)).toList()
      ..sort((primary, secondary) => primary.start.compareTo(secondary.start));
    return wordMatches.fold(<TextRange>[], (ranges, range) => ranges.isNotEmpty && ranges.last.end > range.start ? ranges : [...ranges, range]);
  }

  TextRange? _findMatch(String query, List<int> sourceIndexes) {
    final start = indexOf(query);
    if (query.isEmpty || start < 0) return null;

    return TextRange(start: sourceIndexes[start], end: sourceIndexes[start + query.length - 1] + 1);
  }
}

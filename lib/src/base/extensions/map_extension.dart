import 'package:collection/collection.dart';

/// Extension for safe map operations
extension SafeMapExtension on Map<String, dynamic>? {
  /// Safely get nested value from map using a list of keys
  /// Returns null if any key in the path doesn't exist
  T? safeGetNestedValue<T>(List<String> keys) {
    if (this == null) return null;

    dynamic current = this;
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current is T ? current : null;
  }

  /// Safely get a single level value with type casting
  T? safeGet<T>(String key) {
    if (this == null) return null;
    final value = this![key];
    return value is T ? value : null;
  }

  /// Safely get nested map for chaining operations
  Map<String, dynamic>? safeGetMap(String key) {
    if (this == null) return null;
    final value = this![key];
    return value is Map<String, dynamic> ? value : null;
  }

  /// Check if a nested path exists
  bool hasNestedPath(List<String> keys) {
    if (this == null) return false;

    dynamic current = this;
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return false;
      }
    }
    return true;
  }

  /// Get nested value with fallback
  T getNestedValueOrDefault<T>(List<String> keys, T defaultValue) {
    return safeGetNestedValue<T>(keys) ?? defaultValue;
  }
}

/// Extension for non-nullable maps
extension SafeMapExtensionNonNull on Map<String, dynamic> {
  /// Safely get nested value from non-null map
  T? safeGetNestedValue<T>(List<String> keys) {
    dynamic current = this;
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current is T ? current : null;
  }

  /// Safely get a single level value with type casting
  T? safeGet<T>(String key) {
    final value = this[key];
    return value is T ? value : null;
  }

  /// Safely get nested map for chaining operations
  Map<String, dynamic>? safeGetMap(String key) {
    final value = this[key];
    return value is Map<String, dynamic> ? value : null;
  }
}

extension MapComparisonExtension<K, V> on Map<K, V> {
  static const _equality = DeepCollectionEquality();

  /// Is used to deep compare two Map. Use this if you want to compare two unmodifiable map,
  /// which were created to prevent unwanted modification to the original map, e.g., in a state class.
  bool equals(Map<K, V> other) => _equality.equals(this, other);

  Map<K, V>? nullIfEmpty() => isEmpty ? null : this;
}

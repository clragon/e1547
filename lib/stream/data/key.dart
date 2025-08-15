import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// A class storing a key for a data fetching operation.
/// Uses deep equality to compare keys.
@immutable
class QueryKey {
  QueryKey(this.raw);

  /// The original key used to create this [QueryKey].
  final Object raw;

  static const _equality = DeepCollectionEquality();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueryKey && _equality.equals(raw, other.raw);

  @override
  int get hashCode => _equality.hash(raw);

  late final String _serialized = json.encode(raw);

  @override
  String toString() => 'QueryKey($_serialized)';
}

extension QueryKeyQuerying on QueryKey {
  bool find(String key, Object? value) {
    if (raw case Map<String, dynamic> map) {
      if (map.containsKey(key)) {
        return value == null || map[key] == value;
      }
    }
    return false;
  }
}

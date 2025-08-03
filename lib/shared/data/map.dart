import 'package:collection/collection.dart';

typedef QueryMap = Map<String, String>;

extension QueryMapping on Map<String, dynamic> {
  /// Transforms a given Map into a QueryMap.
  ///
  /// Null values are omitted.
  /// All other values are converted to strings.
  QueryMap toQuery() => entries
      .where((entry) => entry.value != null)
      .map((entry) => MapEntry(entry.key, _stringify(entry.value)))
      .sorted((a, b) => a.key.compareTo(b.key))
      .toMap();

  String _stringify(Object? value) => switch (value) {
    List e => e.map(_stringify).join(','),
    Enum e => e.name,
    _ => value.toString(),
  };
}

extension QueryMapHandling on QueryMap {
  // ignore: use_to_and_as_if_applicable
  QueryMap clone() => Map.of(this);

  void setOrRemove(String key, String? value) {
    if (value == null) {
      remove(key);
    } else {
      this[key] = value;
    }
  }
}

extension MappableListExtension<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMap() => Map.fromEntries(this);
}

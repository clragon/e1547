import 'package:collection/collection.dart';

typedef QueryMap = Map<String, String>;

extension QueryMapping on Map<String, dynamic> {
  String? _serialize(Object? value) {
    if (value == null) return null;
    switch (value) {
      case Enum e:
        return e.name;
      default:
        return value.toString();
    }
  }

  void _serializeNested(Map<String, String> result, String key, Object? value) {
    if (value == null) return;
    switch (value) {
      case Map m:
        for (final e in m.entries) {
          final k = e.key.toString();
          _serializeNested(result, '$key[$k]', e.value);
        }
      case Iterable i:
        final serialized = i.map(_serialize).whereType<String>().join(',');
        if (serialized.isNotEmpty) result[key] = serialized;
      default:
        final serialized = _serialize(value);
        if (serialized != null) result[key] = serialized;
    }
  }

  QueryMap toQuery() {
    final result = <String, String>{};

    for (final e in entries) {
      _serializeNested(result, e.key, e.value);
    }

    return result.entries.sorted((a, b) => a.key.compareTo(b.key)).toMap();
  }
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

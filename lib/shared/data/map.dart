import 'package:collection/collection.dart';

typedef QueryMap = Map<String, String>;

extension QueryMapping on Map<String, dynamic> {
  QueryMap toQuery() {
    final result = <String, String>{};

    void walk(String key, Object? value) {
      if (value == null) return;
      switch (value) {
        case Map m:
          for (final e in m.entries) {
            final k = e.key.toString();
            walk('$key[$k]', e.value);
          }
        case List l:
          for (final v in l) {
            walk('$key[]', v);
          }
        case Enum e:
          result[key] = e.name;
        default:
          result[key] = value.toString();
      }
    }

    for (final e in entries) {
      walk(e.key, e.value);
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

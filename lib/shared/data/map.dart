import 'package:collection/collection.dart';
import 'package:runtime_type/runtime_type.dart';

typedef ProtoMap = Map<String, Object?>;

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
      case List l:
        for (final v in l) {
          _serializeNested(result, '$key[]', v);
        }
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

  void set(String key, Object? value) {
    if (value == null) {
      remove(key);
      return;
    }

    switch (value) {
      case Map _:
      case List _:
        final serialized = <String, String>{};
        _serializeNested(serialized, key, value);
        remove(key);
        addAll(serialized);
      default:
        final serialized = _serialize(value);
        if (serialized != null) {
          this[key] = serialized;
        } else {
          remove(key);
        }
    }
  }

  String? getString(String key) => this[key];

  int? getInt(String key) {
    final value = this[key];
    return value != null ? int.tryParse(value) : null;
  }

  bool? getBool(String key) {
    final value = this[key];
    return value != null ? value.toLowerCase() == 'true' : null;
  }

  List<String>? getStringList(String key) {
    final value = this[key];
    return value
        ?.split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<int>? getIntList(String key) {
    final stringList = getStringList(key);
    return stringList?.map(int.tryParse).whereType<int>().toList();
  }

  T? getEnum<T extends Enum>(String key, List<T> values) {
    final value = getString(key);
    if (value == null) return null;
    return values.asNameMap()[value];
  }

  T? get<T>(String key) {
    if (_isTypeOrNull<String, T>()) {
      return getString(key) as T?;
    }
    if (_isTypeOrNull<int, T>()) {
      return getInt(key) as T?;
    }
    if (_isTypeOrNull<bool, T>()) {
      return getBool(key) as T?;
    }
    if (_isTypeOrNull<List<String>, T>()) {
      return getStringList(key) as T?;
    }
    if (_isTypeOrNull<List<int>, T>()) {
      return getIntList(key) as T?;
    }
    throw UnsupportedError('Type $T is not supported by QueryMap.get()');
  }

  static bool _isTypeOrNull<E, T>() =>
      RuntimeType<T>().isSubtypeOf(RuntimeType<E?>());

  QueryMap select(List<String> keys) =>
      Map.fromEntries(entries.where((e) => keys.contains(e.key)));
}

extension MappableListExtension<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMap() => Map.fromEntries(this);
}

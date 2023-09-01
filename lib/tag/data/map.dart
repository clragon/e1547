import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

/// A collection of parameters.
///
/// Entries are comprised of a name and an optional value.
/// Entries with values are sorted before entries without values.
/// Entries that have no value will return an empty string when accessed.
///
/// A key may be present multiple times with different values.
/// When accessing a key, the first value is returned.
/// To access all values of a key, use [toMapAll].
class QueryMap extends MapBase<String, String> {
  /// Creates a query map.
  /// Optionally, a map can be provided to copy values from.
  factory QueryMap([Map<String, Object?>? other]) {
    return QueryMap.fromIterable(other?.entries ?? []);
  }

  /// Creates a query map internally.
  /// Entries are stored in a [SplayTreeSet] to keep them sorted.
  QueryMap._() : _entries = SplayTreeSet<QueryValue>();

  /// Creates a query map from an iterable of entries.
  factory QueryMap.fromIterable(Iterable<MapEntry<String, Object?>> other) {
    QueryMap result = QueryMap._();
    for (final entry in other) {
      result._entries.add(QueryValue(entry.key, entry.value?.toString()));
    }
    return result;
  }

  /// Creates a query map from a string.
  ///
  /// Input is expected to be in the format `name:value name2`.
  factory QueryMap.parse(String tags) {
    QueryMap result = QueryMap();
    result._entries.addAll(
      tags.trim().split(' ').where((e) => e.isNotEmpty).map(QueryValue.parse),
    );
    return result;
  }

  /// Creates a query map from a decoded JSON map.
  ///
  /// The JSON map is expected to be in the format:
  /// ```json
  /// {
  ///  "name": "value",
  ///  "name2": ["value1", "value2"],
  /// }
  /// ```
  factory QueryMap.fromJson(Map<String, dynamic> json) {
    List<MapEntry<String, String>> entries = [];
    for (final entry in json.entries) {
      if (entry.value is String) {
        entries.add(MapEntry(entry.key, entry.value));
      } else if (entry.value is List) {
        for (final value in entry.value) {
          if (value is! String) {
            throw FormatException(
              'Expected a string or list of strings, got ${value.runtimeType}',
              json,
            );
          }
          entries.add(MapEntry(entry.key, value));
        }
      }
    }
    return QueryMap.fromIterable(entries);
  }

  Map<String, dynamic> toJson() => toMapAll();

  final Set<QueryValue> _entries;

  List<String> get tags => _entries.map((tag) => tag.toString()).toList();

  @override
  String? operator [](Object? key) =>
      _entries.firstWhereOrNull((tag) => tag.name == key)?.value;

  @override
  void operator []=(String key, String? value) {
    remove(key);
    _entries.add(QueryValue(key, value));
  }

  void add(String key, [String? value]) => this[key] = value;

  @override
  String? remove(Object? key) {
    for (final tag in _entries) {
      if (tag.name == key) {
        _entries.remove(tag);
        return tag.value;
      }
    }
    return null;
  }

  @override
  void clear() => _entries.clear();

  @override
  Iterable<MapEntry<String, String>> get entries =>
      _entries.map((tag) => MapEntry(tag.name, tag.value));

  @override
  Iterable<String> get keys => _entries.map((tag) => tag.name);

  @override
  Iterable<String> get values => _entries.map((tag) => tag.value);

  @override
  String toString() => _entries.map((tag) => tag.toString()).join(' ');

  /// Returns a new QueryMap with the same values.
  Map<String, String?> toMap() => QueryMap(this);

  /// Returns a new QueryMap with all values.
  Map<String, List<String>> toMapAll() {
    Map<String, List<String>> result = {};
    for (final tag in _entries) {
      if (result.containsKey(tag.name)) {
        result[tag.name]!.add(tag.value);
      } else {
        result[tag.name] = [tag.value];
      }
    }
    return result;
  }

  /// Returns a new QueryMap with all empty values removed.
  QueryMap withoutEmpty() {
    QueryMap result = QueryMap();
    for (final tag in _entries) {
      if (tag.value.isNotEmpty) {
        result._entries.add(tag);
      }
    }
    return result;
  }
}

/// Represents a tag with a name and an optional value.
///
/// Can be parsed from a string in the format `name:value`.
@immutable
class QueryValue implements Comparable<QueryValue> {
  const QueryValue(this.name, [String? value]) : value = value ?? '';

  factory QueryValue.parse(String tag) {
    List<String> result = tag.split(':');
    String? value;
    if (result.length > 1) {
      value = result.sublist(1).join(':');
    }
    return QueryValue(result[0], value);
  }

  final String name;
  final String value;

  @override
  String toString() => value.isEmpty ? name : '$name:$value';

  @override
  bool operator ==(Object other) =>
      other is QueryValue && name == other.name && value == other.value;

  @override
  int get hashCode => Object.hash(name, value);

  /// Compares this value to another value.
  @override
  int compareTo(QueryValue other) {
    if (value.isEmpty && other.value.isNotEmpty) return 1;
    if (value.isNotEmpty && other.value.isEmpty) return -1;
    if (name != other.name) return name.compareTo(other.name);
    if (value.isEmpty && other.value.isEmpty) return 0;
    return value.compareTo(other.value);
  }
}

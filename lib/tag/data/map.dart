import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

class TagMap extends MapBase<String, String?> {
  TagMap() : _tags = SplayTreeSet<StringTag>();

  factory TagMap.from(Map<String, String?> other) => TagMap()..addAll(other);

  factory TagMap.parse(String tags) {
    TagMap result = TagMap();
    result._tags.addAll(
      tags.trim().split(' ').where((e) => e.isNotEmpty).map(StringTag.parse),
    );
    return result;
  }

  final Set<StringTag> _tags;

  List<String> get tags => _tags.map((tag) => tag.toString()).toList();

  @override
  String? operator [](Object? key) =>
      _tags.firstWhereOrNull((tag) => tag.name == key)?.value;

  @override
  void operator []=(String key, String? value) {
    remove(key);
    _tags.add(StringTag(key, value));
  }

  @override
  void clear() => _tags.clear();

  @override
  Iterable<String> get keys => _tags.map((tag) => tag.name);

  @override
  String? remove(Object? key) {
    for (final tag in _tags) {
      if (tag.name == key) {
        _tags.remove(tag);
        return tag.value;
      }
    }
    return null;
  }

  @override
  String toString() => _tags.map((tag) => tag.toString()).join(' ');

  bool equals(TagMap? other) {
    MapEquality<String, String?> equality = const MapEquality();
    return equality.equals(this, other);
  }
}

extension TagSetLink on TagMap {
  String get link => '/posts?tags=${toString()}';
}

/// Represents a tag with a name and an optional value.
///
/// Can be parsed from a string in the format `name:value`.
@immutable
class StringTag implements Comparable<StringTag> {
  const StringTag(this.name, [this.value]);

  factory StringTag.parse(String tag) {
    List<String> result = tag.split(':');
    String? value;
    if (result.length > 1) {
      value = result.sublist(1).join(':');
    }
    return StringTag(result[0], value);
  }

  final String name;
  final String? value;

  @override
  String toString() => value == null ? name : '$name:$value';

  @override
  bool operator ==(Object other) =>
      other is StringTag && name == other.name && value == other.value;

  @override
  int get hashCode => Object.hash(name, value);

  /// The prefix of the tag, if any.
  ///
  /// The prefix is either `-` for a negated tag or `~` for a union tag.
  String? get prefix {
    if (name.startsWith('-') || name.startsWith('~')) {
      return name[0];
    }
    return null;
  }

  /// Compares this tag to another tag.
  ///
  /// Tags are compared by their prefix, name and value.
  /// Negated tags are considered smaller than union tags.
  @override
  int compareTo(StringTag other) {
    if (value == null && other.value != null) return -1;
    if (value != null && other.value == null) return 1;
    if (prefix != other.prefix) {
      if (prefix == null) return -1;
      if (other.prefix == null) return 1;
      return prefix!.compareTo(other.prefix!);
    }
    if (name != other.name) return name.compareTo(other.name);
    if (value == null && other.value == null) return 0;
    return value!.compareTo(other.value!);
  }
}

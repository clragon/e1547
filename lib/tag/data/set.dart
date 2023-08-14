import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class TagSet extends DelegatingSet<StringTag> {
  TagSet() : super(SplayTreeSet<StringTag>());

  factory TagSet.from(Set<StringTag> value) => TagSet()..addAll(value);

  factory TagSet.parse(String value) {
    final set = TagSet();
    for (final tag in value.split(' ').where((e) => e.trim().isNotEmpty)) {
      set.add(StringTag.parse(tag));
    }
    return set;
  }

  String? operator [](Object? key) {
    if (key is String) {
      return firstWhereOrNull((tag) => tag.name == key)?.value;
    }
    return null;
  }

  void operator []=(String key, String? value) => add(StringTag(key, value));

  List<String> get keys => map((e) => e.name).toList();

  bool containsKey(String key) => keys.contains(key);

  void removeKey(String key) => removeWhere((tag) => tag.name == key);

  @override
  String toString() => join(' ');
}

extension TagSetLink on TagSet {
  String get link => '/posts?tags=${toString()}';
}

@immutable
class StringTag implements Comparable<StringTag> {
  const StringTag(this.name, [this._value]);

  factory StringTag.parse(String tag) {
    tag = tag.trim();
    if (tag.isEmpty) throw const FormatException('Input is empty');

    RegExp pattern = RegExp(r'^(?<name>[-~]?.+?)(?::(?<value>.+))?$');
    RegExpMatch? match = pattern.firstMatch(tag);

    if (match == null) throw FormatException('Invalid tag format', tag);

    String name = match.namedGroup('name')!;
    String? value = match.namedGroup('value');

    return StringTag(name, value);
  }

  final String name;
  final String? _value;
  String? get value => (_value?.isNotEmpty ?? false) ? _value : null;

  @override
  String toString() => '$name${value != null ? ':$value' : ''}';

  @override
  bool operator ==(Object other) =>
      other is StringTag && name == other.name && value == other.value;

  @override
  int get hashCode => toString().hashCode;

  @override
  int compareTo(StringTag other) {
    if (value != null && other.value == null) {
      return -1;
    } else if (value == null && other.value != null) {
      return 1;
    }

    int getPrefixValue(String prefix) {
      switch (prefix[0]) {
        case '-':
          return 1;
        case '~':
          return 0;
        default:
          return -1;
      }
    }

    int firstValue = getPrefixValue(name);
    int secondValue = getPrefixValue(other.name);

    if (firstValue != secondValue) {
      return firstValue.compareTo(secondValue);
    } else {
      return toString().compareTo(other.toString());
    }
  }
}

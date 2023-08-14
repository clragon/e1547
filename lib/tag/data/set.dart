import 'package:e1547/interface/interface.dart';
import 'package:flutter/foundation.dart';

class TagSet extends Iterable<StringTag> {
  TagSet(Set<StringTag> tags) : _tags = {for (final t in tags) t.name: t};

  TagSet.parse(String tagString) : _tags = {} {
    for (final ts in tagString.split(' ').trim()) {
      if (ts.trim().isEmpty) {
        continue;
      }
      StringTag t = StringTag.parse(ts);
      _tags[t.name] = t;
    }
  }

  final Map<String, StringTag> _tags;

  String get link => '/posts?tags=${toString()}';

  @override
  bool contains(Object? element) => _tags.containsValue(element);

  bool containsTag(String tag) => _tags.containsKey(tag);

  String? operator [](String? name) {
    StringTag? t = _tags[name!];
    if (t == null) {
      return null;
    }

    return t.value;
  }

  void operator []=(String name, String? value) {
    _tags[name] = StringTag(name, value);
  }

  void remove(String? name) {
    _tags.remove(name);
  }

  @override
  Iterator<StringTag> get iterator => _tags.values.iterator;

  @override
  String toString() {
    List<StringTag> tags = _tags.values.toList();
    tags.sort();
    return tags.join(' ');
  }
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

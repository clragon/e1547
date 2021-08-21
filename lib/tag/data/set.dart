import 'dart:collection';

import 'package:e1547/tag/tag.dart';

class Tagset extends Object with IterableMixin<Tag> {
  Tagset(Set<Tag> tags)
      : _tags = Map.fromIterable(
          tags,
          key: (t) => (t as Tag).name,
          value: ((t) => (t as Tag?)!),
        );

  Tagset.parse(String tagString) : _tags = {} {
    for (String ts in tagString.split(RegExp(r'\s+'))) {
      if (ts.trim().isEmpty) {
        continue;
      }
      Tag t = Tag.parse(ts);
      _tags[t.name] = t;
    }
  }

  final Map<String, Tag> _tags;

  Uri url(String host) => Uri(
        scheme: 'https',
        host: host,
        path: '/post',
        queryParameters: {'tags': toString()},
      );

  @override
  bool contains(Object? tagName) {
    return _tags.containsKey(tagName);
  }

  String? operator [](String? name) {
    Tag? t = _tags[name!];
    if (t == null) {
      return null;
    }

    return t.value;
  }

  void operator []=(String name, String? value) {
    _tags[name] = Tag(name, value);
  }

  void remove(String? name) {
    _tags.remove(name);
  }

  @override
  Iterator<Tag> get iterator => _tags.values.iterator;

  @override
  String toString() {
    List<Tag> meta = [];
    List<Tag> normal = [];

    for (Tag t in _tags.values) {
      if (t.value != null) {
        meta.add(t);
      } else {
        normal.add(t);
      }
    }

    // normal tags, then optional, then subtracting
    int order(Tag a, Tag b) {
      int getPrefixValue(String prefix) {
        switch (prefix) {
          case '-':
            return 1;
          case '~':
            return 0;
          default:
            return -1;
        }
      }

      int firstValue = getPrefixValue(a.name[0]);
      int secondValue = getPrefixValue(b.name[0]);
      return firstValue.compareTo(secondValue);
    }

    normal.sort(order);
    meta.sort(order);

    // meta tags first
    List<Tag> output = [];
    output.addAll(meta);
    output.addAll(normal);
    return output.join(' ');
  }
}

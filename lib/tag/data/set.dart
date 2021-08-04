import 'dart:collection';

import 'package:e1547/tag.dart';

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

  // Get the URL for this search/tagset.
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

  // The toString order isn't the same as the iteration order. We order the metatags ahead of the
  // normal tags.
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

    // This isn't terribly efficient, but it probably doesn't matter since the strings are tiny.
    // Something that could be interesting to use here since it would be lazy:
    //    https://www.dartdocs.org/documentation/quiver/0.25.0/quiver.iterables/concat.html
    //
    //    Iterable<T> concat<T>(
    //      Iterable<Iterable<T>> iterables
    //    )

    meta.addAll(normal);
    return meta.join(' ');
  }
}

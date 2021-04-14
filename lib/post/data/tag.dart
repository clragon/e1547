import 'dart:collection' show IterableMixin;

import 'package:flutter/material.dart';

class Tag {
  final String name;
  final String value;

  Tag(this.name, [this.value]);

  factory Tag.parse(String tag) {
    assert(tag != null, "Can't parse a null tag.");
    assert(tag.trim().isNotEmpty, "Can't parse an empty tag.");
    List<String> components = tag.trim().split(':');
    assert(components.length == 1 || components.length == 2);

    String name = components[0];
    String value = components.length == 2 ? components[1] : null;
    return Tag(name, value);
  }

  @override
  String toString() => value == null ? name : '$name:$value';

  @override
  bool operator ==(dynamic other) => // ignore: avoid_annotating_with_dynamic
      other is Tag && name == other.name && value == other.value;

  @override
  int get hashCode => toString().hashCode;
}

class Tagset extends Object with IterableMixin<Tag> {
  Tagset(Set<Tag> tags)
      : _tags = Map.fromIterable(
          tags,
          key: (t) => (t as Tag).name,
          value: (t) => t as Tag,
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
  bool contains(Object tagName) {
    return _tags.containsKey(tagName);
  }

  String operator [](String name) {
    Tag t = _tags[name];
    if (t == null) {
      return null;
    }

    return t.value;
  }

  void operator []=(String name, String value) {
    _tags[name] = Tag(name, value);
  }

  void remove(String name) {
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

String sortTags(String tags) {
  return Tagset.parse(tags).toString();
}

String noDash(String tags) => tags
    .split(' ')
    .where((tag) => tag.isNotEmpty)
    .map((tag) => tag.replaceAllMapped(RegExp(r'^[-~]'), (_) => ''))
    .join(' ');

String noScore(String tags) =>
    noDash(tags.trim()).split(' ').join(', ').replaceAll('_', ' ');

Color getCategoryColor(String category) {
  switch (category) {
    case 'general':
      return Colors.indigo[300];
    case 'species':
      return Colors.teal[300];
    case 'character':
      return Colors.lightGreen[300];
    case 'copyright':
      return Colors.yellow[300];
    case 'meta':
      return Colors.deepOrange[300];
    case 'lore':
      return Colors.pink[300];
    case 'artist':
      return Colors.deepPurple[300];
    default:
      return Colors.grey[300];
  }
}

Map<String, int> categories = {
  'general': 0,
  'species': 5,
  'character': 4,
  'copyright': 3,
  'meta': 7,
  'lore': 8,
  'artist': 1,
  'invalid': 6,
};

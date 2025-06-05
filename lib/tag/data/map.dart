import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';

class TagMap extends MapBase<String, String> implements Map<String, String> {
  TagMap(String? tags) : _node = TagNode.parse(tags);

  TagMap.from(Map<String, String> map)
    : _node = TagGroup(
        children: map.entries.map((entry) {
          final MapEntry(:key, :value) = entry;
          final isGroup = RegExp(r'^\$\d+$').hasMatch(key);
          return isGroup ? TagNode.parse(value) : TagNode.parse('$key:$value');
        }).toList(),
      );

  TagNode _node;
  TagNode get node => _node;

  Iterable<MapEntry<String, TagNode>> _entries(TagNode node) sync* {
    int groupIndex = 0;
    for (final child in node.children) {
      yield switch (child) {
        TagAtom atom => MapEntry(atom.name, atom),
        TagGroup group => MapEntry('\$${groupIndex++}', group),
      };
    }
  }

  TagNode _assemble(Iterable<MapEntry<String, TagNode>> entries) =>
      TagGroup(children: entries.map((e) => e.value).toList());

  @override
  String? operator [](Object? key) => switch (_entries(
    _node,
  ).firstWhereOrNull((e) => e.key == key.toString())?.value) {
    TagAtom atom => atom.value,
    TagGroup group => group.toString(),
    null => null,
  };

  @override
  void operator []=(String key, String? value) {
    final isGroup = RegExp(r'^\$\d+$').hasMatch(key);
    final map = _entries(_node).toMap();

    if (value == null) {
      map.remove(key);
    } else {
      map[key] = isGroup ? TagNode.parse(value) : TagAtom(key, value);
    }

    _node = _assemble(map.entries);
  }

  @override
  void clear() => _node = const TagGroup(children: []);

  @override
  Iterable<String> get keys => _entries(_node).map((e) => e.key);

  void add(String tag) {
    final atom = TagAtom.parse(tag);
    final map = _entries(_node).toMap();
    map[atom.name] = atom;
    _node = _assemble(map.entries);
  }

  @override
  String? remove(Object? key) {
    final map = _entries(_node).toMap();
    final removed = map.remove(key.toString());
    _node = _assemble(map.entries);
    return switch (removed) {
      TagAtom atom => atom.value,
      TagGroup group => group.toString(),
      null => null,
    };
  }

  @override
  String toString() => _node.toString();
}

extension on TagAtom {
  String get name {
    final buffer = StringBuffer();
    if (optional) buffer.write('~');
    if (negated) buffer.write('-');
    buffer.write(key);
    return buffer.toString();
  }
}

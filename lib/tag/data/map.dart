import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:e1547/tag/tag.dart';
import 'package:petitparser/petitparser.dart';

class TagMap extends MapBase<String, String> {
  factory TagMap([String? tags]) => TagMap._(_parser.parse(tags ?? '').value);

  factory TagMap.from([Map<String, Object?>? other]) =>
      TagMap.fromIterable(other?.entries ?? []);

  factory TagMap.fromIterable(Iterable<MapEntry<String, Object?>> other) =>
      TagMap(
        other
            .map((entry) {
              final buffer = StringBuffer();
              buffer.write(entry.key);
              final value = entry.value?.toString();
              if (value != null && value.isNotEmpty) {
                buffer.write(':$value');
              }
              return buffer.toString();
            })
            .join(' '),
      );

  TagMap._([List<TagNode>? entries]) : _entries = entries ?? [];

  static final Parser<List<TagNode>> _parser = TagMapParserDefinition().build();

  final List<TagNode> _entries;

  List<String> get tags => _entries.map((tag) => tag.toString()).toList();

  @override
  String? operator [](Object? key) =>
      _entries.firstWhereOrNull((tag) => tag.name == key)?.value;

  @override
  void operator []=(String key, String? value) {
    final index = _entries.indexWhere((tag) => tag.name == key);
    if (index >= 0) {
      if (value == null || value.isEmpty) {
        _entries.removeAt(index);
      } else {
        _entries[index] = TagValue(key, value);
      }
    } else {
      _entries.add(TagValue(key, value));
    }
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
}

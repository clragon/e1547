import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:e1547/tag/tag.dart';
import 'package:meta/meta.dart';

/// Tiny utility class for quickly manipulating the top level of a tag string.
///
/// Note for any operation, tags inside a nested group will be entirely ignored.
/// However, the full structure is preserved when converting back to a string.
class TagMap extends MapBase<String, String> implements Map<String, String> {
  TagMap(String? tags) : _node = TagNode.parse(tags);

  TagNode _node;
  TagNode get node => _node;

  @override
  String? operator [](Object? key) => node.findValue(key.toString());

  @override
  void operator []=(String key, String? value) =>
      _node = node.replaceValue(key, value ?? '');

  @override
  void clear() => _node = const TagGroup(children: []);

  @override
  Iterable<String> get keys => switch (node) {
    final TagAtom atom => [atom.key],
    final TagGroup group => group.children.whereType<TagAtom>().map(
      (atom) => atom.key,
    ),
  };

  @override
  String? remove(Object? key) {
    TagAtom? target = switch (node) {
      final TagAtom atom => atom.key == key ? atom : null,
      final TagGroup group =>
        group.children.firstWhereOrNull((c) => c is TagAtom && c.key == key)
            as TagAtom?,
    };

    if (target == null) return null;

    _node = node.remove(target);
    return target.value;
  }

  @override
  String toString() => _node.toString();
}

extension _TagNodeOperations on TagNode {
  /// Returns true if the tag exists at the top level.
  bool contains(TagNode tag) {
    if (this == tag) return true;
    if (this is TagGroup) {
      return (this as TagGroup).children.contains(tag);
    }
    return false;
  }

  /// Adds a tag to a group or creates a group with self and the tag.
  @useResult
  TagNode add(TagNode tag) => switch (this) {
    final TagGroup group => group.copyWith(children: [...group.children, tag]),
    final TagAtom atom => TagGroup(children: [atom, tag]),
  };

  /// Removes the given tag from top-level children if found.
  @useResult
  // ignore: unused_element
  TagNode remove(TagNode tag) => switch (this) {
    final TagAtom atom => atom == tag ? const TagGroup(children: []) : this,
    final TagGroup group => group.copyWith(
      children: group.children.where((c) => c != tag).toList(),
    ),
  };

  /// Finds the value of a tag by its key at the top level.
  String findValue(String key) =>
      switch (this) {
        final TagAtom atom => atom.key == key ? atom.value : null,
        final TagGroup group =>
          group.children
              .map(
                (node) => switch (node) {
                  TagAtom() when node.key == key => node.value,
                  _ => null,
                },
              )
              .firstWhereOrNull((value) => value?.isNotEmpty ?? false),
      } ??
      '';

  /// Replaces the value of a tag by its key if it exists, or adds it if not.
  @useResult
  TagNode replaceValue(String key, String? newValue) => switch (this) {
    final TagAtom atom =>
      atom.key == key
          ? atom.copyWith(value: newValue)
          : add(TagAtom(key, newValue)),
    final TagGroup group =>
      group.contains(TagAtom(key, newValue))
          ? group.copyWith(
              children: group.children
                  .map(
                    (node) => switch (node) {
                      TagAtom() when node.key == key => node.copyWith(
                        value: newValue,
                      ),
                      _ => node,
                    },
                  )
                  .toList(),
            )
          : group.add(TagAtom(key, newValue)),
  };
}

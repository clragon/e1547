/// TODO: Make this easier to use
/// Currently, this provides fine parsing, however, manipulation of tags throughout the app should
/// be handled by some unified interface. Right now, this is too unwieldy to use to fill that role.
library;

import 'package:collection/collection.dart';
import 'package:e1547/tag/tag.dart';
import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

@immutable
sealed class TagNode implements Comparable<TagNode> {
  const TagNode({this.negated = false, this.optional = false});

  /// The parser used to parse tag strings into [TagNode]s.
  static final Parser<TagNode> _parser = TagGrammarDefinition()
      .build<TagNode>();

  /// Parses a string of tags into a [TagNode].
  static TagNode parse(String? tags) => _parser.parse(tags ?? '').value;

  /// Parses a list of tags into a [TagNode].
  static TagNode fromTags(Iterable<String> tags) =>
      TagNode.parse(tags.join(' '));

  /// Whether this tag is negated (e.g. `-tag`).
  final bool negated;

  /// Whether this tag is optional (e.g. `~tag`).
  final bool optional;

  /// Return a deep copy of this node.
  TagNode copyWith({bool? negated, bool? optional});

  /// Returns a list of this node's flattened tag atoms
  Iterable<TagAtom> get atoms;

  /// Returns a string representation of this node.
  /// The string representation should be parsable back into the same node.
  @override
  String toString({bool isRoot = true});

  /// Sorts by structure (group < atom), name, then value
  @override
  int compareTo(TagNode other);

  /// Deep equality
  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}

final class TagAtom extends TagNode {
  const TagAtom(this.key, this.value, {super.negated, super.optional});

  factory TagAtom.parse(String tag) {
    final node = TagNode.parse(tag);
    if (node is! TagAtom) {
      throw ArgumentError('Invalid tag: $tag');
    }
    return node;
  }

  final String key;
  final String? value;

  @override
  TagAtom copyWith({
    String? key,
    String? value,
    bool? negated,
    bool? optional,
  }) => TagAtom(
    key ?? this.key,
    value ?? this.value,
    negated: negated ?? this.negated,
    optional: optional ?? this.optional,
  );

  @override
  Iterable<TagAtom> get atoms => [this];

  @override
  int compareTo(TagNode other) {
    if (other is! TagAtom) return 1;

    final keyCompare = key.compareTo(other.key);
    if (keyCompare != 0) return keyCompare;

    return (value ?? '').compareTo(other.value ?? '');
  }

  @override
  bool operator ==(Object other) =>
      other is TagAtom &&
      key == other.key &&
      value == other.value &&
      negated == other.negated &&
      optional == other.optional;

  @override
  int get hashCode => Object.hash(key, value, negated, optional);

  @override
  String toString({bool isRoot = true}) {
    final buffer = StringBuffer();

    if (optional) buffer.write('~');
    if (negated) buffer.write('-');

    buffer.write(key);

    if (value != null) {
      buffer.write(':');
      final needsQuotes = value!.contains(' ');
      if (needsQuotes) buffer.write('"');
      buffer.write(needsQuotes ? value!.replaceAll('"', r'\"') : value);
      if (needsQuotes) buffer.write('"');
    }

    return buffer.toString();
  }
}

base class TagGroup extends TagNode {
  const TagGroup({required this.children, super.negated, super.optional});

  final List<TagNode> children;

  @override
  TagGroup copyWith({List<TagNode>? children, bool? negated, bool? optional}) =>
      TagGroup(
        children: children ?? this.children,
        negated: negated ?? this.negated,
        optional: optional ?? this.optional,
      );

  @override
  Iterable<TagAtom> get atoms => children.expand((c) => c.atoms);

  @override
  int compareTo(TagNode other) {
    if (other is TagAtom) return -1;
    if (other is! TagGroup) return 0;
    for (int i = 0; i < children.length; i++) {
      if (i >= other.children.length) return 1;
      final cmp = children[i].compareTo(other.children[i]);
      if (cmp != 0) return cmp;
    }
    return children.length.compareTo(other.children.length);
  }

  @override
  bool operator ==(Object other) =>
      other is TagGroup &&
      const ListEquality().equals(children, other.children) &&
      negated == other.negated &&
      optional == other.optional;

  @override
  int get hashCode => Object.hashAll(children) ^ Object.hash(negated, optional);

  @override
  String toString({bool isRoot = true}) {
    if (children.isEmpty) return '';

    final buffer = StringBuffer();
    if (optional) buffer.write('~');
    if (negated) buffer.write('-');

    if (!isRoot) buffer.write('( ');
    buffer.write(children.joinAndTrim());
    if (!isRoot) buffer.write(' )');

    return buffer.toString();
  }
}

extension _TagJoining on Iterable<TagNode> {
  /// Joins the string representations of the nodes, trimming each one and
  /// removing empty strings. This is necessary to remove empty groups.
  String joinAndTrim() => map(
    (node) => node.toString(isRoot: false).trim(),
  ).where((s) => s.isNotEmpty).join(' ');
}

extension TagNodeOperations on TagNode {
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
  TagNode remove(TagNode tag) => switch (this) {
    final TagAtom atom => atom == tag ? const TagGroup(children: []) : this,
    final TagGroup group => group.copyWith(
      children: group.children.where((c) => c != tag).toList(),
    ),
  };

  /// Removes a tag by its key from the top-level children if found.
  @useResult
  TagNode removeKey(String key) => switch (this) {
    final TagAtom atom => atom.key == key ? const TagGroup(children: []) : this,
    final TagGroup group => group.copyWith(
      children: group.children
          .where(
            (node) => switch (node) {
              TagAtom() when node.key != key => true,
              _ => false,
            },
          )
          .toList(),
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

  @useResult
  TagNode operator +(TagNode other) => add(other);
  @useResult
  TagNode operator -(TagNode other) => remove(other);
  @useResult
  TagNode operator <<(TagAtom tag) => replaceValue(tag.key, tag.value);
}

extension TagAtomOperations on TagAtom {
  @useResult
  TagNode operator >>(TagNode tag) => tag.replaceValue(key, value);
}

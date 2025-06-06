import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

@immutable
sealed class TagNode implements Comparable<TagNode> {
  const TagNode();

  String get name;
  String get value;
}

@immutable
final class TagValue extends TagNode {
  const TagValue(this.name, [String? value]) : value = value ?? '';

  factory TagValue.parse(String tag) {
    final result = tag.split(':');
    final value = result.length > 1 ? result.sublist(1).join(':') : null;
    return TagValue(result[0], value);
  }

  @override
  final String name;

  @override
  final String value;

  @override
  String toString({bool isRoot = true}) {
    final buffer = StringBuffer();
    buffer.write(name);

    if (value.isNotEmpty) {
      buffer.write(':');
      final needsQuotes = value.contains(' ');
      if (needsQuotes) buffer.write('"');
      buffer.write(needsQuotes ? value.replaceAll('"', r'\"') : value);
      if (needsQuotes) buffer.write('"');
    }

    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is TagValue && name == other.name && value == other.value;

  @override
  int get hashCode => Object.hash(name, value);

  @override
  int compareTo(TagNode other) {
    if (other is! TagValue) return -1;
    if (value.isEmpty && other.value.isNotEmpty) return 1;
    if (value.isNotEmpty && other.value.isEmpty) return -1;
    final nameCmp = name.compareTo(other.name);
    return nameCmp != 0 ? nameCmp : value.compareTo(other.value);
  }
}

@immutable
final class TagGroup extends TagNode {
  const TagGroup(this.prefix, this.children);

  final String prefix;
  final List<TagNode> children;

  @override
  String get name => '$prefix( ${children.join(' ')} )';

  @override
  String get value => '';

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      other is TagGroup &&
      prefix == other.prefix &&
      const ListEquality<TagNode>().equals(children, other.children);

  @override
  int get hashCode =>
      Object.hash(prefix, const ListEquality<TagNode>().hash(children));

  @override
  int compareTo(TagNode other) {
    if (other is! TagGroup) return 1;
    return name.compareTo(other.name);
  }
}

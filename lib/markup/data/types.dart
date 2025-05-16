import 'package:flutter/material.dart';

/// Used to identify text segments with unique keys.
///
/// TextSpans cannot contain state as they are not widgets.
/// WidgetSpans can contain state, but they may be disposed early.
/// To identify spoilers and sections, we therefore use this class.
@immutable
class DTextId {
  const DTextId({required this.start, required this.end});

  final int start;
  final int end;

  @override
  String toString() => 'DTextId(start: $start, end: $end)';

  @override
  bool operator ==(Object other) =>
      other is DTextId && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);

  /// Whether this id spans accross the other id.
  bool contains(DTextId other) => start <= other.start && end >= other.end;

  /// Whether this id's span is contained by the other id.
  bool isContainedBy(DTextId other) => other.contains(this);
}

@immutable
sealed class DTextElement {
  const DTextElement();
}

class DTextElements extends DTextElement {
  const DTextElements(this.elements);

  final List<DTextElement> elements;

  @override
  String toString() => 'Elements($elements)';
}

class DTextContent extends DTextElement {
  const DTextContent(this.content);

  final String content;

  @override
  String toString() => 'Text(${content.replaceAll('\r\n', r'\n')})';

  DTextContent operator +(DTextContent other) =>
      DTextContent(content + other.content);
}

sealed class DTextBlock extends DTextElement {
  const DTextBlock(this.children);

  final DTextElement children;
}

class DTextBold extends DTextBlock {
  const DTextBold(super.children);

  @override
  String toString() => 'Bold($children)';
}

class DTextItalic extends DTextBlock {
  const DTextItalic(super.children);

  @override
  String toString() => 'Italic($children)';
}

class DTextOverline extends DTextBlock {
  const DTextOverline(super.children);

  @override
  String toString() => 'Overline($children)';
}

class DTextUnderline extends DTextBlock {
  const DTextUnderline(super.children);

  @override
  String toString() => 'Underline($children)';
}

class DTextStrikethrough extends DTextBlock {
  const DTextStrikethrough(super.children);

  @override
  String toString() => 'Strikethrough($children)';
}

class DTextSuperscript extends DTextBlock {
  const DTextSuperscript(super.children);

  @override
  String toString() => 'Superscript($children)';
}

class DTextSubscript extends DTextBlock {
  const DTextSubscript(super.children);

  @override
  String toString() => 'Subscript($children)';
}

class DTextSpoiler extends DTextBlock {
  const DTextSpoiler(this.id, super.children);

  final DTextId id;

  @override
  String toString() => 'Spoiler($children)';
}

class DTextQuote extends DTextBlock {
  const DTextQuote(super.children);

  @override
  String toString() => 'Quote($children)';
}

class DTextCode extends DTextBlock {
  const DTextCode(super.children);

  @override
  String toString() => 'Code($children)';
}

class DTextSection extends DTextBlock {
  const DTextSection(this.id, this.title, this.expanded, super.children);

  final DTextId? id;
  final String? title;
  final bool expanded;

  @override
  String toString() => 'Section($title, $expanded, $children)';
}

class DTextColor extends DTextBlock {
  const DTextColor(this.color, super.children);

  final String color;

  @override
  String toString() => 'Color($color, $children)';
}

class DTextInlineCode extends DTextElement {
  const DTextInlineCode(this.content);

  final String content;

  @override
  String toString() => 'InlineCode($content)';
}

enum LinkWord {
  post,
  forum,
  topic,
  comment,
  user,
  blip,
  pool,
  set,
  takedown,
  record,
  ticket,
  thumb;

  String toLink(int id) {
    switch (this) {
      case thumb:
      case post:
        return '/posts/$id';
      case pool:
        return '/pools/$id';
      case user:
        return '/users/$id';
      case forum:
        return '/forum_posts/$id';
      case topic:
        return '/forum_topics/$id';
      case comment:
        return '/comments/$id';
      case set:
        return '/post_sets/$id';
      case record:
        return '/user_feedbacks/$id';
      case blip:
        return '/blips/$id';
      case ticket:
        return '/tickets/$id';
      case takedown:
        return '/takedowns/$id';
    }
  }
}

class DTextHeader extends DTextBlock {
  const DTextHeader(this.level, super.children);

  final int level;

  @override
  String toString() => 'Header($level, $children)';
}

class DTextBullet extends DTextBlock {
  const DTextBullet(this.indent, super.children);

  final int indent;

  @override
  String toString() => 'Bullet($indent, $children)';
}

class DTextList extends DTextElement {
  const DTextList(this.items);

  final List<DTextBullet> items;

  @override
  String toString() => 'List($items)';
}

class DTextLinkWord extends DTextElement {
  const DTextLinkWord(this.type, this.id);

  final LinkWord type;
  final int id;

  @override
  String toString() => 'LinkWord($type, $id)';
}

class DTextLink extends DTextElement {
  const DTextLink(this.name, this.link);

  final DTextElement? name;
  final String link;

  @override
  String toString() => 'Link($name, $link)';
}

class DTextLocalLink extends DTextElement {
  const DTextLocalLink(this.name, this.link);

  final DTextElement name;
  final String link;

  @override
  String toString() => 'LocalLink($name, $link)';
}

class DTextTagLink extends DTextElement {
  const DTextTagLink(this.name, this.tag);

  final String? name;
  final String tag;

  @override
  String toString() => 'TagLink($name, $tag)';
}

class DTextTagSearchLink extends DTextElement {
  const DTextTagSearchLink(this.tags);

  final String tags;

  @override
  String toString() => 'TagSearchLink($tags)';
}

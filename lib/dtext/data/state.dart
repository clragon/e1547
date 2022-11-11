import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
class TextState with _$TextState {
  const factory TextState({
    @Default(false) bool bold,
    @Default(false) bool italic,
    @Default(false) bool strikeout,
    @Default(false) bool underline,
    @Default(false) bool overline,
    @Default(false) bool header,
    @Default(false) bool link,
    @Default(false) bool highlight,
    @Default(false) bool spoiler,
    VoidCallback? onTap,
  }) = _TextState;
}

enum TextStateTag {
  b,
  i,
  u,
  o,
  s,
  color,
  sup,
  sub,
  spoiler,
}

enum TextBlock {
  code,
  section,
  quote,
}

class TextTag {
  TextTag({
    required this.before,
    required this.tag,
    required this.after,
    required this.key,
    required this.active,
    required this.expanded,
    required this.value,
  });

  factory TextTag.fromMatch(RegExpMatch match) {
    return TextTag(
      before: match.input.substring(0, match.start),
      tag: match.input.substring(match.start, match.end),
      after: match.input.substring(match.end),
      key: match.namedGroup('tag')!.toLowerCase(),
      active: match.namedGroup('closing') == null,
      expanded: match.namedGroup('expanded') != null,
      value: match.namedGroup('value'),
    );
  }

  final String before;
  final String tag;
  final String after;
  final String key;
  final bool active;
  final bool expanded;
  final String? value;

  static String _singleBrackets(String value) => [
        r'(?<!\[)', // prevent double brackets
        r'(?<!\\)', // prevent escaped brackets
        r'\[', // opening backet
        value,
        r'\]', // closing bracket
        r'(?!\])', // prevent double brackets
      ].join();

  static String _blockTag(String value) => _singleBrackets(
        [
          r'(?<closing>\/)?', // read closing
          value,
          r'(?<expanded>,expanded)?', // read expanded
          r'(=(?<value>(.|\n)*?))?', // read value
        ].join(),
      );

  static const String _anyName = r'(?<tag>[\w\d]+?)';

  static RegExp toRegex([String? name]) {
    String nameMatch = _anyName;
    if (name != null) {
      nameMatch = r'(?<tag>' + RegExp.escape(name) + r')';
    }
    return RegExp(
      _blockTag(
        nameMatch, // read tag
      ),
      caseSensitive: false,
    );
  }

  static TextTag? firstMatch(String text, {String? name}) {
    RegExpMatch? match = toRegex(name).firstMatch(text);
    if (match != null) {
      return TextTag.fromMatch(match);
    } else {
      return null;
    }
  }

  static List<TextTag> allMatches(String text, {String? name}) {
    return toRegex(name).allMatches(text).map(TextTag.fromMatch).toList();
  }
}

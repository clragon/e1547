import 'package:flutter/material.dart';

@immutable
sealed class TextState {
  const TextState();
}

class TextStateBold extends TextState {}

class TextStateItalic extends TextState {}

class TextStateStrikeout extends TextState {}

class TextStateUnderline extends TextState {}

class TextStateOverline extends TextState {}

class TextStateInlineCode extends TextState {}

class TextStateColor extends TextState {
  const TextStateColor(this.color);

  final String color;
}

class TextStateSuperText extends TextState {}

class TextStateSubText extends TextState {}

class TextStateHeader extends TextState {
  const TextStateHeader(this.size);

  final int size;
}

class TextStateLink extends TextState {
  const TextStateLink(this.onTap);

  final VoidCallback? onTap;
}

class TextStateSpoiler extends TextState {
  const TextStateSpoiler(this.text);

  final String text;
}

@immutable
class TextStateStack {
  const TextStateStack([List<TextState>? states])
      : _states = states ?? const [];

  /// The list of states in this stack.
  final List<TextState> _states;

  /// Retrieves the closest instance of a state [T].
  T? getClosest<T extends TextState>() {
    List<T> targets = _states.whereType<T>().toList();
    if (targets.isEmpty) return null;
    return targets.last;
  }

  /// Retrieves the all instances of a state [T].
  List<T> getAll<T extends TextState>() => _states.whereType<T>().toList();

  /// Checks whether the Stack has a certain state [T].
  bool hasState<T extends TextState>() => getClosest<T>() != null;

  /// Adds a new TextState to the stack.
  TextStateStack push(TextState state) => TextStateStack(
        List.of(_states)..add(state),
      );

  /// Removes the last inserted State if it is of Type [T].
  /// Otherwise, nothing happens.
  TextStateStack pop<T extends TextState>() {
    if (_states.isNotEmpty && _states.last is T) {
      return TextStateStack(
        List.of(_states)..remove(_states.last),
      );
    }
    return this;
  }
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

@immutable
class TextTag {
  const TextTag({
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

  @override
  String toString() => '$tag$after';

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

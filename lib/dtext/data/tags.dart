class TextState {
  bool bold;
  bool italic;
  bool strikeout;
  bool underline;
  bool overline;
  bool header;
  bool link;

  TextState({
    required this.bold,
    required this.italic,
    required this.strikeout,
    required this.underline,
    required this.overline,
    required this.header,
    required this.link,
  });

  TextState copyWith({
    bool? bold,
    bool? italic,
    bool? strikeout,
    bool? underline,
    bool? overline,
    bool? header,
    bool? link,
    bool? dark,
  }) =>
      TextState(
        bold: bold ?? this.bold,
        italic: italic ?? this.italic,
        strikeout: strikeout ?? this.strikeout,
        underline: underline ?? this.underline,
        overline: overline ?? this.overline,
        header: header ?? this.header,
        link: link ?? this.link,
      );
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
}

enum TextBlock {
  spoiler,
  code,
  section,
  quote,
}

class TextTag {
  final String before;
  final String tag;
  final String after;
  final String key;
  final bool active;
  final bool expanded;
  final String? value;

  TextTag({
    required this.before,
    required this.tag,
    required this.after,
    required this.key,
    required this.active,
    required this.expanded,
    required this.value,
  });

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

  static final String _anyName = r'(?<tag>[\w\d]+?)';

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

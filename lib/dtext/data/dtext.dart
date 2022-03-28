import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/material.dart';

final List<DTextParser> allParsers = [
  blockParser,
  tagParser,
  codeParser,
  anchorParser,
  searchParser,
  listParser,
  headerParser,
  linkParser,
  localLinkParser,
  ...linkWordParsers(),
];

InlineSpan parseDText(BuildContext context, String text, TextState state,
    {List<DTextParser>? parsers}) {
  parsers ??= allParsers;

  if (text.isEmpty) {
    return TextSpan();
  }

  List<InlineSpan> spans = [];

  Map<RegExpMatch, DTextParser> eligible = {};

  for (final parser in parsers) {
    RegExpMatch? match = parser.regex.firstMatch(text);
    if (match != null) {
      eligible[match] = parser;
    }
  }

  if (eligible.isEmpty) {
    return plainText(context: context, text: text, state: state);
  }

  List<MapEntry<RegExpMatch, DTextParser>> sorted = eligible.entries.toList()
    ..sort((a, b) {
      int result = a.key.start.compareTo(b.key.start);
      if (result == 0) {
        result = parsers!.indexOf(a.value).compareTo(parsers.indexOf(b.value));
      }
      return result;
    });

  sorted.removeWhere((element) => sorted.first.key.start != element.key.start);

  DTextParserResult? result;

  for (final entry in sorted) {
    result = entry.value.tranformer(context, entry.key, state.copyWith());
    if (result != null) {
      spans.addAll([
        plainText(context: context, text: entry.key.before, state: state),
        result.span,
        parseDText(context, result.text, result.state),
      ]);
      break;
    }
  }

  if (result == null) {
    String before = text.substring(0, sorted.first.key.start + 1);
    String after = text.substring(sorted.first.key.start + 1);
    spans.addAll([
      plainText(context: context, text: before, state: state),
      parseDText(context, after, state),
    ]);
  }

  return TextSpan(
    children: spans,
  );
}

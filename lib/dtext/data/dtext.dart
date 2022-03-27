import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/material.dart';

final List<DTextParser> allParsers = [
  blockParser,
  tagParser,
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
    spans.add(plainText(context: context, text: text, state: state));
  }

  return TextSpan(
    children: spans,
  );
}

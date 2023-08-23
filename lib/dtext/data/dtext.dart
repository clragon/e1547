import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/material.dart';

InlineSpan parseDText(BuildContext context, String text, TextStateStack state,
    {List<DTextParser>? parsers}) {
  parsers ??= [
    DTextBlockParser(),
    DTextTagParser(),
    DTextCodeParser(),
    DTextAnchorParser(),
    DTextSearchParser(),
    DTextListParser(),
    DTextHeaderParser(),
    DTextLinkParser(),
    DTextLocalLinkParser(),
    DTextLinkWordParser(),
  ];

  if (text.isEmpty) {
    return const TextSpan();
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
    result = entry.value.transform(context, entry.key, state);
    if (result != null) {
      spans.addAll([
        if (entry.key.before.isNotEmpty)
          plainText(context: context, text: entry.key.before, state: state),
        result.span,
        if (entry.key.after.isNotEmpty)
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

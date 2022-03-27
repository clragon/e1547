import 'package:e1547/dtext/data/block.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

// parse string recursively
InlineSpan parseDText(BuildContext context, String text, TextState state) {
  // no text, empty span
  if (text.isEmpty) {
    return TextSpan();
  }

  Map<RegExp, DTextParser> regexes = {
    TextTag.toRegex(): parseBlocks,
    RegExp(r'\[\[(?<anchor>#)?(?<tags>.*?)(\|(?<name>.*?))?\]\]'):
        (context, match, result, state) {
      bool anchor = match.namedGroup('anchor') != null;
      String tags = match.namedGroup('tags')!;
      String name = match.namedGroup('name') ?? tags;

      tags = tags.replaceAll(' ', '_');

      VoidCallback? onTap;

      if (!anchor) {
        onTap = () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SearchPage(tags: tags),
              ),
            );
      }

      return plainText(
        context: context,
        text: name,
        state: state.copyWith(link: true),
        onTap: onTap,
      );
    },
    RegExp(r'{{(?<tags>.*?)(\|(?<name>.*?))?}}'):
        (context, match, result, state) {
      String? tags = match.namedGroup('tags');
      String name = match.namedGroup('name') ?? tags!;

      return plainText(
        context: context,
        text: name,
        state: state.copyWith(link: true),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchPage(tags: tags),
          ),
        ),
      );
    },
    RegExp(r'(^|\n)(?<dots>\*+) '): (context, match, result, state) {
      return parseDText(context,
          '\n' + '  ' * ('*'.allMatches(result).length - 1) + '• ', state);
    },
    RegExp(r'h[1-6]\.\s?(?<name>.*)', caseSensitive: false):
        (context, match, result, state) {
      return parseDText(
        context,
        match.namedGroup('name')!,
        state.copyWith(header: true),
      );
    },
    ...linkRegexes(context),
    ...linkWordRegexes(context),
  };

  // list of spans that will be returned
  List<InlineSpan> spans = [];

  for (final entry in regexes.entries) {
    for (RegExpMatch otherMatch in entry.key.allMatches(text)) {
      String before = text.substring(0, otherMatch.start);
      String result = text.substring(otherMatch.start, otherMatch.end);
      String after = text.substring(otherMatch.end, text.length);

      spans.addAll([
        parseDText(context, before, state),
        entry.value(context, otherMatch, result, state),
        parseDText(context, after, state),
      ]);

      return TextSpan(
        children: spans,
      );
    }
  }

  // no matching brackets, return normal text
  return plainText(context: context, text: text, state: state);
}

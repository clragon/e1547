import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:username_generator/username_generator.dart';

// parse string recursively
InlineSpan parseDText(BuildContext context, String text, TextState state,
    {UsernameGenerator? usernameGenerator}) {
  // list of spans that will be returned
  List<InlineSpan> spans = [];

  // no text, empty span
  if (text.isEmpty) {
    return TextSpan();
  }

  TextTag? tag = TextTag.firstMatch(text);
  if (tag != null) {
    String after = tag.after;
    String before = tag.before;

    TextBlock? block = TextBlock.values.asNameMap()[tag.key];
    TextStateTag? stateTag = TextStateTag.values.asNameMap()[tag.key];

    if (block != null && tag.active) {
      List<TextTag> others = TextTag.allMatches(after, name: tag.key);

      TextTag? end;

      int openTagCounter = 0;
      for (final other in others) {
        if (other.active) {
          openTagCounter++;
        } else {
          openTagCounter--;
        }
        if (openTagCounter == -1) {
          end = other;
          break;
        }
      }

      String between;

      if (end != null) {
        between = end.before;
        after = end.after;
      } else {
        between = after;
        after = '';
      }

      between = between.replaceAllMapped(blankless, (_) => '');

      Widget blocked;

      switch (block) {
        case TextBlock.spoiler:
          blocked = SpoilerWrap(
            child: Text.rich(parseDText(context, between, state)),
          );
          break;
        case TextBlock.code:
          blocked = QuoteWrap(
            child: Text.rich(
                plainText(context: context, text: between, state: state)),
          );
          break;
        case TextBlock.section:
          blocked = SectionWrap(
            child: Text.rich(parseDText(context, between, state)),
            title: tag.value,
            expanded: tag.expanded,
          );
          break;
        case TextBlock.quote:
          blocked = QuoteWrap(
            child: Text.rich(parseDText(context, between, state)),
          );
          break;
      }

      // remove all the spaces around blocks
      before = before.replaceAllMapped(RegExp(r'[ \n]*$'), (_) => '');
      after = after.replaceAllMapped(RegExp(r'^[ \n]*'), (_) => '');

      spans.addAll([
        parseDText(context, before, state),
        WidgetSpan(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: blocked,
          ),
        ),
        parseDText(context, after, state),
      ]);
    } else if (stateTag != null) {
      TextState updated = state.copyWith();

      // add textStyle
      switch (stateTag) {
        case TextStateTag.b:
          updated.bold = tag.active;
          break;
        case TextStateTag.i:
          updated.italic = tag.active;
          break;
        case TextStateTag.u:
          updated.underline = tag.active;
          break;
        case TextStateTag.o:
          // not supported on the site.
          // updated.overline = active;
          break;
        case TextStateTag.s:
          updated.strikeout = tag.active;
          break;
        case TextStateTag.color:
          // I cannot be bothered.
          break;
        case TextStateTag.sup:
          // I have no idea how to implement this.
          break;
        case TextStateTag.sub:
          // I have no idea how to implement this.
          break;
      }

      spans.addAll([
        parseDText(context, before, state),
        parseDText(context, after, updated),
      ]);
    } else {
      spans.add(parseDText(context, '$before${escape(tag.tag)}$after', state));
    }

    return TextSpan(
      children: spans,
    );
  }

  Map<RegExp, DTextParser> regexes = {
    RegExp(r'\[\[(?<anchor>#)?(?<tags>.*?)(\|(?<name>.*?))?\]\]'):
        (match, result, state) {
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
    RegExp(r'{{(?<tags>.*?)(\|(?<name>.*?))?}}'): (match, result, state) {
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
    RegExp(r'(^|\n)(?<dots>\*+) '): (match, result, state) {
      return parseDText(context,
          '\n' + '  ' * ('*'.allMatches(result).length - 1) + '• ', state);
    },
    RegExp(r'h[1-6]\.\s?(?<name>.*)', caseSensitive: false):
        (match, result, state) {
      return parseDText(
        context,
        match.namedGroup('name')!,
        state.copyWith(header: true),
      );
    },
    ...linkRegexes(context, usernameGenerator),
    ...linkWordRegexes(context),
  };

  for (final entry in regexes.entries) {
    for (RegExpMatch otherMatch in entry.key.allMatches(text)) {
      String before = text.substring(0, otherMatch.start);
      String result = text.substring(otherMatch.start, otherMatch.end);
      String after = text.substring(otherMatch.end, text.length);

      spans.addAll([
        parseDText(context, before, state),
        entry.value(otherMatch, result, state),
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

import 'package:collection/collection.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:username_generator/username_generator.dart';

typedef DTextParser = InlineSpan Function(
    RegExpMatch match, String result, TextState state);

class DText extends StatelessWidget {
  final String source;
  final bool dark;
  final UsernameGenerator? usernameGenerator;

  const DText(this.source, {this.dark = false, this.usernameGenerator});

  @override
  Widget build(BuildContext context) {
    // parse string recursively
    TextSpan resolve(String text, TextState state) {
      // list of spans that will be returned
      List<InlineSpan> spans = [];

      // no text, empty span
      if (text.isEmpty) {
        return TextSpan();
      }

      RegExpMatch? bracketMatch = anyBlockTag.firstMatch(text);
      if (bracketMatch != null) {
        // string before bracket
        String before = text.substring(0, bracketMatch.start);
        // string inside bracket
        String tag = text.substring(bracketMatch.start, bracketMatch.end);
        // string after bracket
        String after = text.substring(bracketMatch.end);

        // the key of the tag
        String key = bracketMatch.namedGroup('tag')!.toLowerCase();
        // whether the tag is closing
        bool active = bracketMatch.namedGroup('closing') == null;
        // whether section tag is expanded
        bool expanded = bracketMatch.namedGroup('expanded') != null;
        // the value of the tag
        String? value = bracketMatch.namedGroup('value');

        // block tag check.
        Widget? blocked;

        if ([
              'spoiler',
              'code',
              'section',
              'quote',
            ].contains(key) &&
            active) {
          RegExp start = RegExp(
            blockTag([
              RegExp.escape(key),
            ].join()),
            caseSensitive: false,
          );

          RegExp end = RegExp(
            singleBrackets([
              r'\/',
              RegExp.escape(key),
            ].join()),
            caseSensitive: false,
          );

          Match? endMatch = end.allMatches(after).firstWhereOrNull((match) {
            String container = after.substring(0, match.start);
            return start.allMatches(container).length ==
                end.allMatches(container).length;
          });

          int splitStart;
          int splitEnd;

          if (endMatch != null) {
            splitStart = endMatch.start;
            splitEnd = endMatch.end;
          } else {
            splitStart = after.length;
            splitEnd = after.length;
          }

          String between = after
              .substring(0, splitStart)
              .replaceAllMapped(blankless, (_) => '');

          after = after.substring(splitEnd);

          switch (key) {
            case 'spoiler':
              blocked = SpoilerWrap(
                child: RichText(
                  text: resolve(between, state),
                ),
              );
              break;
            case 'code':
              blocked = QuoteWrap(
                child: RichText(
                  text:
                      plainText(context: context, text: between, state: state),
                ),
              );
              break;
            case 'quote':
              blocked = QuoteWrap(
                child: RichText(
                  text: resolve(between, state),
                ),
              );
              break;
            case 'section':
              blocked = SectionWrap(
                  child: RichText(
                    text: resolve(between, state),
                  ),
                  title: value,
                  expanded: expanded);
              break;
          }
        }

        if (blocked != null) {
          // remove all the spaces around blocks
          before = before.replaceAllMapped(RegExp(r'[ \n]*$'), (_) => '');
          after = after.replaceAllMapped(RegExp(r'^[ \n]*'), (_) => '');

          spans.addAll([
            resolve(before, state),
            WidgetSpan(child: blocked),
            resolve(after, state),
          ]);
        } else {
          TextState newState = state.copyWith();
          bool triggered = true;

          // add textStyle
          switch (key) {
            case 'b':
              newState.bold = active;
              break;
            case 'i':
              newState.italic = active;
              break;
            case 'u':
              newState.underline = active;
              break;
            case 'o':
              // not supported on the site.
              // newState.overline = active;
              break;
            case 's':
              newState.strikeout = active;
              break;
            case 'color':
              // I cannot be bothered.
              break;
            case 'sup':
              // I have no idea how to implement this.
              break;
            case 'sub':
              // I have no idea how to implement this.
              break;
            default:
              triggered = false;
              break;
          }

          if (triggered) {
            spans.addAll([
              resolve(before, state),
              resolve(after, newState),
            ]);
          } else {
            spans.add(resolve('$before${escape(tag)}$after', state));
          }
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
            onTap = () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(tags: tags)));
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
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SearchPage(tags: tags)),
              );
            },
          );
        },
        RegExp(r'(^|\n)\*+ '): (match, result, state) {
          return resolve(
              '\n' + '  ' * ('*'.allMatches(result).length - 1) + '• ', state);
        },
        RegExp(r'h[1-6]\.\s?(?<name>.*)', caseSensitive: false):
            (match, result, state) {
          return resolve(
            match.namedGroup('name')!,
            state.copyWith(header: true),
          );
        },
        ...linkRegexes(context, usernameGenerator),
        ...linkWordRegexes(context),
      };

      for (MapEntry<RegExp, DTextParser> entry in regexes.entries) {
        for (RegExpMatch otherMatch in entry.key.allMatches(text)) {
          String before = text.substring(0, otherMatch.start);
          String result = text.substring(otherMatch.start, otherMatch.end);
          String after = text.substring(otherMatch.end, text.length);

          spans.addAll([
            resolve(before, state),
            entry.value(otherMatch, result, state),
            resolve(after, state),
          ]);

          return TextSpan(
            children: spans,
          );
        }
      }

      // no matching brackets, return normal text
      return plainText(context: context, text: text, state: state);
    }

    // keep track of textStyle
    TextState state = TextState(
      bold: false,
      italic: false,
      strikeout: false,
      underline: false,
      overline: false,
      header: false,
      link: false,
      dark: dark,
    );

    String result = source.replaceAllMapped(RegExp(r'\r\n'), (_) => '\n');
    result = result.trim();

    try {
      return RichText(
        text: resolve(result, state),
      );
    } catch (_) {
      if (kDebugMode) {
        rethrow;
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.warning_amber_outlined,
              color: Colors.red,
              size: 20,
            ),
          ),
          Text('DText parsing has failed', style: TextStyle(color: Colors.red)),
        ],
      );
    }
  }
}

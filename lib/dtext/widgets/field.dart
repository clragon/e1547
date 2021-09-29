import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:username_generator/username_generator.dart';

class DTextField extends StatelessWidget {
  final String source;
  final bool dark;
  final UsernameGenerator? usernameGenerator;

  DTextField({required this.source, this.dark = false, this.usernameGenerator});

  @override
  Widget build(BuildContext context) {
    // parse string recursively
    TextSpan resolve(String text, Map<TextState, bool> state) {
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
          Map<TextState, bool> newState = Map.from(state);
          bool triggered = true;

          // add textStyle
          switch (key) {
            case 'b':
              newState[TextState.bold] = active;
              break;
            case 'i':
              newState[TextState.italic] = active;
              break;
            case 'u':
              newState[TextState.underline] = active;
              break;
            case 'o':
              // not supported on the site.
              // newState[TextState.overline] = active;
              break;
            case 's':
              newState[TextState.strikeout] = active;
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

      InlineSpan parseLink(RegExpMatch match, String result,
          [bool insite = false]) {
        String? display = match.namedGroup('name');
        String search = match.namedGroup('link')!;
        String siteMatch = r'((e621|e926)\.net)?';
        VoidCallback onTap = () => launch(search);
        int? id = int.tryParse(search.split('/').last.split('?').first);

        if (display == null) {
          display = match.namedGroup('link');
          display = linkToDisplay(display!);
        }

        if (insite) {
          onTap = () async => launch('https://${settings.host.value}$search');

          // forum topics need generated names
          if (usernameGenerator != null) {
            RegExp userReg = RegExp(r'/user(s|/show)/(?<id>\d+)');
            RegExpMatch? userMatch = userReg.firstMatch(search);
            if (userMatch != null) {
              onTap = () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      SearchPage(tags: match.namedGroup('name'))));
              int id = int.parse(userMatch.namedGroup('id')!);
              display = usernameGenerator!.generate(id);
            }
          }
        }

        Map<RegExp, Function Function(RegExpMatch match)> links = {
          RegExp(siteMatch + r'/posts/\d+'): (match) => () async {
                Post p = await client.post(id!);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PostDetail(post: p)));
              },
          RegExp(siteMatch + r'/pool(s|/show)/\d+'): (match) => () async {
                Pool p = await client.pool(id!);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PoolPage(pool: p)));
              },
        };

        for (MapEntry<RegExp, Function(RegExpMatch match)> entry
            in links.entries) {
          RegExpMatch? match = entry.key.firstMatch(result);
          if (match != null) {
            onTap = entry.value(match);
            break;
          }
        }

        return plainText(
            context: context,
            text: display,
            state: Map.from(state)..[TextState.link] = true,
            onTap: onTap);
      }

      InlineSpan parseWord(LinkWord? word, RegExpMatch match, String result) {
        VoidCallback? onTap;

        switch (word) {
          case LinkWord.thumb:
          // add actual pictures here some day.
          case LinkWord.post:
            onTap = () async {
              Post p = await client.post(int.parse(match.namedGroup('id')!));
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PostDetail(post: p);
              }));
            };
            break;
          case LinkWord.pool:
            onTap = () async {
              Pool p = await client.pool(int.parse(match.namedGroup('id')!));
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PoolPage(pool: p);
              }));
            };
            break;
          default:
            break;
        }

        return plainText(
            context: context,
            text: result,
            state: Map.from(state)..[TextState.link] = true,
            onTap: onTap);
      }

      Map<RegExp, InlineSpan Function(RegExpMatch match, String result)>
          regexes = {
        RegExp(r'\[\[(?<anchor>#)?(?<tags>.*?)(\|(?<name>.*?))?\]\]'):
            (match, result) {
          bool anchor = match.namedGroup('anchor') != null;
          String? tags = match.namedGroup('tags');
          String name = match.namedGroup('name') ?? tags!;

          VoidCallback? onTap;

          if (!anchor) {
            onTap = () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(tags: tags)));
          }

          return plainText(
              context: context,
              text: name,
              state: Map.from(state)..[TextState.link] = true,
              onTap: onTap);
        },
        RegExp(r'{{(?<tags>.*?)(\|(?<name>.*?))?}}'): (match, result) {
          String? tags = match.namedGroup('tags');
          String name = match.namedGroup('name') ?? tags!;

          VoidCallback onTap = () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(tags: tags)));
          };

          return plainText(
              context: context,
              text: name,
              state: Map.from(state)..[TextState.link] = true,
              onTap: onTap);
        },
        RegExp(r'(^|\n)\*+ '): (match, result) {
          return resolve(
              '\n' + '  ' * ('*'.allMatches(result).length - 1) + '• ', state);
        },
        RegExp(r'h[1-6]\.\s?(?<name>.*)', caseSensitive: false):
            (match, result) {
          return resolve(
            match.namedGroup('name')!,
            Map.from(state)..[TextState.header] = true,
          );
        },
        RegExp(linkWrap(
            r'(?<link>(http(s)?)?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))',
            false)): parseLink,
        RegExp(linkWrap(r'(?<link>[-a-zA-Z0-9()@:%_\+.~#?&//=]*)')):
            (match, result) => parseLink(match, result, true),
        ...Map.fromIterable(LinkWord.values,
            key: (word) => RegExp(
                RegExp.escape(describeEnum(word)) + r' #(?<id>\d+)',
                caseSensitive: false),
            value: (word) => (match, result) => parseWord(word, match, result)),
      };

      for (MapEntry<RegExp, Function(RegExpMatch match, String result)> entry
          in regexes.entries) {
        for (RegExpMatch otherMatch in entry.key.allMatches(text)) {
          String before = text.substring(0, otherMatch.start);
          String result = text.substring(otherMatch.start, otherMatch.end);
          String after = text.substring(otherMatch.end, text.length);

          spans.addAll([
            resolve(before, state),
            entry.value(otherMatch, result),
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

    // Map to keep track of textStyle
    Map<TextState, bool> state = {
      TextState.bold: false,
      TextState.italic: false,
      TextState.strikeout: false,
      TextState.underline: false,
      TextState.overline: false,
      TextState.header: false,
      TextState.link: false,
      TextState.dark: dark,
    };

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

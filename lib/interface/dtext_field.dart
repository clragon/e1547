import 'package:e1547/client.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DTextField extends StatelessWidget {
  final String msg;
  final bool darkText;

  DTextField({@required this.msg, this.darkText = false});

  @override
  Widget build(BuildContext context) {
    // wrapper widget for quotes
    Widget quoteWrap(Widget child) {
      return Card(
        color: Theme.of(context).canvasColor,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [child],
              ),
            ),
          ]),
        ),
      );
    }

    // wrapper widget for sections
    Widget sectionWrap(
        {@required Widget child, String title, bool expanded = false}) {
      title = title.replaceAllMapped(RegExp(r'\n'), (_) => '');
      return Card(
          color: Theme.of(context).canvasColor,
          child: ExpandableNotifier(
            initialExpanded: expanded,
            child: ExpandableTheme(
              data: ExpandableThemeData(
                headerAlignment: ExpandablePanelHeaderAlignment.center,
                iconColor: Theme.of(context).iconTheme.color,
              ),
              child: ExpandablePanel(
                header: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                collapsed: Container(),
                expanded: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [child],
                  ),
                ),
              ),
            ),
          ));
    }

    Widget spoilerWrap(Widget child) {
      ValueNotifier<bool> isShown = ValueNotifier(false);
      return Card(
          child: InkWell(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [child],
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: ValueListenableBuilder(
                valueListenable: isShown,
                builder: (context, value, child) {
                  return AnimatedOpacity(
                    opacity: value ? 0 : 1,
                    duration: Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text('SPOILER',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
        onTap: () => isShown.value = !isShown.value,
      ));
    }

    // parse string recursively
    TextSpan resolve(String source, Map<TextState, bool> state) {
      // get string in plain text. no parsing.
      TextSpan getText(String msg, Map<TextState, bool> states,
          {Function() onTap}) {
        msg = msg.replaceAll('\\[', '[');
        msg = msg.replaceAllMapped(RegExp(r'\n{4,}'), (_) => '\n');

        return TextSpan(
          text: msg,
          recognizer: TapGestureRecognizer()..onTap = onTap,
          style: TextStyle(
            color: states[TextState.link]
                ? Colors.blue[400]
                : darkText
                    ? Theme.of(context)
                        .textTheme
                        .bodyText1
                        .color
                        .withOpacity(0.5)
                    : Theme.of(context).textTheme.bodyText1.color,
            fontWeight: states[TextState.bold] ? FontWeight.bold : null,
            fontStyle: states[TextState.italic] ? FontStyle.italic : null,
            fontSize: states[TextState.header] ? 18 : null,
            decoration: TextDecoration.combine([
              states[TextState.strikeout]
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              states[TextState.underline]
                  ? TextDecoration.underline
                  : TextDecoration.none,
              states[TextState.overline]
                  ? TextDecoration.overline
                  : TextDecoration.none,
            ]),
          ),
        );
      }

      // list of widgets that will be returned
      List<InlineSpan> spans = [];

      // test for brackets
      RegExp bracketRex = RegExp([
        r'(?<!\[)', // prevent double brackets
        r'(?<!\\)', // prevent escaped brackets
        r'\[', // opening backet
        r'(?<closing>\/)?', // read closing
        r'(?<tag>[\w\d]+?)', // read tag
        r'(?<expanded>,expanded)?', // read expanded
        r'(=(?<value>(.|\n)*?))?', // read value
        r'\]', // closing bracket
        r'(?!\])', // prevent double brackets
      ].join());

      RegExpMatch bracketMatch = bracketRex.firstMatch(source);
      if (bracketMatch != null) {
        // string before bracket
        String before = source.substring(0, bracketMatch.start);
        // string inside bracket
        String tag = source.substring(bracketMatch.start, bracketMatch.end);
        // string after bracket
        String after = source.substring(bracketMatch.end);

        // the key of the tag
        String key = bracketMatch.namedGroup('tag');
        // whether the tag is closing
        bool active = bracketMatch.namedGroup('closing') == null;
        // whether section tag is expanded
        bool expanded = bracketMatch.namedGroup('expanded') != null;
        // the value of the tag
        String value = bracketMatch.namedGroup('value');

        // block tag check.
        // prepare block beforehand,
        // so spaces can be removed

        Widget blocked;
        RegExp blankless = RegExp(r'(^\n*)|(\n*$)');

        if ([
              'spoiler',
              'code',
              'section',
              'quote',
            ].contains(key) &&
            active) {
          String end = '[/$key]';
          int splitStart;
          int splitEnd;
          for (Match endMatch in end.allMatches(after)) {
            String container = after.substring(0, endMatch.start);
            if ('[$key'.allMatches(container).length !=
                end.allMatches(container).length) {
              continue;
            }
            splitStart = endMatch.start;
            splitEnd = endMatch.end;
            break;
          }
          if (splitStart == null) {
            splitStart = after.length;
            splitEnd = after.length;
          }
          String between = after
              .substring(0, splitStart)
              .replaceAllMapped(blankless, (_) => '');
          switch (key) {
            case 'spoiler':
              blocked = spoilerWrap(RichText(
                text: resolve(between, state),
              ));
              break;
            case 'code':
              blocked = quoteWrap(RichText(
                text: getText(between, state),
              ));
              break;
            case 'quote':
              blocked = quoteWrap(RichText(
                text: resolve(between, state),
              ));
              break;
            case 'section':
              blocked = sectionWrap(
                  child: RichText(
                    text: resolve(between, state),
                  ),
                  title: value,
                  expanded: expanded);
              break;
          }
          after = after.substring(splitEnd);
        }

        if (blocked != null) {
          // remove all the spaces around blocks
          before = before.replaceAllMapped(RegExp(r'[ \n]*$'), (_) => '');
          after = after.replaceAllMapped(RegExp(r'^[ \n]*'), (_) => '');
          if (after.isNotEmpty) {
            // after = '\n' + after;
          }

          if (before.isNotEmpty) {
            spans.add(resolve(before, state));
          }

          // add block
          spans.add(WidgetSpan(child: blocked));

          if (after.isNotEmpty) {
            spans.add(resolve(after, state));
          }
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
              // ignore color tags
              // they're insanely hard to implement.
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
            if (before.isNotEmpty) {
              spans.add(resolve(before, state));
            }

            if (after.isNotEmpty) {
              spans.add(resolve(after, newState));
            }
          } else {
            spans.add(resolve('$before\\$tag$after', state));
          }
        }

        return TextSpan(
          children: spans,
        );
      }

      void parseLink(RegExpMatch match, String result, [bool insite = false]) {
        state[TextState.link] = true;

        String display = match.namedGroup('name');
        String search = match.namedGroup('link');
        String siteMatch = r'(e621\.net|e926\.net)?';
        Function onTap = () => launch(search);
        int id = int.tryParse(search.split('/').last.split('?').first);

        if (display == null) {
          display = match.namedGroup('link');
          display = display.replaceFirst('https://', '');
          display = display.replaceFirst('www.', '');
        }

        if (insite) {
          onTap = () async => launch('https://${await db.host.value}$search');
        }

        Map<RegExp, Function(RegExpMatch match)> links = {
          RegExp(siteMatch + r'/posts/\d+'): (match) {
            onTap = () async {
              Post p = await client.post(id);
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PostDetail(post: p);
              }));
            };
          },
          RegExp(siteMatch + r'/pool(s|/show)/\d+'): (match) {
            onTap = () async {
              Pool p = await client.pool(id);
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PoolPage(pool: p);
              }));
            };
          },
        };

        for (MapEntry<RegExp, Function(RegExpMatch match)> entry
            in links.entries) {
          RegExpMatch match = entry.key.firstMatch(result);
          if (match != null) {
            entry.value(match);
            break;
          }
        }

        spans.add(getText(display, state, onTap: onTap));

        state[TextState.link] = false;
      }

      void parseWord(String match, LinkWord word) {
        state[TextState.link] = true;

        Function onTap;

        switch (word) {
          case LinkWord.thumb:
          // add actual pictures here some day.
          case LinkWord.post:
            onTap = () async {
              Post p = await client.post(int.parse(match.split('#')[1]));
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PostDetail(post: p);
              }));
            };
            break;
          case LinkWord.pool:
            onTap = () async {
              Pool p = await client.pool(int.parse(match.split('#')[1]));
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PoolPage(pool: p);
              }));
            };
            break;
          default:
            break;
        }

        spans.add(getText(match, state, onTap: onTap));

        state[TextState.link] = false;
      }

      Map<RegExp, void Function(RegExpMatch match, String result)> regexes = {
        RegExp(r'\[\[(?<anchor>#)?(?<tags>.*?)(\|(?<name>.*?))?\]\]'):
            (match, result) {
          state[TextState.link] = true;

          bool anchor = match.namedGroup('anchor') != null;
          String name = match.namedGroup('name');
          String tags = match.namedGroup('tags');
          name ??= tags;

          Function onTap;

          if (!anchor) {
            onTap = () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(tags: tags)));
          }

          spans.add(getText(name, state, onTap: onTap));

          state[TextState.link] = false;
        },
        RegExp(r'{{(?<tags>.*?)(\|(?<name>.*?))?}}'): (match, result) {
          state[TextState.link] = true;

          String name = match.namedGroup('name');
          String tags = match.namedGroup('tags');
          name ??= tags;

          Function onTap = () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(tags: tags)));
          };

          spans.add(getText(name, state, onTap: onTap));

          state[TextState.link] = false;
        },
        RegExp(r'(^|\n)\*+ '): (match, result) => spans.add(resolve(
            '\n' + '  ' * ('*'.allMatches(result).length - 1) + '• ', state)),
        RegExp(r'h[1-6]\.\s?(?<name>.*)', caseSensitive: false):
            (match, result) {
          state[TextState.header] = true;
          String name = match.namedGroup('name');
          spans.add(resolve(name, state));
          state[TextState.header] = false;
        },
        RegExp(r'("(?<name>[^"]+?)":)?(?<link>(http(s)?)?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)([^.,!?:"\s]+))'):
            parseLink,
        RegExp(r'("(?<name>[^"]+?)":)(?<link>[-a-zA-Z0-9()@:%_\+.~#?&//=]*)([^.,!?:"\s]+)'):
            (match, result) => parseLink(match, result, true),
      };

      regexes.addEntries(LinkWord.values.map((word) {
        return MapEntry(
            RegExp(describeEnum(word) + r' #\d+', caseSensitive: false),
            (match, result) => parseWord(result, word));
      }));

      for (MapEntry<RegExp, Function(RegExpMatch match, String result)> entry
          in regexes.entries) {
        for (RegExpMatch otherMatch in entry.key.allMatches(source)) {
          String before = source.substring(0, otherMatch.start);
          String result = source.substring(otherMatch.start, otherMatch.end);
          String after = source.substring(otherMatch.end, source.length);

          if (before.isNotEmpty) {
            spans.add(resolve(before, state));
          }

          entry.value(otherMatch, result);

          if (after.isNotEmpty) {
            spans.add(resolve(after, state));
          }
          return TextSpan(
            children: spans,
          );
        }
      }

      // no matching brackets, return normal text
      return getText(source, state);
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
    };

    String result = msg.replaceAllMapped(RegExp(r'\r\n'), (_) => '\n');

    return RichText(
      text: resolve(result, state),
    );
  }
}

enum TextState {
  bold,
  italic,
  strikeout,
  underline,
  overline,
  header,
  link,
}

enum LinkWord {
  post,
  forum,
  comment,
  blip,
  pool,
  set,
  takedown,
  record,
  ticket,
  category,
  thumb,
}

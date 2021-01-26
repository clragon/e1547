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
    Widget sectionWrap(Widget child, String title, {bool expanded = false}) {
      return Card(
          color: Theme.of(context).canvasColor,
          child: ExpandableNotifier(
            initialExpanded: expanded,
            child: ExpandableTheme(
              data: ExpandableThemeData(
                iconColor: Theme.of(context).iconTheme.color,
              ),
              child: ExpandablePanel(
                header: Padding(
                  padding: EdgeInsets.only(left: 8, top: 10),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                collapsed: Container(),
                expanded: Padding(
                  padding: EdgeInsets.only(left: 8, right: 8, bottom: 10),
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
    TextSpan resolve(String msg, Map<TextState, bool> state) {
      // get string in plain text. no parsing.
      TextSpan getText(String msg, Map<TextState, bool> states,
          {Function() onTap}) {
        msg = msg.replaceAll('\\[', '[');
        msg = msg.replaceAll('\\]', ']');

        msg = msg.replaceAllMapped(RegExp(r'(\r\n){4,}'), (lines) => '\n');

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
            fontWeight:
                states[TextState.bold] ? FontWeight.bold : FontWeight.normal,
            fontStyle:
                states[TextState.italic] ? FontStyle.italic : FontStyle.normal,
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
      if (msg.contains('[')) {
        // string before bracket
        String before = '';
        // string inside bracket
        String tag = '';
        // string after bracket
        String after = '';

        // if double bracket
        bool isFat = false;
        // index of starting bracket
        int start;
        // index of ending bracket
        int end;

        // iterate through all brackets
        // apply conditions to prevent using irrelevant brackets
        // only use the first matching one, pass on others
        for (Match startMatch in '['.allMatches(msg)) {
          // discard escaped brackets
          if (startMatch.start != 0 && msg[startMatch.start - 1] == '\\') {
            continue;
          }

          // check if stray ending bracket
          for (Match endMatch in ']'.allMatches(msg)) {
            // check is end before start (invalid)
            if (endMatch.start < startMatch.start) {
              continue;
            }
            // check if escaped ending bracket
            if (endMatch.start != 0 && msg[endMatch.start - 1] == '\\') {
              continue;
            }
            // return ending bracket
            end = endMatch.start;
            break;
          }
          // discard if no matching ending bracket
          if (end == null) {
            continue;
          }

          // check for double brackets
          int double = msg.indexOf('[[');
          if (double == startMatch.start) {
            start = startMatch.start;
            if (msg.indexOf(']]') != -1) {
              end = msg.indexOf(']]') + 1;
              isFat = true;
            } else {
              continue;
            }
            break;
          }
          // check if stray starting bracket
          int second = msg.substring(startMatch.start + 1).indexOf('[');
          if (second != -1) {
            if ((startMatch.start + second) < end) {
              continue;
            }
          }
          // return matching starting bracket
          start = startMatch.start;
          break;
        }

        // parse valid brackets
        if (start != null) {
          before = msg.substring(0, start);
          tag = msg.substring(start + 1, end);
          after = msg.substring(end + 1, msg.length);

          if (tag.isNotEmpty) {
            // the key of the tag
            String key;
            // whether tag is starting or ending
            bool active = true;
            // whether section tag is expanded
            bool expanded = false;

            key = tag.split('=').first.toLowerCase();

            // check if tag is opening or closing
            if (key[0] == '/') {
              key = key.substring(1);
              active = false;
            }

            // check if tag is expanded section
            if (key.contains(',') && key.split(',')[1] == 'expanded') {
              key = key.split(',').first;
              expanded = true;
            }

            // check if tag is named section
            String value = '';
            if (tag.contains('=')) {
              value = tag.substring(tag.indexOf('=') + 1);
            }

            if (isFat) {
              if (before.isNotEmpty) {
                spans.add(resolve(before, state));
              }

              state[TextState.link] = true;

              Function onTap;
              bool sameSite = false;

              key = key.substring(1, key.length - 1);

              if (key[0] == '#') {
                key = key.substring(1);
                sameSite = true;
              }

              String display = key;
              String search = key.replaceAll(' ', '_');

              if (key.contains('|')) {
                search = key.split('|')[0];
                display = key.split('|')[1];
              }

              if (!sameSite) {
                onTap = () => Navigator.of(context)
                        .push(MaterialPageRoute<Null>(builder: (context) {
                      return SearchPage(tags: search);
                    }));
              }

              spans.add(getText(display, state, onTap: onTap));

              state[TextState.link] = false;

              if (after.isNotEmpty) {
                spans.add(resolve(after, state));
              }
            } else {
              // block tag check.
              // prepare block beforehand,
              // so spaces can be removed

              Widget blocked;
              RegExp blankless = RegExp(r'(^[\r\n]*)|([\r\n]*$)');

              if ([
                    'spoiler',
                    'code',
                    'section',
                    'quote',
                  ].any((block) => block == key) &&
                  active) {
                String end = '[/$key]';
                int split;
                for (Match endMatch in end.allMatches(after)) {
                  String container = after.substring(0, endMatch.start);
                  if ('[$key'.allMatches(container).length !=
                      end.allMatches(container).length) {
                    continue;
                  }
                  split = endMatch.start;
                  break;
                }
                if (split != null) {
                  String between = after
                      .substring(0, split)
                      .replaceAllMapped(blankless, (match) => '');
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
                          RichText(
                            text: resolve(between, state),
                          ),
                          value,
                          expanded: expanded);
                      break;
                  }
                  after = after.substring(split + end.length);
                }
              }

              if (blocked != null) {
                // remove all the spaces around blocks
                before =
                    before.replaceAllMapped(RegExp(r'[\r\n]*$'), (match) => '');
                after =
                    after.replaceAllMapped(RegExp(r'^[ \r\n]*'), (match) => '');
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
                  spans.add(resolve('$before\\[$tag\\]$after', state));
                }
              }
            }
          }

          return TextSpan(
            children: spans,
          );
        }
      }

      void parseLink(String match, {bool insite = false}) {
        String display = match;
        String search = match;

        Match name = RegExp(r'"[^"]+?":').firstMatch(match);
        if (name != null) {
          display = match.substring(name.start + 1, name.end - 2);
          search = match.substring(name.end);
        }

        state[TextState.link] = true;

        String siteMatch = r'(e621\.net|e926\.net)';
        Function onTap = () => launch(search);
        int id = int.tryParse(search.split('/').last.split('?').first);

        if (insite) {
          siteMatch = r'';
          onTap = () async => launch('https://${await db.host.value}$search');
        }

        if (id != null) {
          if (RegExp(siteMatch + r'/posts/\d+').hasMatch(search)) {
            onTap = () async {
              Post p = await client.post(id);
              Navigator.of(context)
                  .push(MaterialPageRoute<Null>(builder: (context) {
                return PostDetail(post: p);
              }));
            };
          }
          if (RegExp(siteMatch + r'/pool(s|/show)/\d+').hasMatch(search)) {
            onTap = () async {
              Pool p = await client.pool(id);
              Navigator.of(context)
                  .push(MaterialPageRoute<Null>(builder: (context) {
                return PoolPage(pool: p);
              }));
            };
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
              Navigator.of(context)
                  .push(MaterialPageRoute<Null>(builder: (context) {
                return PostDetail(post: p);
              }));
            };
            break;
          case LinkWord.pool:
            onTap = () async {
              Pool p = await client.pool(int.parse(match.split('#')[1]));
              Navigator.of(context)
                  .push(MaterialPageRoute<Null>(builder: (context) {
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

      Map<RegExp, void Function(String match)> regexes = {
        RegExp(r'{{.*?}}'): (match) {
          // remove the brackets
          match = match.substring(2, match.length - 2);

          state[TextState.link] = true;

          Function onTap = () {
            Navigator.of(context)
                .push(MaterialPageRoute<Null>(builder: (context) {
              // split of display text after |
              // and replace spaces with _ to produce a valid tag
              return SearchPage(
                  tags: match.split('|').first.replaceAll(' ', '_'));
            }));
          };

          spans.add(getText(match, state, onTap: onTap));

          state[TextState.link] = false;
        },
        RegExp(r'(^|\n)\*+ '): (match) => spans.add(resolve(
            '\n' + '  ' * ('*'.allMatches(match).length - 1) + '• ', state)),
        RegExp(r'h[1-6]\.\s?.*', caseSensitive: false): (match) {
          state[TextState.header] = true;
          String blocked = match.substring(3).trim();
          spans.add(resolve(blocked, state));
          state[TextState.header] = false;
        },
        RegExp(r'("[^"]+?":)?(http(s)?)?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)([^.,!?:"\s]+)'):
            parseLink,
        RegExp(r'("[^"]+?":)([-a-zA-Z0-9()@:%_\+.~#?&//=]*)([^.,!?:"\s]+)'):
            (match) => parseLink(match, insite: true),
      };

      regexes.addEntries(LinkWord.values.map((word) {
        return MapEntry(
            RegExp(describeEnum(word) + r' #\d+', caseSensitive: false),
            (String match) => parseWord(match, word));
      }));

      for (MapEntry<RegExp, Function(String match)> entry in regexes.entries) {
        if (entry.key.hasMatch(msg)) {
          for (Match wordMatch in entry.key.allMatches(msg)) {
            String before = msg.substring(0, wordMatch.start);
            String match = msg.substring(wordMatch.start, wordMatch.end);
            String after = msg.substring(wordMatch.end, msg.length);

            if (before.isNotEmpty) {
              spans.add(resolve(before, state));
            }

            entry.value(match);

            if (after.isNotEmpty) {
              spans.add(resolve(after, state));
            }
            return TextSpan(
              children: spans,
            );
          }
        }
      }

      // no matching brackets, return normal text
      return getText(msg, state);
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

    return RichText(
      text: resolve(msg, state),
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

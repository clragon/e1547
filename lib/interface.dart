import 'package:e1547/persistence.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/tag.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as url;
import 'package:e1547/client.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

void wikiDialog(BuildContext context, String tag, {actions = false}) {
  Widget body() {
    return ConstrainedBox(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data.length != 0) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: dTextField(context, snapshot.data[0]['body']),
                  physics: BouncingScrollPhysics(),
                );
              } else {
                return Text(
                  'no wiki entry',
                  style: TextStyle(fontStyle: FontStyle.italic),
                );
              }
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        height: 26,
                        width: 26,
                        child: CircularProgressIndicator(),
                      ))
                ],
              );
            }
          },
          future: client.wiki(tag, 0),
        ),
        constraints: new BoxConstraints(
          maxHeight: 400.0,
        ));
  }

  Widget title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            tag.replaceAll('_', ' '),
            softWrap: true,
          ),
        ),
        actions ? _TagActions(tag) : Container(),
      ],
    );
  }

  showDialog(
    context: context,
    child: AlertDialog(
      title: title(),
      content: body(),
      actions: [
        FlatButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

class _TagActions extends StatefulWidget {
  final String tag;

  const _TagActions(this.tag);

  @override
  State<StatefulWidget> createState() {
    return _TagActionsState();
  }
}

class _TagActionsState extends State<_TagActions> {
  @override
  Widget build(BuildContext context) {
    bool blacklisted = false;
    bool following = false;
    List<String> blacklist;
    List<String> follows;

    Future getLists() async {
      blacklist = await db.blacklist.value;
      blacklist.forEach((b) {
        if (b == widget.tag) {
          blacklisted = true;
        }
      });
      follows = await db.follows.value;
      follows.forEach((b) {
        if (b == widget.tag) {
          following = true;
        }
      });
      return;
    }

    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  if (following) {
                    follows.removeAt(follows.indexOf(widget.tag));
                    db.follows.value = Future.value(follows);
                    setState(() {
                      following = false;
                    });
                  } else {
                    follows.add(widget.tag);
                    db.follows.value = Future.value(follows);
                    setState(() {
                      following = true;
                      if (blacklisted) {
                        blacklist.removeAt(blacklist.indexOf(widget.tag));
                        db.blacklist.value = Future.value(blacklist);
                        blacklisted = false;
                      }
                    });
                  }
                },
                icon: following
                    ? Icon(Icons.turned_in)
                    : Icon(Icons.turned_in_not),
                tooltip: following ? 'follow tag' : 'unfollow tag',
              ),
              IconButton(
                onPressed: () {
                  if (blacklisted) {
                    blacklist.removeAt(blacklist.indexOf(widget.tag));
                    db.blacklist.value = Future.value(blacklist);
                    setState(() {
                      blacklisted = false;
                    });
                  } else {
                    blacklist.add(widget.tag);
                    db.blacklist.value = Future.value(blacklist);
                    setState(() {
                      blacklisted = true;
                      if (following) {
                        follows.removeAt(follows.indexOf(widget.tag));
                        db.follows.value = Future.value(follows);
                        following = false;
                      }
                    });
                  }
                },
                icon: blacklisted ? Icon(Icons.check) : Icon(Icons.block),
                tooltip: blacklisted ? 'block tag' : 'unblock tag',
              ),
            ],
          );
        } else {
          return Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.turned_in_not),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.block),
                onPressed: () {},
              ),
            ],
          );
        }
      },
      future: getLists(),
    );
  }
}

Widget dTextField(BuildContext context, String msg, {bool darkText = false}) {
  // transform dynamic list to widgets
  // wrap all consecutive TextSpans into RichText
  List<Widget> toWidgets(List<dynamic> parts) {
    List<Widget> widgets = [];
    List<List<dynamic>> rows = [];
    bool lastIsText = false;
    for (var text in parts) {
      if (text is TextSpan) {
        if (lastIsText) {
          rows[rows.length - 1].add(text);
        } else {
          rows.add([text]);
        }
        lastIsText = true;
      } else {
        rows.add([text]);
        lastIsText = false;
      }
    }
    for (var row in rows) {
      if (row[0] is Widget) {
        row.forEach((r) => widgets.add(r));
      } else {
        widgets.add(RichText(
          text: TextSpan(
            children: row.cast<TextSpan>(),
          ),
        ));
      }
    }
    return widgets;
  }

  // parse string recursively
  List<dynamic> resolve(String msg, Map<String, bool> states) {
    // wrapper widget for quotes
    Widget quoteWrap(List<Widget> children) {
      return Card(
        color: Theme.of(context).canvasColor,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ]),
        ),
      );
    }

    // wrapper widget for sections
    Widget sectionWrap(List<Widget> children, String title,
        {bool expanded = false}) {
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
                    children: children,
                  ),
                ),
              ),
            ),
          ));
    }

    // get string in plain text. no parsing.
    List<TextSpan> getText(String msg, Map<String, bool> states,
        {Function() onTap}) {
      msg = msg.replaceAll('\\[', '[');
      msg = msg.replaceAll('\\]', ']');

      msg = msg.replaceAllMapped(RegExp(r'(\r\n){4,}'), (lines) => '\n');

      return [
        TextSpan(
          text: msg,
          recognizer: new TapGestureRecognizer()..onTap = onTap,
          style: TextStyle(
            color: states['link']
                ? Colors.blue[400]
                : states['dark']
                    ? Colors.grey[600]
                    : Theme.of(context).textTheme.body1.color,
            fontWeight: states['bold'] ? FontWeight.bold : FontWeight.normal,
            fontStyle: states['italic'] ? FontStyle.italic : FontStyle.normal,
            decoration: TextDecoration.combine([
              states['strike']
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              states['underline']
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ]),
          ),
        ),
      ];
    }

    // list of widgets that will be returned
    List<dynamic> newParts = [];

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
      int start = -1;
      // index of ending bracket
      int end = -1;

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
        if (end == -1) {
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
      if (start != -1) {
        before = msg.substring(0, start);
        tag = msg.substring(start + 1, end);
        after = msg.substring(end + 1, msg.length);

        if (tag.isNotEmpty) {
          // whether tag is starting or ending
          bool active;
          // the actual tag
          String key;
          // whether section tag is expanded
          bool expanded = false;

          // check if tag is starting or ending
          if (tag[0] == '/') {
            key = tag.split('=')[0].substring(1);
            active = false;
          } else {
            key = tag.split('=')[0];
            active = true;
          }

          // check for comma in tag
          // this seems to be ONLY used in sections.
          if (key.contains(',')) {
            if (key.split(',')[1].toLowerCase() == 'expanded') {
              expanded = true;
            }
            key = key.split(',')[0];
          }

          String value = '';
          if (tag.contains('=')) {
            // use index of in case of multiple equals
            int equal = tag.indexOf('=');
            value = tag.substring(equal + 1);
          }

          if (isFat) {
            if (before.isNotEmpty) {
              newParts.addAll(resolve(before, states));
            }

            states['link'] = true;

            Function onTap;
            bool sameSite = false;

            key = key.substring(1, key.length - 1);

            if (key[0] == '#') {
              key = key.substring(1);
              sameSite = true;
            }

            String display = key;
            String search = key;

            if (key.contains('|')) {
              search = key.split('|')[0];
              display = key.split('|')[1];
            }

            if (!sameSite) {
              onTap = () => Navigator.of(context)
                      .push(new MaterialPageRoute<Null>(builder: (context) {
                    return new SearchPage(tags: new Tagset.parse(search));
                  }));
            }

            newParts.addAll(getText(display, states, onTap: onTap));

            states['link'] = false;

            if (after.isNotEmpty) {
              newParts.addAll(resolve(after, states));
            }
          } else {
            // block tag check.
            // prepare block beforehand,
            // so spaces can be removed

            Widget blocked;
            RegExp blankLess = RegExp(r'(^[\r\n]*)|([\r\n]*$)');

            switch (key.toLowerCase()) {
              case 'code':
              case 'section':
              case 'quote':
                if (active) {
                  String end = '[/${key.toLowerCase()}]';
                  int split = -1;
                  for (Match endMatch in end.allMatches(after)) {
                    String container = after.substring(0, endMatch.start);
                    if ('[$key'.allMatches(container).length !=
                        end.allMatches(container).length) {
                      continue;
                    }
                    split = endMatch.start;
                    break;
                  }
                  if (split == -1) {
                    break;
                  }
                  String between = after
                      .substring(0, split)
                      .replaceAllMapped(blankLess, (match) => '');
                  switch (key.toLowerCase()) {
                    case 'code':
                      blocked = quoteWrap(toWidgets(getText(between, states)));
                      break;
                    case 'quote':
                      blocked = quoteWrap(toWidgets(resolve(between, states)));
                      break;
                    case 'section':
                      blocked = sectionWrap(
                          toWidgets(resolve(between, states)), value,
                          expanded: expanded);
                      break;
                  }
                  after = after.substring(split + end.length);
                }
                break;
            }

            if (blocked != null) {
              // remove all the spaces around blocks
              before =
                  before.replaceAllMapped(RegExp(r'[\r\n]*$'), (match) => '');
              after =
                  after.replaceAllMapped(RegExp(r'^[ \r\n]*'), (match) => '');
              if (after.isNotEmpty) {
                after = '\n' + after;
              }

              if (before.isNotEmpty) {
                newParts.addAll(resolve(before, states));
              }

              // add block
              newParts.add(blocked);

              if (after.isNotEmpty) {
                newParts.addAll(resolve(after, states));
              }
            } else {
              Map<String, bool> oldStates = Map.from(states);
              bool triggered = false;

              // add textStyle
              switch (key.toLowerCase()) {
                case 'b':
                  states['bold'] = active;
                  triggered = true;
                  break;
                case 'i':
                  states['italic'] = active;
                  triggered = true;
                  break;
                case 'u':
                  states['underline'] = active;
                  triggered = true;
                  break;
                case 's':
                  states['strike'] = active;
                  triggered = true;
                  break;
                case 'color':
                  // ignore color tags
                  // they're insanely hard to implement.
                  triggered = true;
                  break;
                case 'sup':
                  // I have no idea how to implement this.
                  triggered = true;
                  break;
                case 'sub':
                  // I have no idea how to implement this.
                  triggered = true;
                  break;
              }

              if (triggered) {
                if (before.isNotEmpty) {
                  newParts.addAll(resolve(before, oldStates));
                }

                if (after.isNotEmpty) {
                  newParts.addAll(resolve(after, states));
                }
              } else {
                newParts.addAll(resolve('$before\\[$tag\\]$after', states));
              }
            }
          }
        }

        return newParts;
      }
    }

    List<String> words = [
      'post',
      'forum',
      'comment',
      'blip',
      'pool',
      'set',
      'takedown',
      'record',
      'ticket',
      'category',
      'thumb',
    ];

    for (String word in words) {
      RegExp rex = RegExp('$word #[0-9]{1,9}');
      if (rex.hasMatch(msg)) {
        for (Match wordMatch in rex.allMatches(msg)) {
          String before = msg.substring(0, wordMatch.start);
          String match = msg.substring(wordMatch.start, wordMatch.end);
          String after = msg.substring(wordMatch.end, msg.length);

          if (before.isNotEmpty) {
            newParts.addAll(resolve(before, states));
          }

          states['link'] = true;

          Function onTap;

          switch (word) {
            case 'thumb':
            // add actual pictures here some day.
            case 'post':
              onTap = () async {
                Post p = await client.post(int.parse(match.split('#')[1]));
                Navigator.of(context)
                    .push(new MaterialPageRoute<Null>(builder: (context) {
                  return new PostWidget(p);
                }));
              };
              break;
            case 'pool':
              onTap = () async {
                Pool p = await client.pool(int.parse(match.split('#')[1]));
                Navigator.of(context)
                    .push(new MaterialPageRoute<Null>(builder: (context) {
                  return new PoolPage(p);
                }));
              };
              break;
          }

          newParts.addAll(getText(match, states, onTap: onTap));

          states['link'] = false;

          if (after.isNotEmpty) {
            newParts.addAll(resolve(after, states));
          }
          return newParts;
        }
      }
    }

    void parseLink(String match, {bool insite = false}) {
      if (match.endsWith('/')) {
        match = match.substring(0, match.length - 1);
      }

      String display = match;
      String search = match;
      if (match[0] == '"') {
        int end = match.substring(1).indexOf('"') + 1;
        display = match.substring(1, end);
        search = match.substring(end + 2);
      }

      states['link'] = true;

      Function onTap;

      if (!insite) {
        onTap = () async {
          url.launch(search);
        };
        try {
          if (RegExp(r'(e621\.net|e926\.net)/posts/[0-9]{1,9}')
              .hasMatch(search)) {
            int id = int.parse(search.split('/').last.split('?').first);
            onTap = () async {
              Post p = await client.post(id);
              Navigator.of(context)
                  .push(new MaterialPageRoute<Null>(builder: (context) {
                return new PostWidget(p);
              }));
            };
          }
          if (RegExp(r'(e621\.net|e926\.net)/pool(s|/show)/[0-9]{1,9}')
              .hasMatch(search)) {
            int id = int.parse(search.split('/').last);
            onTap = () async {
              Pool p = await client.pool(id);
              Navigator.of(context)
                  .push(new MaterialPageRoute<Null>(builder: (context) {
                return new PoolPage(p);
              }));
            };
          }
        } catch (Exception) {
          // parsing this ain't safe
          // and its not a temporary solution.
          // but we're gonna give it a try because its neat if it works.
        }
      } else {
        onTap = () async {
          url.launch('https://${await db.host.value}$search');
        };
        try {
          if (search.startsWith('/posts/')) {
            int id = int.parse(search.split('/').last);
            onTap = () async {
              Post p = await client.post(id);
              Navigator.of(context)
                  .push(new MaterialPageRoute<Null>(builder: (context) {
                return new PostWidget(p);
              }));
            };
          }
          if (search.startsWith('/pools/')) {
            int id = int.parse(search.split('/').last);
            onTap = () async {
              Pool p = await client.pool(id);
              Navigator.of(context)
                  .push(new MaterialPageRoute<Null>(builder: (context) {
                return new PoolPage(p);
              }));
            };
          }
        } catch (Exception) {
          // uh oh
        }
      }

      newParts.addAll(getText(display, states, onTap: onTap));

      states['link'] = false;
    }

    void parseWord(String match, String word) {
      states['link'] = true;

      Function onTap;

      switch (word) {
        case 'thumb':
        // add actual pictures here some day.
        case 'post':
          onTap = () async {
            Post p = await client.post(int.parse(match.split('#')[1]));
            Navigator.of(context)
                .push(new MaterialPageRoute<Null>(builder: (context) {
              return new PostWidget(p);
            }));
          };
          break;
        case 'pool':
          onTap = () async {
            Pool p = await client.pool(int.parse(match.split('#')[1]));
            Navigator.of(context)
                .push(new MaterialPageRoute<Null>(builder: (context) {
              return new PoolPage(p);
            }));
          };
          break;
      }

      newParts.addAll(getText(match, states, onTap: onTap));

      states['link'] = false;
    }

    Map<RegExp, Function(String match)> regexes = {
      RegExp(r'{{.*?}}'): (match) {
        // remove the brackets
        match = match.substring(2);
        match = match.substring(0, match.length - 2);

        states['link'] = true;

        Function onTap = () {
          Navigator.of(context)
              .push(new MaterialPageRoute<Null>(builder: (context) {
            // split of display text after |
            // and replace spaces with _ to produce a valid tag
            return new SearchPage(
                tags:
                    new Tagset.parse(match.split('|')[0].replaceAll(' ', '_')));
          }));
        };

        newParts.addAll(getText(match, states, onTap: onTap));

        states['link'] = false;
      },
      RegExp(r'(^|\n)\*+ '): (match) {
        newParts.addAll(resolve(
            '\n' + '  ' * ('*'.allMatches(match).length - 1) + '• ', states));
      },
      RegExp(r'h[1-6]\..*', caseSensitive: false): (match) {
        states['headline'] = true;

        newParts.addAll(resolve(match.substring(3), states));

        states['headline'] = false;
      },
      RegExp(r'("[^"]+?":)?(http(s)?)?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)([^.,!?:"\s]+)'):
          parseLink,
      RegExp(r'("[^"]+?":)([-a-zA-Z0-9()@:%_\+.~#?&//=]*)([^.,!?:"\s]+)'):
          (match) {
        parseLink(match, insite: true);
      },
    };

    List<MapEntry<RegExp, Function(String match)>> links = [];

    for (String word in words) {
      RegExp rex = RegExp('$word #[0-9]{1,9}');
      links.add(MapEntry(rex, (match) {
        parseWord(match, word);
      }));
    }

    regexes.addEntries(links);

    for (MapEntry<RegExp, Function(String match)> entry in regexes.entries) {
      if (entry.key.hasMatch(msg)) {
        for (Match wordMatch in entry.key.allMatches(msg)) {
          String before = msg.substring(0, wordMatch.start);
          String match = msg.substring(wordMatch.start, wordMatch.end);
          String after = msg.substring(wordMatch.end, msg.length);

          if (before.isNotEmpty) {
            newParts.addAll(resolve(before, states));
          }

          entry.value(match);

          if (after.isNotEmpty) {
            newParts.addAll(resolve(after, states));
          }
          return newParts;
        }
      }
    }

    // no matching brackets, return normal text
    return getText(msg, states);
  }

  // Map to keep track of textStyle
  Map<String, bool> states = {
    'bold': false,
    'italic': false,
    'strike': false,
    'underline': false,
    'headline': false,
    'link': false,
    'dark': darkText,
  };

  // call with initial string
  List<dynamic> parts = resolve(msg, states);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: toWidgets(parts),
  );
}

class LowercaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue prev, TextEditingValue current) {
    return current.copyWith(text: current.text.toLowerCase());
  }
}

void setFocusToEnd(TextEditingController controller) {
  controller.selection = new TextSelection(
    baseOffset: controller.text.length,
    extentOffset: controller.text.length,
  );
}

void setUIColors(ThemeData theme) {
  FlutterStatusbarcolor.setStatusBarColor(theme.canvasColor);
  FlutterStatusbarcolor.setNavigationBarColor(theme.canvasColor);
  FlutterStatusbarcolor.setNavigationBarWhiteForeground(
      theme.brightness == Brightness.dark);
  FlutterStatusbarcolor.setStatusBarWhiteForeground(
      theme.brightness == Brightness.dark);
}

Future<bool> getConsent(BuildContext context) async {
  bool hasConsent = false;

  if (await db.hasConsent.value) {
    return true;
  }

  await showDialog(
    context: context,
    child: new AlertDialog(
      title: const Text('Age verification'),
      content: const Text(
          'You need to be above the age of 18 to view explicit content.'),
      actions: [
        new FlatButton(
          child: const Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        new FlatButton(
          child: const Text('OK'),
          onPressed: () {
            hasConsent = true;
            db.hasConsent.value = Future.value(true);
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );

  return hasConsent;
}

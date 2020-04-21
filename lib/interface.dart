import 'package:e1547/persistence.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/tag.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url;

import 'client.dart';

Widget wikiDialog(BuildContext context, String tag, {actions = false}) {
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
        Text(tag),
        actions ? _BlockButton(tag) : Container(),
      ],
    );
  }

  return AlertDialog(
    title: title(),
    content: body(),
    actions: [
      FlatButton(
        child: Text('OK'),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}

class _BlockButton extends StatefulWidget {
  final String tag;

  const _BlockButton(this.tag);

  @override
  State<StatefulWidget> createState() {
    return _BlockButtonState();
  }
}

class _BlockButtonState extends State<_BlockButton> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          bool blackListed = false;
          snapshot.data.forEach((b) {
            if (b == widget.tag) {
              blackListed = true;
            }
          });
          return IconButton(
            onPressed: () {
              if (blackListed) {
                snapshot.data.removeAt(snapshot.data.indexOf(widget.tag));
                db.blacklist.value = Future.value(snapshot.data);
                setState(() {
                  blackListed = false;
                });
              } else {
                snapshot.data.add(widget.tag);
                db.blacklist.value = Future.value(snapshot.data);
                setState(() {
                  blackListed = true;
                });
              }
            },
            icon: blackListed ? Icon(Icons.check) : Icon(Icons.block),
          );
        } else {
          return Container();
        }
      },
      future: db.blacklist.value,
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
        color: Colors.grey[900],
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
          color: Colors.grey[900],
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
    List<dynamic> getText(String msg, Map<String, bool> states) {
      msg = msg.replaceAll('\\[', '[');
      msg = msg.replaceAll('\\]', ']');

      msg = msg.replaceAllMapped(RegExp(r'(\r\n){4,}'), (lines) => '\n');

      return [
        TextSpan(
          text: msg,
          style: TextStyle(
            color: darkText ? Colors.grey[600] : null,
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
          isFat = true;
          if (msg.indexOf(']]') != -1) {
            end = msg.indexOf(']]') + 1;
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

        if (tag != '') {
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
            if (key.split(',')[1] == 'expanded') {
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

          switch (key) {
            case 'quote':
            case 'code':
            case 'section':
              before =
                  before.replaceAllMapped(RegExp(r'[\r\n]*$'), (match) => '');
              break;
          }

          if (before != '') {
            newParts.addAll(resolve(before, states));
          }

          // if double bracket, return this.
          if (isFat) {
            key = key.substring(1, key.length - 1);
            bool sameSite = false;
            if (key[0] == '#') {
              key = key.substring(1);
              sameSite = true;
            }

            String display;
            String search;

            if (key.contains('|')) {
              search = key.split('|')[0];
              display = key.split('|')[1];
            } else {
              search = key;
              display = key;
            }

            newParts.add(TextSpan(
              text: display,
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  if (!sameSite) {
                    Navigator.of(context)
                        .push(new MaterialPageRoute<Null>(builder: (context) {
                      return new SearchPage(new Tagset.parse(search));
                    }));
                  }
                },
              style: TextStyle(
                color: Colors.blue[400],
                fontWeight:
                    states['bold'] ? FontWeight.bold : FontWeight.normal,
                fontStyle:
                    states['italic'] ? FontStyle.italic : FontStyle.normal,
                decoration: TextDecoration.combine([
                  states['strike']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  states['underline']
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ]),
              ),
            ));
          } else {
            switch (key) {
              case 'b':
                states['bold'] = active;
                break;
              case 'i':
                states['italic'] = active;
                break;
              case 'u':
                states['underline'] = active;
                break;
              case 's':
                states['strike'] = active;
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
              case 'spoiler':
                // maybe with a wrap.
                break;
              case 'code':
                if (active) {
                  String end = '[/code]';
                  int split = after.indexOf(end);
                  if (split == -1) {
                    newParts.addAll(resolve('\\[$tag\\]', states));
                    break;
                  }
                  String quoted = after.substring(0, split);
                  quoted = quoted.replaceAllMapped(
                      RegExp(r'(^[\r\n]*)|([\r\n]*$)'), (match) => '');
                  newParts.add(quoteWrap(toWidgets(getText(quoted, states))));
                  after = after.substring(split + end.length);
                  after = after.replaceAllMapped(
                      RegExp(r'^[ \r\n]*'), (match) => '');
                  if (after != '') {
                    after = '\n' + after;
                  }
                } else {
                  // display tag normally. inactive block tags are impossible.
                  newParts.addAll(resolve('\\[$tag\\]', states));
                }
                break;
              case 'quote':
                if (active) {
                  String end = '[/quote]';
                  int split = after.indexOf(end);
                  if (split == -1) {
                    newParts.addAll(resolve('\\[$tag\\]', states));
                    break;
                  }
                  String quoted = after.substring(0, split);
                  quoted = quoted.replaceAllMapped(
                      RegExp(r'(^[\r\n]*)|([\r\n]*$)'), (match) => '');
                  newParts.add(quoteWrap(toWidgets(resolve(quoted, states))));
                  after = after.substring(split + end.length);
                  after = after.replaceAllMapped(
                      RegExp(r'^[ \r\n]*'), (match) => '');
                  if (after != '') {
                    after = '\n' + after;
                  }
                } else {
                  // display tag normally. inactive block tags are impossible.
                  newParts.addAll(resolve('\\[$tag\\]', states));
                }
                break;
              case 'section':
                if (active) {
                  String end = '[/section]';
                  int split = after.indexOf(end);
                  if (split == -1) {
                    newParts.addAll(resolve('\\[$tag\\]', states));
                    break;
                  }
                  String quoted = after.substring(0, split);
                  quoted = quoted.replaceAllMapped(
                      RegExp(r'(^[\r\n]*)|([\r\n]*$)'), (match) => '');
                  newParts.add(sectionWrap(
                      toWidgets(resolve(quoted, states)), value,
                      expanded: expanded));
                  after = after.substring(split + end.length);
                  after = after.replaceAllMapped(
                      RegExp(r'^[ \r\n]*'), (match) => '');
                  if (after != '') {
                    after = '\n' + after;
                  }
                } else {
                  // display tag normally. inactive block tags are impossible.
                  newParts.addAll(resolve('\\[$tag\\]', states));
                }
                break;
              default:
                newParts.addAll(resolve('\\[$tag\\]', states));
                break;
            }
          }
        }

        if (after != '') {
          newParts.addAll(resolve(after, states));
        }
        return newParts;
      }
    }

    List<String> linkWords = [
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

    for (String word in linkWords) {
      RegExp rex = RegExp('$word #[0-9]{1,9}');
      if (rex.hasMatch(msg)) {
        for (Match wordMatch in rex.allMatches(msg)) {
          String before = msg.substring(0, wordMatch.start);
          String match = msg.substring(wordMatch.start, wordMatch.end);
          String after = msg.substring(wordMatch.end, msg.length);

          if (before != '') {
            newParts.addAll(resolve(before, states));
          }

          newParts.add(TextSpan(
            text: match,
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                switch (word) {
                  case 'thumb':
                  case 'post':
                    return () async {
                      Post p =
                          await client.post(int.parse(match.split('#')[1]));
                      Navigator.of(context)
                          .push(new MaterialPageRoute<Null>(builder: (context) {
                        return new PostWidget(p);
                      }));
                    };
                    break;
                  case 'pool':
                    return () async {
                      Pool p =
                          await client.poolById(int.parse(match.split('#')[1]));
                      Navigator.of(context)
                          .push(new MaterialPageRoute<Null>(builder: (context) {
                        return new PoolPage(p);
                      }));
                    };
                    break;
                  default:
                    return () {};
                    break;
                }
              }(),
            style: TextStyle(
              color: Colors.blue[400],
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
          ));

          if (after != '') {
            newParts.addAll(resolve(after, states));
          }
          return newParts;
        }
      }
    }

    RegExp linkRex = RegExp(
        r'("[^"]+?":)?https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*?)([^\s]+)');
    RegExp inSite = RegExp(r'("[^"]+?":)([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');

    for (RegExp word in [linkRex, inSite]) {
      if (word.hasMatch(msg)) {
        for (Match wordMatch in word.allMatches(msg)) {
          String before = msg.substring(0, wordMatch.start);
          String match = msg.substring(wordMatch.start, wordMatch.end);
          String after = msg.substring(wordMatch.end, msg.length);

          if (before != '') {
            newParts.addAll(resolve(before, states));
          }

          String display = match;
          String search = match;
          if (match[0] == '"') {
            int end = match.substring(1).indexOf(':');
            display = match.substring(1, end);
            search = match.substring(end + 2, match.length - 1);
          }
          if (display[display.length - 1] == '/') {
            display = display.substring(0, display.length - 1);
          }

          newParts.add(TextSpan(
            text: display,
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                if (word == linkRex) {
                  return () async {
                    url.launch(search);
                  };
                }
                if (word == inSite) {
                  return () {};
                }
                return () {};
              }(),
            style: TextStyle(
              color: Colors.blue[400],
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
          ));

          if (after != '') {
            newParts.addAll(resolve(after, states));
          }
          return newParts;
        }
      }
    }

    RegExp head = RegExp(r'h[1-6]\..*');

    if (head.hasMatch(msg)) {
      for (Match wordMatch in head.allMatches(msg)) {
        int end = msg.substring(wordMatch.start).indexOf('\n');
        if (end == -1) {
          end = msg.length - 1;
        }

        String before = msg.substring(0, wordMatch.start);
        String match = msg.substring(wordMatch.start, wordMatch.end);
        String after = msg.substring(wordMatch.end, msg.length);

        if (before != '') {
          newParts.addAll(resolve(before, states));
        }

        newParts.add(TextSpan(
          text: match.substring(3),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
        ));

        if (after != '') {
          newParts.addAll(resolve(after, states));
        }
        return newParts;
      }
    }

    RegExp list = RegExp(r'(^|\n)\*+ ');

    if (list.hasMatch(msg)) {
      for (Match wordMatch in list.allMatches(msg)) {
        int end = msg.substring(wordMatch.start).indexOf('\n');
        if (end == -1) {
          end = msg.length - 1;
        }

        String before = msg.substring(0, wordMatch.start);
        String match = msg.substring(wordMatch.start, wordMatch.end);
        String after = msg.substring(wordMatch.end, msg.length);

        if (before != '') {
          newParts.addAll(resolve(before, states));
        }

        newParts.add(TextSpan(
          text: '\n' + '  ' * ('*'.allMatches(match).length - 1) + '• ',
          style: TextStyle(
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
        ));

        if (after != '') {
          newParts.addAll(resolve(after, states));
        }
        return newParts;
      }
    }

    RegExp tagSearch = RegExp(r'{{.*?}}');

    if (tagSearch.hasMatch(msg)) {
      for (Match wordMatch in tagSearch.allMatches(msg)) {
        int end = msg.substring(wordMatch.start).indexOf('\n');
        if (end == -1) {
          end = msg.length - 1;
        }

        String before = msg.substring(0, wordMatch.start);
        String match = msg.substring(wordMatch.start, wordMatch.end);
        String after = msg.substring(wordMatch.end, msg.length);

        if (before != '') {
          newParts.addAll(resolve(before, states));
        }

        newParts.add(TextSpan(
          text: match.replaceAllMapped(RegExp(r'(^{{*)|(}}*$)'), (b) => ''),
          recognizer: new TapGestureRecognizer()
            ..onTap = () {
              Navigator.of(context)
                  .push(new MaterialPageRoute<Null>(builder: (context) {
                return new SearchPage(new Tagset.parse(match.split('|')[0]));
              }));
            },
          style: TextStyle(
            color: Colors.blue[400],
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
        ));

        if (after != '') {
          newParts.addAll(resolve(after, states));
        }
        return newParts;
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
  };

  // call with initial string
  List<dynamic> parts = resolve(msg, states);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: toWidgets(parts),
  );
}

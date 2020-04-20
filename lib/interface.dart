import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import 'client.dart';

Widget wikiDialog(BuildContext context, String tag) {
  return AlertDialog(
    title: Text(tag),
    content: new ConstrainedBox(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: badTextField(context, snapshot.data[0]['body']),
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
        )),
    actions: [
      FlatButton(
        child: Text('OK'),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}

Widget badTextField(BuildContext context, String msg, {bool darkText = false}) {
  RegExp quoteMatch = RegExp(
    r'[\s\n]*\[(quote|code)\]((.)*?)\[/\1\]',
    dotAll: true,
  );

  List<Widget> resolve(List<Widget> parts) {
    List<Widget> newParts = [];
    for (Widget part in parts) {
      if (part is Text) {
        if (quoteMatch.hasMatch(part.data)) {
          Match match = quoteMatch.firstMatch(part.data);
          int last = 0;
          if (match.start != 0) {
            newParts
                .addAll(resolve([Text(part.data.substring(0, match.start))]));
            last = match.start;
          }
          String child = part.data.substring(last, match.end);
          child = child.replaceAllMapped(
              RegExp(r'[\s\n]*\[\/*(quote|code)\][\s\n]*'), (match) {
            return '';
          });

          newParts.add(
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: resolve([Text(child)]),
                    ),
                  ),
                ]),
              ),
            ),
          );
          if (match.end != part.data.length) {
            newParts.addAll(resolve([
              Text('\n' +
                  part.data
                      .substring(match.end, part.data.length)
                      .replaceAllMapped(RegExp(r'^[\s\n]*'), (match) {
                    return '';
                  }))
            ]));
          }
        } else {
          newParts.add(
            _parsedTextField(context, part.data, darkText: darkText),
          );
        }
      } else {
        newParts.add(part);
      }
    }
    return newParts;
  }

  List<Widget> parts = resolve([Text(msg)]);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: parts,
  );
}

Widget dTextField(BuildContext context, String msg, {bool darkText = false}) {
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

  List<dynamic> resolve(String msg, Map<String, bool> states) {
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

    List<dynamic> newParts = [];
    if (msg.contains('[')) {
      String before = '';
      String tag = '';
      String after = '';
      bool isFat = false;
      int start = -1;
      int end = msg.indexOf(']') + 1;
      for (Match startMatch in '['.allMatches(msg)) {
        if (startMatch.start != 0 && msg[startMatch.start - 1] == '\\') {
          continue;
        }
        int double = msg.indexOf('[[');
        if (double == startMatch.start) {
          start = startMatch.start;
          isFat = true;
          if (msg.indexOf(']]') != -1) {
            end = msg.indexOf(']]') + 2;
          } else {
            continue;
          }
          break;
        }
        int second = msg.substring(startMatch.start + 1).indexOf('[');
        if (second != -1) {
          if ((startMatch.start + second) < end) {
            continue;
          }
        }
        end = -1;
        for (Match endMatch in ']'.allMatches(msg)) {
          if (endMatch.start < startMatch.start) {
            continue;
          }
          end = endMatch.start;
          break;
        }
        if (end == -1) {
          continue;
        }
        start = startMatch.start;
        break;
      }

      print(start);

      if (start != -1) {
        if (start > 0) {
          before = msg.substring(0, start);
        }
        tag = msg.substring(start + 1, end);
        after = msg.substring(end + 1, msg.length);

        if (before != '') {
          newParts.addAll(resolve(before, states));
        }

        if (tag != '') {
          bool active;
          String key;
          if (tag[0] == '/') {
            key = tag.split('=')[0].substring(1);
            active = false;
          } else {
            key = tag.split('=')[0];
            active = true;
          }
          String value = '';
          if (tag.contains('=')) {
            value = tag.split('=')[1];
          }

          if (isFat) {
            newParts.add(TextSpan(
              text: tag.substring(1, tag.length - 1),
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
          }

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
            case 'quote':
              if (active) {
                String end = '[/quote]';
                int split = after.indexOf(end);
                String quoted = after.substring(1, split - 1);
                newParts.add(quoteWrap(toWidgets(resolve(quoted, states))));
                after = after.substring(split + end.length);
              }
              break;
            default:
            // newParts.addAll(resolve('\[$tag\]', states));
          }
        }

        newParts.addAll(resolve(after, states));
        return newParts;
      }
    }
    return [
      TextSpan(
        text: msg,
        style: TextStyle(
          fontWeight: states['bold'] ? FontWeight.bold : FontWeight.normal,
          fontStyle: states['italic'] ? FontStyle.italic : FontStyle.normal,
          decoration: TextDecoration.combine([
            states['strike'] ? TextDecoration.lineThrough : TextDecoration.none,
            states['underline']
                ? TextDecoration.underline
                : TextDecoration.none,
          ]),
        ),
      ),
    ];
  }

  Map<String, bool> states = {
    'bold': false,
    'italic': false,
    'strike': false,
    'underline': false,
  };

  List<dynamic> parts = resolve(msg, states);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: toWidgets(parts),
  );
}

Widget _parsedTextField(BuildContext context, String msg,
    {bool darkText = false}) {
  return ParsedText(
    text: msg,
    style: new TextStyle(
      color: darkText ? Colors.grey[600] : Colors.grey[300],
    ),
    parse: <MatchText>[
      new MatchText(
        type: ParsedType.CUSTOM,
        pattern: r'h[1-6]\..*',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        renderText: ({String str, String pattern}) {
          String display = str;
          display = display.replaceAll(RegExp(r'h[1-6]\. ?'), '');
          Map<String, String> map = Map<String, String>();
          map['display'] = display;
          map['value'] = str;
          return map;
        },
      ),
      new MatchText(
          type: ParsedType.CUSTOM,
          pattern: r'\[b\].*\[/b\]',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          renderText: ({String str, String pattern}) {
            String display = str;
            display = display.replaceAll('[b]', '');
            display = display.replaceAll('[/b]', '');
            Map<String, String> map = Map<String, String>();
            map['display'] = display;
            map['value'] = str;
            return map;
          }),
      new MatchText(
          type: ParsedType.CUSTOM,
          pattern: r'\[i\].*\[/i\]',
          style: TextStyle(
            fontStyle: FontStyle.italic,
          ),
          renderText: ({String str, String pattern}) {
            String display = str;
            display = display.replaceAll('[i]', '');
            display = display.replaceAll('[/i]', '');
            Map<String, String> map = Map<String, String>();
            map['display'] = display;
            map['value'] = str;
            return map;
          }),
      new MatchText(
          type: ParsedType.CUSTOM,
          pattern: r'\[s\].*\[/s\]',
          style: TextStyle(
            fontStyle: FontStyle.italic,
          ),
          renderText: ({String str, String pattern}) {
            String display = str;
            display = display.replaceAll('[s]', '');
            display = display.replaceAll('[/s]', '');
            Map<String, String> map = Map<String, String>();
            map['display'] = display;
            map['value'] = str;
            return map;
          }),
      new MatchText(
          type: ParsedType.CUSTOM,
          pattern: r'(^|\n)\*+',
          renderText: ({String str, String pattern}) {
            String display = str;
            display = '\n' + '  ' * ('*'.allMatches(display).length - 1) + '•';
            Map<String, String> map = Map<String, String>();
            map['display'] = display;
            map['value'] = str;
            return map;
          }),
      new MatchText(
        type: ParsedType.CUSTOM,
        pattern: r'(\[\[.*?\]\])|({{.*?}})',
        style: new TextStyle(
          color: Colors.blue[400],
        ),
        renderText: ({String str, String pattern}) {
          String display = str;
          display = display.replaceAll('{{', '');
          display = display.replaceAll('}}', '');
          display = display.replaceAll('[[', '');
          display = display.replaceAll(']]', '');
          String value = display;
          if (display.contains('|')) {
            value = display.split('|')[0];
            display = display.split('|')[1];
          }
          Map<String, String> map = Map<String, String>();
          map['display'] = display;
          map['value'] = value;
          return map;
        },
        onTap: (url) {
          Navigator.of(context)
              .push(new MaterialPageRoute<Null>(builder: (context) {
            return new SearchPage(new Tagset.parse(url));
          }));
        },
      ),
      new MatchText(
          type: ParsedType.CUSTOM,
          pattern: r'(post #[0-9]{2,7})',
          style: new TextStyle(
            color: Colors.blue[400],
          ),
          onTap: (url) async {
            Post p = await client.post(int.parse(url.split('#')[1]));
            Navigator.of(context)
                .push(new MaterialPageRoute<Null>(builder: (context) {
              return new PostWidget(p);
            }));
          }),
      new MatchText(
          type: ParsedType.CUSTOM,
          pattern: r'(pool #[0-9]{1,5})',
          style: new TextStyle(
            color: Colors.blue[400],
          ),
          onTap: (url) async {
            Pool p = await client.poolById(int.parse(url.split('#')[1]));
            Navigator.of(context)
                .push(new MaterialPageRoute<Null>(builder: (context) {
              return new PoolPage(p);
            }));
          }),
      new MatchText(
        type: ParsedType.CUSTOM,
        pattern: r'(thumb #[0-9]{2,8})',
        style: new TextStyle(
          color: Colors.blue[400],
        ),
        renderText: ({String str, String pattern}) {
          Map<String, String> map = Map<String, String>();
          map['display'] = '';
          map['value'] = '';
          return map;
        },
      ),
      new MatchText(
        type: ParsedType.CUSTOM,
        pattern:
            r'(".+":)*https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*[^\s]+)',
        style: new TextStyle(
          color: Colors.blue[400],
        ),
        renderText: ({String str, String pattern}) {
          String display;
          String value;
          if (str.contains('"')) {
            display = str.split('"')[1];
            value = str.split('":')[1];
          } else {
            display = str.replaceAll('https://', '');
            value = str;
          }
          if (display[display.length - 1] == '/') {
            display = display.substring(0, display.length - 1);
          }
          Map<String, String> map = Map<String, String>();
          map['display'] = display;
          map['value'] = value;
          return map;
        },
        onTap: (url) {
          urlLauncher.launch(url);
        },
      ),
      new MatchText(
        type: ParsedType.CUSTOM,
        pattern: r'(".+":)([-a-zA-Z0-9()@:%_\+.~#?&//=]*[^\s]+)',
        style: new TextStyle(
          color: Colors.blue[400],
        ),
        renderText: ({String str, String pattern}) {
          String display;
          String value;
          display = str.split('"')[1];
          value = str.split('":')[1];
          if (display[display.length - 1] == '/') {
            display = display.substring(0, display.length - 1);
          }
          Map<String, String> map = Map<String, String>();
          map['display'] = display;
          map['value'] = value;
          return map;
        },
      ),
    ],
  );
}

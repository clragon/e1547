import 'package:e1547/post.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import 'client.dart';

class Pool {
  Map raw;

  int id;
  String name;
  String description;
  List<int> postIDs = [];
  String creator;
  String creation;
  String updated;
  bool active;

  Pool.fromRaw(this.raw) {
    id = raw['id'];
    name = raw['name'];
    description = raw['description'];
    postIDs.addAll(raw['post_ids'].cast<int>());
    creator = raw['creator_name'];
    active = raw['is_active'] as bool;
    creation = raw['created_at'];
    updated = raw['updated_at'];
  }

  Uri url(String host) =>
      new Uri(scheme: 'https', host: host, path: '/pools/$id');
}

class PoolPreview extends StatelessWidget {
  final Pool pool;
  final VoidCallback onPressed;

  const PoolPreview(
    this.pool, {
    Key key,
    this.onPressed,
  }) : super(key: key);

  static Widget dTextField(BuildContext context, String msg,
      {bool darkText = false}) {
    return new ParsedText(
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
              display =
                  '\n' + '  ' * ('*'.allMatches(display).length - 1) + '•';
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
            if(display.contains('|')) {
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
          pattern:
          r'(".+":)([-a-zA-Z0-9()@:%_\+.~#?&//=]*[^\s]+)',
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

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return new Row(
        children: <Widget>[
          new Expanded(
            child: new Container(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: new Text(
                pool.name.replaceAll('_', ' '),
                overflow: TextOverflow.ellipsis,
                style: new TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
          new Container(
            margin: EdgeInsets.only(left: 22, top: 8, bottom: 8, right: 12),
            child: Text(
              pool.postIDs.length.toString(),
              style: new TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }

    return new GestureDetector(
        onTap: this.onPressed,
        child: new Card(
            child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              height: 42,
              child: Center(child: title()),
            ),
            () {
              if (pool.description != '') {
                return new Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 0,
                    bottom: 8,
                  ),
                  child: dTextField(context, pool.description, darkText: true),
                );
              } else {
                return new Container();
              }
            }(),
          ],
        )));
  }
}

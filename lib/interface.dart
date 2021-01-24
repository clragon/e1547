import 'dart:math' as math show max, min;

import 'package:e1547/client.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/tag.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:url_launcher/url_launcher.dart' as url;

import 'http.dart';

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

Widget dTextField(BuildContext context, String msg, {bool darkText = false}) {
  Widget toWidget(TextSpan span) {
    return RichText(
      text: span,
    );
  }

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
                  ? Theme.of(context).textTheme.bodyText1.color.withOpacity(0.5)
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
                    blocked = spoilerWrap(toWidget(resolve(between, state)));
                    break;
                  case 'code':
                    blocked = quoteWrap(toWidget(getText(between, state)));
                    break;
                  case 'quote':
                    blocked = quoteWrap(toWidget(resolve(between, state)));
                    break;
                  case 'section':
                    blocked = sectionWrap(
                        toWidget(resolve(between, state)), value,
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
      Function onTap = () => url.launch(search);
      int id = int.tryParse(search.split('/').last.split('?').first);

      if (insite) {
        siteMatch = r'';
        onTap = () async => url.launch('https://${await db.host.value}$search');
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

  return toWidget(resolve(msg, state));
}

class LowercaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue prev, TextEditingValue current) {
    return current.copyWith(text: current.text.toLowerCase());
  }
}

void setFocusToEnd(TextEditingController controller) {
  controller.selection = TextSelection(
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

Future<bool> setCustomHost(BuildContext context) async {
  bool success = false;
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<String> error = ValueNotifier<String>(null);
  TextEditingController controller =
      TextEditingController(text: await db.customHost.value);
  Future<bool> submit(String text) async {
    error.value = null;
    isLoading.value = true;
    String host = text.trim();
    host = host.replaceAll(RegExp(r'^http(s)?://'), '');
    host = host.replaceAll(RegExp(r'^(www.)?'), '');
    host = host.replaceAll(RegExp(r'/$'), '');
    HttpHelper http = HttpHelper();
    if (host.isEmpty) {
      success = false;
      error.value = null;
      db.customHost.value = Future.value(null);
    } else {
      await Future.delayed(Duration(seconds: 1));
      try {
        if ((await http
            .get(host, '/')
            .then((response) => response.statusCode != 200))) {
          error.value = 'Cannot reach host';
        } else {
          switch (host) {
            case 'e621.net':
              db.customHost.value = Future.value(host);
              error.value = null;
              success = true;
              break;
            case 'e926.net':
              error.value = 'default host cannot be custom host';
              success = false;
              break;
            default:
              error.value = 'Host API incompatible';
              success = false;
              break;
          }
        }
      } catch (SocketException) {
        error.value = 'Cannot reach host';
      }
    }

    isLoading.value = false;
    return error.value == null;
  }

  await showDialog(
      context: context,
      child: AlertDialog(
        title: Text('Custom Host'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: isLoading,
                  builder: (BuildContext context, value, Widget child) =>
                      crossFade(
                          showChild: value,
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Container(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          )),
                ),
                Expanded(
                    child: ValueListenableBuilder(
                  valueListenable: error,
                  builder: (BuildContext context, value, Widget child) {
                    return Theme(
                      data: value != null
                          ? Theme.of(context).copyWith(
                              accentColor: Theme.of(context).errorColor)
                          : Theme.of(context),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.url,
                        autofocus: true,
                        maxLines: 1,
                        decoration: InputDecoration(
                            labelText: 'url', border: UnderlineInputBorder()),
                        onSubmitted: (_) async {
                          if (await submit(controller.text)) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    );
                  },
                ))
              ],
            ),
            ValueListenableBuilder(
              valueListenable: error,
              builder: (BuildContext context, value, Widget child) {
                return crossFade(
                  duration: Duration(milliseconds: 200),
                  showChild: value != null,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.error_outline,
                            size: 14,
                            color: Theme.of(context).errorColor,
                          ),
                        ),
                        Text(
                          value ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).errorColor,
                          ),
                        )
                      ],
                    ),
                  ),
                  secondChild: Container(),
                );
              },
            ),
          ],
        ),
        actions: [
          FlatButton(
            child: Text('CANCEL'),
            onPressed: Navigator.of(context).pop,
          ),
          FlatButton(
            child: Text('OK'),
            onPressed: () async {
              if (await submit(controller.text)) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ));
  return success;
}

class TextEditor extends StatefulWidget {
  final String title;
  final String content;
  final bool richEditor;
  final Future<bool> Function(BuildContext context, String text) validator;

  const TextEditor({
    @required this.title,
    this.content,
    @required this.validator,
    this.richEditor = true,
  });

  @override
  State<StatefulWidget> createState() {
    return _TextEditorState();
  }
}

class _TextEditorState extends State<TextEditor> with TickerProviderStateMixin {
  bool showBar = true;
  bool showBlocks = false;
  bool isLoading = false;
  TabController tabController;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      vsync: this,
      length: 2,
    );
    textController.text = widget.content ?? '';
    tabController.addListener(() {
      if (tabController.index == 0) {
        setState(() {
          showBar = true;
        });
      } else {
        setState(() {
          FocusScope.of(context).unfocus();
          showBar = false;
        });
      }
    });
    textController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget frame(Widget child) {
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: child,
                  )
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget editor() {
      return frame(Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: TextField(
          controller: textController,
          keyboardType: TextInputType.multiline,
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'type here...',
          ),
          maxLines: null,
        ),
      ));
    }

    Widget preview() {
      return frame(
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: textController.text.trim().isNotEmpty
                ? dTextField(context, textController.text.trim())
                : Text('your text here',
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .color
                            .withOpacity(0.35),
                        fontStyle: FontStyle.italic)),
          ),
        ),
      );
    }

    Widget fab() {
      return Builder(
        builder: (context) {
          return FloatingActionButton(
            heroTag: 'float',
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(Icons.check, color: Theme.of(context).iconTheme.color),
            onPressed: () async {
              String text = textController.text.trim();
              setState(() {
                isLoading = true;
              });
              if ((await widget.validator?.call(context, text)) ?? true) {
                Navigator.of(context).pop();
              }
              setState(() {
                isLoading = false;
              });
            },
          );
        },
      );
    }

    Widget hotkeys() {
      void enclose(String blockTag, {String endTag}) {
        String before = textController.text
            .substring(0, textController.selection.baseOffset);
        String block = textController.text.substring(
            textController.selection.baseOffset,
            textController.selection.extentOffset);
        String after = textController.text
            .substring(textController.selection.extentOffset);
        int pos = before.length + block.length + '[$blockTag]'.length;
        block = '[$blockTag]$block[/${endTag ?? blockTag}]';
        textController.text = '$before$block$after';
        textController.selection = TextSelection(
          baseOffset: pos,
          extentOffset: pos,
        );
      }

      return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: () {
                      List<Widget> buttons = [];
                      int rowSize =
                          (MediaQuery.of(context).size.width / 40).round();
                      List<Widget> blockButtons = [
                        IconButton(
                          icon: Icon(Icons.subject),
                          onPressed: () =>
                              enclose('section,expanded=', endTag: 'section'),
                          tooltip: 'Section',
                        ),
                        IconButton(
                          icon: Icon(Icons.format_quote),
                          onPressed: () => enclose('quote'),
                          tooltip: 'Quote',
                        ),
                        IconButton(
                          icon: Icon(Icons.code),
                          onPressed: () => enclose('code'),
                          tooltip: 'Code',
                        ),
                        IconButton(
                          icon: Icon(Icons.warning),
                          onPressed: () => enclose('spoiler'),
                          tooltip: 'Spoiler',
                        ),
                      ];
                      List<Widget> textbuttons = [
                        IconButton(
                          icon: Icon(Icons.format_bold),
                          onPressed: () => enclose('b'),
                          tooltip: 'Bold',
                        ),
                        IconButton(
                          icon: Icon(Icons.format_italic),
                          onPressed: () => enclose('i'),
                          tooltip: 'Italic',
                        ),
                        IconButton(
                          icon: Icon(Icons.format_underlined),
                          onPressed: () => enclose('u'),
                          tooltip: 'Underlined',
                        ),
                        IconButton(
                          icon: Icon(Icons.format_strikethrough),
                          onPressed: () => enclose('s'),
                          tooltip: 'Strikethrough',
                        ),
                      ];

                      if (rowSize > 10) {
                        buttons.addAll(textbuttons);
                        buttons.addAll(blockButtons);
                      } else {
                        buttons.add(crossFade(
                          showChild: showBlocks,
                          child: Row(
                            children: blockButtons,
                          ),
                          secondChild: Row(
                            children: textbuttons,
                          ),
                        ));
                        buttons.addAll([
                          VerticalDivider(),
                          IconButton(
                            icon: Icon(showBlocks
                                ? Icons.expand_less
                                : Icons.expand_more),
                            onPressed: () => setState(() {
                              showBlocks = !showBlocks;
                            }),
                          ),
                        ]);
                      }
                      return buttons;
                    }(),
                  ),
                )
              ]));
        },
      );
    }

    return Scaffold(
        floatingActionButton: fab(),
        bottomSheet: () {
          if (isLoading) {
            return Padding(
                padding: EdgeInsets.only(
                    left: 10.0, right: 10.0, bottom: 16, top: 16),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        )
                      ],
                    ),
                  )
                ]));
          }
          return (widget.richEditor && showBar) ? hotkeys() : null;
        }(),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                floating: true,
                pinned: false,
                snap: false,
                leading: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(widget.title),
                bottom: widget.richEditor
                    ? TabBar(
                        controller: tabController,
                        tabs: [
                          Tab(text: 'WRITE'),
                          Tab(text: 'PREVIEW'),
                        ],
                      )
                    : null,
              ),
            ];
          },
          body: Padding(
            padding: EdgeInsets.only(bottom: 42),
            child: widget.richEditor
                ? TabBarView(
                    controller: tabController,
                    children: [
                      editor(),
                      preview(),
                    ],
                  )
                : editor(),
          ),
        ));
  }
}

Widget popMenuListTile(String title, IconData icon) {
  return Row(
    children: <Widget>[
      Icon(icon, size: 20),
      Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
        child: Text(title),
      ),
    ],
  );
}

class RangeDialog extends StatefulWidget {
  RangeDialog({this.title, this.value, this.max, this.min, this.division});

  final Widget title;
  final int value;
  final int max;
  final int min;
  final int division;

  @override
  _RangeDialogState createState() => _RangeDialogState();
}

class _RangeDialogState extends State<RangeDialog> {
  final TextEditingController _controller = TextEditingController();
  int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    Widget numberWidget() {
      _controller.text = _value.toString();
      FocusScope.of(context)
          .requestFocus(FocusNode()); // Clear text entry focus, if any.

      Widget number = TextField(
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 48.0),
        textAlign: TextAlign.center,
        decoration: InputDecoration(border: InputBorder.none),
        controller: _controller,
        onSubmitted: (v) => Navigator.of(context).pop(int.parse(v)),
      );

      return Container(
        padding: EdgeInsets.only(bottom: 20.0),
        child: number,
      );
    }

    Widget sliderWidget() {
      return Slider(
          min: math.min(widget.min != null ? widget.min.toDouble() : 0.0,
              _value.toDouble()),
          max: math.max(widget.max.toDouble(), _value.toDouble()),
          divisions: widget.division,
          value: _value.toDouble(),
          activeColor: Theme.of(context).accentColor,
          onChanged: (v) {
            setState(() => _value = v.toInt());
          });
    }

    return AlertDialog(
      title: widget.title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          numberWidget(),
          sliderWidget(),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text('save'),
          onPressed: () {
            int textValue = int.parse(_controller.text);
            Navigator.of(context).pop(textValue ?? _value);
          },
        ),
      ],
    );
  }
}

Widget pageLoader(
    {@required Widget child,
    Widget onLoading,
    Widget onEmpty,
    bool isLoading,
    bool isEmpty}) {
  return Stack(children: [
    Visibility(
      visible: isLoading,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: onLoading,
            ),
          ],
        ),
      ),
    ),
    child,
    Visibility(
      visible: (isEmpty),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 32,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: onEmpty,
            ),
          ],
        ),
      ),
    ),
  ]);
}

class DataProvider<T> {
  bool willLoad = false;
  bool isLoading = false;
  ValueNotifier<String> search = ValueNotifier('');
  ValueNotifier<List<List<T>>> pages = ValueNotifier([]);
  Future<List<T>> Function(String search, int page) provider;
  Future<List<T>> Function(String search, List<List<T>> pages) extendedProvider;

  List<T> get items {
    return pages.value
        .fold<Iterable<T>>(Iterable.empty(), (a, b) => a.followedBy(b))
        .toList();
  }

  void _init(String search) {
    this.search.value = sortTags(search ?? '');
    // this should probably include db.denylist,
    // but it will fuck with wikidialogues
    [db.host, db.credentials, this.search]
        .forEach((notifier) => notifier.addListener(resetPages));
    loadNextPage();
  }

  DataProvider({String search, @required this.provider}) {
    _init(search);
  }

  DataProvider.extended({String search, @required this.extendedProvider}) {
    _init(search);
  }

  Future<void> resetPages() async {
    pages.value = [];
    if (pages.value.length == 0) {
      if (isLoading) {
        willLoad = true;
      } else {
        loadNextPage(reset: true);
      }
    }
  }

  Future<void> loadNextPage({bool reset = false}) async {
    if (!isLoading) {
      isLoading = true;
      List<T> nextPage = [];

      int page = reset ? 1 : pages.value.length + 1;

      if (extendedProvider != null) {
        nextPage.addAll(await extendedProvider(search.value, pages.value));
      } else {
        nextPage.addAll(await provider(search.value, page));
      }

      if (nextPage.length != 0 || pages.value.length == 0) {
        if (reset) {
          pages.value = [nextPage];
        } else {
          pages.value = List.from(pages.value..add(nextPage));
        }
      }
      isLoading = false;
      if (willLoad) {
        willLoad = false;
        resetPages();
      }
    }
  }
}

String getAge(String date) {
  Duration duration = DateTime.now().difference(DateTime.parse(date).toLocal());

  List<int> periods = [
    1,
    60,
    3600,
    86400,
    604800,
    2419200,
    29030400,
  ];

  int ago;
  String measurement;
  for (int period = 0; period <= periods.length; period++) {
    if (period == periods.length || duration.inSeconds < periods[period]) {
      if (period != 0) {
        ago = (duration.inSeconds / periods[period - 1]).round();
      } else {
        ago = duration.inSeconds;
      }
      bool single = (ago == 1);
      switch (periods[period - 1] ?? 1) {
        case 1:
          measurement = single ? 'second' : 'seconds';
          break;
        case 60:
          measurement = single ? 'minute' : 'minutes';
          break;
        case 3600:
          measurement = single ? 'hour' : 'hours';
          break;
        case 86400:
          measurement = single ? 'day' : 'days';
          break;
        case 604800:
          measurement = single ? 'week' : 'weeks';
          break;
        case 2419200:
          measurement = single ? 'month' : 'months';
          break;
        case 29030400:
          measurement = single ? 'year' : 'years';
          break;
      }
      break;
    }
  }
  return '$ago $measurement ago';
}

Widget crossFade({
  @required bool showChild,
  @required Widget child,
  Widget secondChild,
  Duration duration,
}) {
  return AnimatedCrossFade(
    duration: duration ?? Duration(milliseconds: 400),
    crossFadeState:
        showChild ? CrossFadeState.showFirst : CrossFadeState.showSecond,
    firstChild: child,
    secondChild: secondChild ?? Container(),
  );
}

Widget tagInputField({
  @required String labelText,
  @required Function onSubmit,
  @required TextEditingController controller,
  bool multiInput = true,
  int category,
}) {
  setFocusToEnd(controller);
  controller.text = sortTags(controller.text);
  if (controller.text != '') {
    controller.text = controller.text + ' ';
  }
  return TypeAheadField(
    direction: AxisDirection.up,
    hideOnEmpty: true,
    hideOnError: true,
    keepSuggestionsOnSuggestionSelected: true,
    textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        autofocus: true,
        maxLines: 1,
        inputFormatters: !multiInput
            ? [
                LowercaseTextInputFormatter(),
                FilteringTextInputFormatter.deny(' ')
              ]
            : [LowercaseTextInputFormatter()],
        decoration: InputDecoration(
            labelText: labelText, border: UnderlineInputBorder()),
        onSubmitted: (_) {
          if (onSubmit != null) {
            onSubmit();
          }
        }),
    onSuggestionSelected: (suggestion) {
      List<String> tags = sortTags(controller.text).split(' ');
      List<String> before = [];
      for (String tag in tags) {
        before.add(tag);
        if (before.join(' ').length >= controller.selection.extent.offset) {
          String operator = tags[tags.indexOf(tag)][0];
          if (operator != '-' && operator != '~') {
            operator = '';
          }
          tags[tags.indexOf(tag)] = operator + suggestion['name'];
          break;
        }
      }
      controller.text = tags.join(' ') + ' ';
      setFocusToEnd(controller);
    },
    itemBuilder: (BuildContext context, itemData) {
      String count = itemData['post_count'].toString();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: getCategoryColor(categories.entries
                    .firstWhere((e) => e.value == itemData['category'],
                        orElse: () => MapEntry('', 0))
                    .key),
                height: 54,
                width: 5,
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  itemData['name'],
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              itemData['post_count'] >= 1000
                  ? '${count.substring(0, count.length - 3)}k'
                  : count.toString(),
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      );
    },
    loadingBuilder: (BuildContext context) => Container(height: 0),
    noItemsFoundBuilder: (BuildContext context) {
      return ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    },
    suggestionsCallback: (String pattern) async {
      List<String> tags = controller.text.split(' ');
      List<String> before = [];
      int selection = 0;
      for (String tag in tags) {
        before.add(tag);
        if (before.join(' ').length >= controller.selection.extent.offset) {
          selection = tags.indexOf(tag);
          break;
        }
      }
      if (noDash(tags[selection].trim()).isNotEmpty) {
        return (await client.autocomplete(noDash(tags[selection]),
            category: category));
      } else {
        return [];
      }
    },
  );
}

String noDash(String s) {
  if (s.isNotEmpty) {
    if (s[0] == '-' || s[0] == '~') {
      return s.substring(1);
    } else {
      return s;
    }
  }
  return '';
}

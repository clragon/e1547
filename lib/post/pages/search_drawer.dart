import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';

class SearchDrawer extends StatefulWidget {
  final PostProvider provider;

  const SearchDrawer({this.provider});

  @override
  _SearchDrawerState createState() => _SearchDrawerState();
}

class _SearchDrawerState extends State<SearchDrawer> {
  Function update;

  @override
  void initState() {
    super.initState();
    update = () => mounted ? setState(() {}) : () {};
    widget.provider.denying.addListener(update);
    widget.provider.denied.addListener(update);
    widget.provider.allowlist.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    widget.provider.denying.removeListener(update);
    widget.provider.denied.removeListener(update);
    widget.provider.allowlist.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    Widget cardWidget(String tag) {
      return Card(
          child: InkWell(
              onTap: () => wikiSheet(context: context, tag: noDash(tag)),
              onLongPress: () => wikiSheet(context: context, tag: noDash(tag)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 24,
                    width: 5,
                    decoration: BoxDecoration(
                      color: () {
                        if ('${tag[0]}' == '-') {
                          return Colors.green[300];
                        } else {
                          return Colors.red[300];
                        }
                      }(),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5)),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 6),
                    child: Text(noDash(tag.replaceAll('_', ' '))),
                  ),
                ],
              )));
    }

    Widget listEntry(MapEntry<String, List<Post>> entry) {
      return CheckboxListTile(
        value: !widget.provider.allowlist.value.contains(entry.key),
        onChanged: (value) {
          if (value) {
            widget.provider.allowlist.value.remove(entry.key);
          } else {
            widget.provider.allowlist.value.add(entry.key);
          }
          widget.provider.allowlist.value =
              List.from(widget.provider.allowlist.value);
        },
        title: Row(
          children: <Widget>[
            Expanded(
              child: Wrap(
                direction: Axis.horizontal,
                children: () {
                  List<Widget> rows = [];
                  List<String> tags = entry.key.split(' ');
                  for (String tag in tags) {
                    if (tag.isEmpty) {
                      continue;
                    }
                    rows.add(cardWidget(tag));
                  }
                  return rows;
                }(),
              ),
            ),
          ],
        ),
        secondary: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: IntTween(begin: 0, end: entry.value.length),
              duration: Duration(milliseconds: 200),
              builder: (BuildContext context, value, Widget child) {
                return Text(value.toString(),
                    style: Theme.of(context).textTheme.headline6);
              },
            ),
          ],
        ),
      );
    }

    Widget blacklistSwitch() {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: SwitchListTile(
                title: Text(
                  'Blacklist',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                subtitle: widget.provider.denying.value
                    ? TweenAnimationBuilder(
                        tween: IntTween(
                            begin: 0, end: widget.provider.denied.value.length),
                        duration: Duration(milliseconds: 200),
                        builder: (BuildContext context, value, Widget child) {
                          return Text('blocked $value posts');
                        },
                      )
                    : null,
                secondary: Icon(Icons.block),
                value: widget.provider.denying.value,
                onChanged: (value) => widget.provider.denying.value = value),
          ),
          CrossFade(
              showChild: widget.provider.denied.value.isNotEmpty ||
                  widget.provider.allowlist.value.isNotEmpty,
              child: Column(
                children: () {
                  List<MapEntry<String, List<Post>>> entries = [];
                  entries.addAll(widget.provider.deniedMap.value.entries);
                  entries.addAll(widget.provider.allowlist.value
                      .map((e) => MapEntry(e, List<Post>())));
                  entries.sort((a, b) => a.key.compareTo(b.key));

                  List<Widget> children = [];
                  children.add(Divider());
                  children.addAll(entries.map(listEntry));
                  return children;
                }(),
              )),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder(
                  future: db.denylist.value,
                  builder: (context, snapshot) {
                    int count = snapshot.data?.length;
                    if (count != null && widget.provider.denying.value) {
                      count -= widget.provider.deniedMap.value.keys.length;
                      count -= widget.provider.allowlist.value.length;
                    }
                    return CrossFade(
                      showChild: snapshot.hasData && count > 0,
                      child: TweenAnimationBuilder(
                        tween: IntTween(begin: 0, end: count ?? 0),
                        duration: Duration(milliseconds: 200),
                        builder: (BuildContext context, value, Widget child) {
                          return Text(
                            '$value inactive entries',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .color
                                  .withOpacity(0.35),
                            ),
                          );
                        },
                      ),
                    );
                  }),
            ],
          ),
        ],
      );
    }

    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Search'),
          leading: BackButton(),
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Builder(
              builder: (context) {
                return blacklistSwitch();
              },
            )
          ],
        ),
      ),
    );
  }
}

class SearchTag {
  final String category;
  final String tag;
  final int count;

  SearchTag({
    @required this.category,
    @required this.tag,
    @required this.count,
  });
}

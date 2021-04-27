import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/post/detail/display.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class SearchDrawer extends StatelessWidget {
  final PostProvider provider;

  SearchDrawer({this.provider});

  Widget cardWidget(String tag) {
    return Card(
      child: TagGesture(
        safe: true,
        tag: tagToName(tag),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 24,
              width: 5,
              decoration: BoxDecoration(
                color: (tag[0] == '-') ? Colors.green[300] : Colors.red[300],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 6),
              child: Text(tagToCard(tag)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        provider.denying,
        provider.denied,
        provider.allowlist,
      ]),
      builder: (context, child) {
        Widget listEntry(MapEntry<String, List<Post>> entry) {
          return CheckboxListTile(
            value: !provider.allowlist.value.contains(entry.key),
            onChanged: (value) {
              if (value) {
                provider.allowlist.value.remove(entry.key);
              } else {
                provider.allowlist.value.add(entry.key);
              }
              provider.allowlist.value = List.from(provider.allowlist.value);
            },
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Wrap(
                    direction: Axis.horizontal,
                    children: entry.key
                        .split(' ')
                        .where((tag) => tag.isNotEmpty)
                        .map((tag) => cardWidget(tag))
                        .toList(),
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
                    subtitle: provider.denying.value
                        ? TweenAnimationBuilder(
                            tween: IntTween(
                                begin: 0, end: provider.denied.value.length),
                            duration: Duration(milliseconds: 200),
                            builder:
                                (BuildContext context, value, Widget child) {
                              return Text('blocked $value posts');
                            },
                          )
                        : null,
                    secondary: Icon(Icons.block),
                    value: provider.denying.value,
                    onChanged: (value) => provider.denying.value = value),
              ),
              CrossFade(
                showChild: provider.denied.value.isNotEmpty ||
                    provider.allowlist.value.isNotEmpty,
                child: Column(
                  children: [
                    Divider(),
                    ...([
                      ...provider.deniedMap.value.entries,
                      ...provider.allowlist.value
                          .map((e) => MapEntry(e, <Post>[])),
                    ]..sort((a, b) => a.key.compareTo(b.key)))
                        .map(listEntry),
                  ],
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: db.denylist.value,
                    builder: (context, snapshot) {
                      int count = snapshot.data?.length;
                      if (count != null && provider.denying.value) {
                        count -= provider.deniedMap.value.keys.length;
                        count -= provider.allowlist.value.length;
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
                    },
                  ),
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
                  builder: (context) => blacklistSwitch(),
                )
              ],
            ),
          ),
        );
      },
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

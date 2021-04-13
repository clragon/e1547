import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final String tags;
  SearchPage({this.tags});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  PostProvider provider;

  @override
  void initState() {
    super.initState();
    provider = PostProvider(search: widget.tags);
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: (context) => SearchPageAppBar(provider: provider),
      provider: provider,
    );
  }
}

class SearchPageAppBar extends StatefulWidget with PreferredSizeWidget {
  final PostProvider provider;

  const SearchPageAppBar({@required this.provider});

  @override
  _SearchPageAppBarState createState() => _SearchPageAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _SearchPageAppBarState extends State<SearchPageAppBar> {
  String title = '';
  Pool pool;

  void updateTitle() {
    bool matched = false;
    if (!widget.provider.search.value.contains(' ')) {
      Map<RegExp, Function(RegExpMatch match)> specials = {
        RegExp(r'^pool:(?<id>\d+)$'): (match) {
          if (pool == null) {
            client.pool(int.tryParse(match.namedGroup('id'))).then((value) {
              pool = value;
              updateTitle();
            });
          }
        },
      };

      for (MapEntry<RegExp, Function(RegExpMatch)> entry in specials.entries) {
        RegExpMatch match = entry.key.firstMatch(widget.provider.search.value);
        if (match != null) {
          entry.value(match);
          matched = true;
          break;
        }
      }
    }

    if (!matched) {
      pool = null;
    }

    title = () {
      if (pool != null) {
        return noScore(pool.name);
      }
      if (Tagset.parse(widget.provider.search.value).length == 1) {
        return noScore(widget.provider.search.value);
      }
      return 'Search';
    }();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    updateTitle();
    widget.provider.search.addListener(updateTitle);
  }

  @override
  void dispose() {
    super.dispose();
    widget.provider.search.removeListener(updateTitle);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: AnimatedSwitcher(
        duration: defaultAnimationDuration,
        child: Text(title),
        key: Key(title),
      ),
      leading: BackButton(),
      actions: [
        CrossFade(
          showChild: Tagset.parse(widget.provider.search.value).length > 0,
          child: IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              if (pool != null) {
                return poolSheet(context, pool);
              }
              return wikiSheet(
                  context: context, tag: widget.provider.search.value);
            },
          ),
        ),
      ],
    );
  }
}

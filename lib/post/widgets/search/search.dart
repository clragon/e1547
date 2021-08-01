import 'package:e1547/client.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/tag.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final String? tags;
  SearchPage({this.tags});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late PostController controller;

  @override
  void initState() {
    super.initState();
    controller = PostController(search: widget.tags);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: (context) => SearchPageAppBar(controller: controller),
      controller: controller,
    );
  }
}

class SearchPageAppBar extends StatefulWidget with PreferredSizeWidget {
  final PostController controller;

  const SearchPageAppBar({required this.controller});

  @override
  _SearchPageAppBarState createState() => _SearchPageAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _SearchPageAppBarState extends State<SearchPageAppBar> {
  String title = 'Search';
  List<Follow>? follows;
  Pool? pool;

  Future<void> updateFollows() async {
    await settings.follows.value.then((value) => follows = value);
    updateTitle();
  }

  String getTitle() {
    if (follows != null && follows!.contains(widget.controller.search.value)) {
      Follow follow = follows!.singleWhere(
          (follow) => follow.tags == widget.controller.search.value);
      if (widget.controller.itemList!.isNotEmpty) {
        follow
            .updateLatest(widget.controller.itemList!.first, foreground: true)
            .then((updated) {
          if (updated) {
            settings.follows.value = Future.value(follows);
          }
        });
      }
      if (pool != null) {
        if (follow.updatePoolName(pool)) {
          settings.follows.value = Future.value(follows);
        }
      }
      return follow.title;
    }
    if (pool != null) {
      return tagToTitle(pool!.name);
    }
    if (Tagset.parse(widget.controller.search.value).length == 1) {
      return tagToTitle(widget.controller.search.value);
    }
    return 'Search';
  }

  Future<void> updateTitle() async {
    if (widget.controller.search.value.isNotEmpty &&
        !widget.controller.search.value.contains(' ')) {
      bool matched = false;
      Map<RegExp, Function(RegExpMatch match)> specials = {
        RegExp(r'^pool:(?<id>\d+)$'): (match) async {
          if (pool == null) {
            pool = await client.pool(int.tryParse(match.namedGroup('id')!)!);
          }
        },
      };

      for (MapEntry<RegExp, Function(RegExpMatch)> entry in specials.entries) {
        RegExpMatch? match =
            entry.key.firstMatch(widget.controller.search.value);
        if (match != null) {
          await entry.value(match);
          matched = true;
          break;
        }
      }
      if (!matched) {
        pool = null;
      }
    }

    title = getTitle();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    updateTitle();
    widget.controller.addListener(updateTitle);
    settings.follows.addListener(updateFollows);
    updateFollows();
  }

  @override
  void dispose() {
    widget.controller.removeListener(updateTitle);
    settings.follows.removeListener(updateFollows);
    super.dispose();
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
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CrossFade(
              showChild:
                  Tagset.parse(widget.controller.search.value).length > 0,
              child: IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  if (pool != null) {
                    return poolSheet(context, pool!);
                  }
                  return wikiSheet(
                      context: context,
                      tag: widget.controller.search.value,
                      controller: widget.controller);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

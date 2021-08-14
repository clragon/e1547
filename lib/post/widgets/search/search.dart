import 'package:collection/collection.dart';
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

class _SearchPageState extends State<SearchPage> with LinkingMixin {
  late PostController controller = PostController(
    provider: (tags, page) =>
        client.posts(tags, page, reversePools: reversePools),
    search: widget.tags,
  );

  List<Follow>? follows;
  Pool? pool;

  bool reversePools = false;
  bool loading = true;

  String title = 'Search';

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        controller: updateTitle,
        controller.search: updatePool,
        settings.follows: updateFollows,
      };

  @override
  void dispose() {
    super.dispose();
    // call super first, to disconnect mixin listeners
    controller.dispose();
  }

  String getTitle() {
    Follow? follow = follows
        ?.singleWhereOrNull((follow) => follow.tags == controller.search.value);
    if (follow != null) {
      if (controller.itemList?.isNotEmpty ?? false) {
        follow
            .updateLatest(controller.itemList!.first, foreground: true)
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
    if (Tagset.parse(controller.search.value).length == 1) {
      return tagToTitle(controller.search.value);
    }
    return 'Search';
  }

  Future<void> updateTitle() async {
    title = getTitle();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> updateFollows() async {
    follows = await settings.follows.value;
    updateTitle();
  }

  Future<void> updatePool() async {
    setState(() {
      loading = true;
    });
    pool = null;
    Tagset input = Tagset.parse(controller.search.value);
    if (input.length == 1) {
      RegExpMatch? match = RegExp(poolRegex).firstMatch(input.toString());
      if (match != null) {
        pool = await client.pool(int.parse(match.namedGroup('id')!));
      }
    }
    setState(() {
      loading = false;
    });
    updateTitle();
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appbar() {
      return AppBar(
        title: AnimatedSwitcher(
          key: Key(title),
          child: Text(title),
          duration: defaultAnimationDuration,
        ),
        leading: BackButton(),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CrossFade(
                showChild: !loading &&
                    Tagset.parse(controller.search.value).length > 0,
                child: IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: pool != null
                      ? () => poolSheet(context, pool!)
                      : () => wikiSheet(
                            context: context,
                            tag: controller.search.value,
                            controller: controller,
                          ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return PostsPage(
      appBarBuilder: (context) => appbar(),
      controller: controller,
      drawerActions: [
        if (pool != null)
          PoolOrderSwitch(
            reversePool: reversePools,
            onChange: (value) {
              setState(() {
                reversePools = value;
              });
              controller.refresh();
            },
          ),
      ],
    );
  }
}

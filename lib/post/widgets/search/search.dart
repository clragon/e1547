import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final String? tags;
  final bool reversePools;

  const SearchPage({this.tags, this.reversePools = false});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with ListenerCallbackMixin {
  late bool reversePools = widget.reversePools;
  late PostController controller = PostController(
    search: widget.tags,
    provider: (tags, page, force) => client.posts(
      page,
      search: tags,
      reversePools: reversePools,
      force: force,
    ),
  );
  List<Follow>? follows;
  Pool? pool;
  bool loading = true;
  String title = 'Search';

  void updateTitle() {
    if (mounted) {
      setState(() {
        title = getTitle();
      });
    }
  }

  void updateFollows() {
    follows = List.from(settings.follows.value);
    updateTitle();
  }

  @override
  Map<ChangeNotifier, VoidCallback> get initListeners => {
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
            settings.follows.value = follows!;
          }
        });
      }
      if (pool != null) {
        if (follow.updatePool(pool!)) {
          settings.follows.value = follows!;
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

  Future<void> updatePool() async {
    setState(() {
      loading = true;
    });
    pool = null;
    Tagset input = Tagset.parse(controller.search.value);
    if (input.length == 1) {
      RegExpMatch? match = poolRegex().firstMatch(input.toString());
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
    PreferredSizeWidget appbar(BuildContext context) {
      return DefaultAppBar(
        title: Text(title),
        leading: BackButton(),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CrossFade(
                  showChild: !loading &&
                      Tagset.parse(controller.search.value).isNotEmpty,
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
                ContextDrawerButton(),
              ],
            ),
          ),
        ],
      );
    }

    return PostsPage(
      appBarBuilder: appbar,
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
              Navigator.of(context).maybePop();
            },
          ),
      ],
    );
  }
}

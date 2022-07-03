import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final String? tags;
  final bool reversePools;

  const SearchPage({this.tags, this.reversePools = false});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with ListenerCallbackMixin {
  late bool reversePools = widget.reversePools;
  bool loadingInfo = true;
  Pool? pool;

  late PostsController controller = PostsController(
    search: widget.tags,
    provider: (tags, page, force) => client.posts(
      page,
      search: tags,
      reversePools: reversePools,
      force: force,
    ),
  );

  @override
  Map<ChangeNotifier, VoidCallback> get initListeners => {
        controller.search: updateSearch,
        followController: updateFollow,
      };

  Future<void> updateSearch() async {
    await updatePool();
    await controller.waitForFirstPage();
    await updateFollow();
    controller.addToHistory(context, pool);
  }

  Future<void> updateFollow() async {
    Follow? follow = followController.getFollow(controller.search.value);
    if (follow != null) {
      if (controller.itemList?.isNotEmpty ?? false) {
        Follow updated = follow.withLatest(
          client.host,
          controller.itemList!.first,
          foreground: mounted,
        );
        if (updated != follow) {
          followController.replace(
            follow,
            updated,
          );
        }
      }
      if (pool != null) {
        Follow updated = follow.withPool(pool!);
        if (updated != follow) {
          followController.replace(
            follow,
            updated,
          );
        }
      }
    }
  }

  Future<void> updatePool() async {
    setState(() {
      loadingInfo = true;
    });
    Tagset input = Tagset.parse(controller.search.value);
    RegExpMatch? match = poolRegex().firstMatch(input.toString());
    if (input.length == 1 &&
        match != null &&
        match.namedGroup('id')! != pool?.id.toString()) {
      pool = await client.pool(int.parse(match.namedGroup('id')!));
    } else {
      pool = null;
    }
    setState(() {
      loadingInfo = false;
    });
  }

  String getTitle() {
    Follow? follow = followController.getFollow(controller.search.value);
    if (follow != null) {
      return follow.name;
    }
    if (pool != null) {
      return tagToTitle(pool!.name);
    }
    if (Tagset.parse(controller.search.value).length == 1) {
      return tagToTitle(controller.search.value);
    }
    return 'Search';
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      controller: controller,
      appBar: DefaultAppBar(
        title: Text(getTitle()),
        leading: const BackButton(),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                CrossFade(
                  showChild: !loadingInfo &&
                      Tagset.parse(controller.search.value).isNotEmpty,
                  child: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: pool != null
                        ? () => poolSheet(context, pool!)
                        : () => tagSearchSheet(
                              context: context,
                              tag: controller.search.value,
                              controller: controller,
                            ),
                  ),
                ),
                const ContextDrawerButton(),
              ],
            ),
          ),
        ],
      ),
      drawerActions: [
        if (pool != null)
          PoolOrderSwitch(
            reversePool: reversePools,
            onChange: (value) {
              setState(() => reversePools = value);
              controller.refresh();
              Navigator.of(context).maybePop();
            },
          ),
      ],
    );
  }
}

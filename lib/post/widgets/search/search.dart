import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PostsSearchPage extends StatefulWidget {
  const PostsSearchPage({
    this.tags,
    this.orderPoolsByOldest = true,
    this.readerMode = false,
  });

  final String? tags;
  final bool orderPoolsByOldest;
  final bool readerMode;

  @override
  State<PostsSearchPage> createState() => _PostsSearchPageState();
}

class _PostsSearchPageState extends State<PostsSearchPage> {
  late bool orderPoolsByOldest = widget.orderPoolsByOldest;
  late bool readerMode = widget.readerMode;
  bool loadingInfo = true;
  Pool? pool;
  Follow? follow;

  @override
  Widget build(BuildContext context) {
    return PostsProvider(
      search: widget.tags,
      fetch: (controller, tags, page, force) => controller.client.posts(
        page,
        search: tags,
        orderPoolsByOldest: orderPoolsByOldest,
        force: force,
        cancelToken: controller.cancelToken,
      ),
      child: Consumer3<PostsController, FollowsService, Client>(
        builder: (context, controller, follows, client, child) {
          Future<void> updateFollow() async {
            follow =
                await follows.getFollow(client.host, controller.search.value);
            if (follow != null) {
              Follow updated = follow!;
              if (controller.itemList?.isNotEmpty ?? false) {
                updated = follow!.withLatest(
                  controller.itemList!.first,
                  foreground: mounted,
                );
              }
              if (pool != null) {
                updated = updated.withPool(pool!);
              }
              if (updated != follow) {
                await follows.replace(updated);
              }
              setState(() => follow = updated);
            }
          }

          Future<void> updatePool() async {
            if (!mounted) return;
            setState(() {
              loadingInfo = true;
            });
            Tagset input = Tagset.parse(controller.search.value);
            RegExpMatch? match = poolRegex().firstMatch(input.toString());
            if (input.length == 1 && match != null) {
              if (match.namedGroup('id')! != pool?.id.toString()) {
                try {
                  pool = await client.pool(int.parse(match.namedGroup('id')!));
                } on ClientException {
                  pool = null;
                }
              }
            } else {
              pool = null;
            }
            if (!mounted) return;
            setState(() {
              loadingInfo = false;
            });
          }

          Future<void> updateSearch() async {
            if (!mounted) return;
            String host = context.read<Client>().host;
            HistoriesService historiesService =
                context.read<HistoriesService>();
            await updatePool();
            try {
              await controller.waitForFirstPage();
            } on ClientException {
              return;
            }
            await updateFollow();
            if (pool != null) {
              historiesService.addPool(host, pool!, posts: controller.itemList);
            } else {
              historiesService.addPostSearch(host, controller.search.value,
                  posts: controller.itemList);
            }
          }

          String getTitle() {
            if (follow != null) {
              return follow!.name;
            }
            if (pool != null) {
              return tagToName(pool!.name);
            }
            if (Tagset.parse(controller.search.value).length == 1) {
              return tagToName(controller.search.value);
            }
            return 'Search';
          }

          return SubListener(
            initialize: true,
            listenable: controller,
            listener: () => WidgetsBinding.instance
                .addPostFrameCallback((_) => updateSearch()),
            child: PostsPage(
              controller: controller,
              displayType: readerMode ? PostDisplayType.comic : null,
              appBar: DefaultAppBar(
                title: Text(getTitle()),
                actions: [
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
                              ),
                    ),
                  ),
                  const ContextDrawerButton(),
                ],
              ),
              drawerActions: [
                if (pool != null)
                  Builder(
                    builder: (context) => PoolReaderSwitch(
                      readerMode: readerMode,
                      onChange: (value) {
                        setState(() => readerMode = value);
                        Scaffold.of(context).closeEndDrawer();
                      },
                    ),
                  ),
                if (pool != null)
                  Builder(
                    builder: (context) => PoolOrderSwitch(
                      oldestFirst: orderPoolsByOldest,
                      onChange: (value) {
                        setState(() => orderPoolsByOldest = value);
                        controller.refresh();
                        Scaffold.of(context).closeEndDrawer();
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:e1547/domain/domain.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({
    super.key,
    this.query,
    this.orderPoolsByOldest = true,
    this.readerMode = false,
  });

  final QueryMap? query;
  final bool orderPoolsByOldest;
  final bool readerMode;

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late bool readerMode = widget.readerMode;
  bool loadingInfo = true;
  Pool? pool;
  Follow? follow;
  QueryMap? lastQuery;

  @override
  Widget build(BuildContext context) {
    return PostProvider(
      query: widget.query,
      orderPools: widget.orderPoolsByOldest,
      child: Consumer2<PostController, Domain>(
        builder: (context, controller, domain, child) {
          Future<void> updateFollow() async {
            String? tags = controller.query['tags'];
            if (tags?.nullWhenEmpty != null) {
              follow = await domain.follows.getByTags(tags: tags!);
            } else {
              follow = null;
            }
            if (follow != null) {
              await domain.follows.syncWith(
                id: follow!.id,
                posts: controller.items,
                pool: pool,
              );
              if (!context.mounted) return;
              Follow updated = await domain.follows.get(id: follow!.id);
              if (follow == updated) return;
              if (!context.mounted) return;
              setState(() => follow = updated);
            }
          }

          Future<void> updatePool() async {
            if (!mounted) return;
            setState(() {
              loadingInfo = true;
            });
            RegExpMatch? match = poolRegex().firstMatch(
              controller.query['tags'] ?? '',
            );
            if (match != null) {
              if (match.namedGroup('id')! != pool?.id.toString()) {
                try {
                  pool = await domain.pools.get(
                    id: int.parse(match.namedGroup('id')!),
                  );
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
            if (mapEquals(lastQuery, controller.query)) return;
            lastQuery = controller.query;
            final domain = context.read<Domain>();
            await updatePool();
            await controller.waitForNextPage();
            if (controller.error != null) return;
            await updateFollow();
            if (pool != null) {
              domain.histories.useAdd().mutate(
                PoolHistoryRequest.item(pool: pool!, posts: controller.items),
              );
            } else {
              domain.histories.useAdd().mutate(
                PostHistoryRequest.search(
                  query: controller.query,
                  posts: controller.items,
                ),
              );
            }
          }

          String getTitle() {
            if (follow != null) {
              return follow!.name;
            }
            if (pool != null) {
              return tagToName(pool!.name);
            }
            String tags = (controller.query['tags'] ?? '').trim();
            if (tags.isEmpty) return 'Search';
            return tagToName(tags);
          }

          return SubListener(
            initialize: true,
            listenable: controller,
            listener: () => WidgetsBinding.instance.addPostFrameCallback(
              (_) => updateSearch(),
            ),
            builder: (context) => PostListPage(
              controller: controller,
              displayType: readerMode ? PostDisplayType.comic : null,
              appBar: DefaultAppBar(
                title: Text(getTitle()),
                actions: [
                  CrossFade(
                    showChild:
                        !loadingInfo &&
                        (controller.query['tags']?.trim().isNotEmpty ?? false),
                    child: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: pool != null
                          ? () => showPoolPrompt(context: context, pool: pool!)
                          : () => showTagSearchPrompt(
                              context: context,
                              tag: controller.query['tags'] ?? '',
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
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) => PoolOrderSwitch(
                      oldestFirst: controller.orderPools,
                      onChange: (value) {
                        controller.orderPools = value;
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

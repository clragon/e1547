import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<Client>(
      builder: (context, client, child) => PostsProvider(
        search: widget.tags,
        provider: (tags, page, force) => client.posts(
          page,
          search: tags,
          reversePools: reversePools,
          force: force,
        ),
        child: Consumer2<PostsController, FollowsService>(
          builder: (context, controller, follows, child) {
            Future<void> updateFollow() async {
              Follow? follow = follows.getFollow(controller.search.value);
              if (follow != null) {
                if (controller.itemList?.isNotEmpty ?? false) {
                  Follow updated = follow.withLatest(
                    client.host,
                    controller.itemList!.first,
                    foreground: mounted,
                  );
                  if (updated != follow) {
                    follows.replace(
                      follow,
                      updated,
                    );
                  }
                }
                if (pool != null) {
                  Follow updated = follow.withPool(pool!);
                  if (updated != follow) {
                    follows.replace(
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

            Future<void> updateSearch() async {
              await updatePool();
              await controller.waitForFirstPage();
              await updateFollow();
              if (pool != null) {
                context
                    .read<HistoriesService>()
                    .addPool(pool!, posts: controller.itemList);
              } else {
                context.read<HistoriesService>().addPostSearch(
                    controller.search.value,
                    posts: controller.itemList);
              }
            }

            String getTitle() {
              Follow? follow = follows.getFollow(controller.search.value);
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

            return ListenableListener(
              listener: () => WidgetsBinding.instance
                  .addPostFrameCallback((_) => updateSearch()),
              listenable: controller,
              child: ListenableListener(
                listener: updateFollow,
                listenable: follows,
                child: PostsPage(
                  controller: controller,
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
                                    controller: controller,
                                  ),
                        ),
                      ),
                      const ContextDrawerButton(),
                    ],
                  ),
                  drawerActions: [
                    if (pool != null)
                      Builder(
                        builder: (context) => PoolOrderSwitch(
                          reversePool: reversePools,
                          onChange: (value) {
                            setState(() => reversePools = value);
                            controller.refresh();
                            Scaffold.of(context).closeEndDrawer();
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

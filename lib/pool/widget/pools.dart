import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';

class PoolsPage extends StatefulWidget {
  const PoolsPage({super.key, this.search});

  final QueryMap? search;

  @override
  State<StatefulWidget> createState() => _PoolsPageState();
}

class _PoolsPageState extends State<PoolsPage> with RouterDrawerEntryWidget {
  @override
  Widget build(BuildContext context) {
    return PoolsProvider(
      search: widget.search,
      child: Consumer<PoolController>(
        builder:
            (context, controller, child) => ControllerHistoryConnector(
              controller: controller,
              addToHistory:
                  (context, client, controller) async =>
                      client.histories.addPoolSearch(
                        query: controller.query,
                        pools: controller.items,
                        posts: controller.thumbnails.items,
                      ),
              child: RefreshableDataPage.builder(
                appBar: const DefaultAppBar(
                  title: Text('Pools'),
                  actions: [ContextDrawerButton()],
                ),
                floatingActionButton: PoolsPageFloatingActionButton(
                  controller: controller,
                ),
                drawer: const RouterDrawer(),
                endDrawer: ContextDrawer(
                  title: const Text('Pools'),
                  children: [
                    DrawerDenySwitch(controller: controller.thumbnails),
                    DrawerTagCounter(controller: controller.thumbnails),
                  ],
                ),
                controller: controller,
                builder:
                    (context, child) => AnimatedBuilder(
                      animation: context.watch<Settings>().tileSize,
                      builder: (context, child) {
                        return TileLayout(
                          tileSize: context.watch<Settings>().tileSize.value,
                          child: child!,
                        );
                      },
                      child: child,
                    ),
                child:
                    (context) => PagedMasonryGridView<int, Pool>.count(
                      primary: true,
                      showNewPageProgressIndicatorAsGridChild: false,
                      showNewPageErrorIndicatorAsGridChild: false,
                      showNoMoreItemsIndicatorAsGridChild: false,
                      padding: defaultListPadding,
                      pagingController: controller.paging,
                      crossAxisCount:
                          (TileLayout.of(context).crossAxisCount * 0.5).round(),
                      builderDelegate: defaultPagedChildBuilderDelegate<Pool>(
                        pagingController: controller.paging,
                        itemBuilder:
                            (context, item, index) => ImageCacheSizeProvider(
                              size: TileLayout.of(context).tileSize * 4,
                              child: PoolTile(
                                pool: item,
                                onPressed:
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => PoolPage(pool: item),
                                      ),
                                    ),
                              ),
                            ),
                        onEmpty: const Text('No pools'),
                        onError: const Text('Failed to load pools'),
                      ),
                    ),
              ),
            ),
      ),
    );
  }
}

import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

import 'input.dart';
import 'tile.dart';

class PoolsPage extends StatefulWidget {
  const PoolsPage({this.search});

  final String? search;

  @override
  State<StatefulWidget> createState() => _PoolsPageState();
}

class _PoolsPageState extends State<PoolsPage> with DrawerEntry {
  @override
  Widget build(BuildContext context) {
    return PoolsProvider(
      search: widget.search,
      child: Consumer<PoolsController>(
        builder: (context, controller, child) => ListenableListener(
          initialize: true,
          listenable: controller.search,
          listener: () async {
            HistoriesService service = context.read<HistoriesService>();
            Client client = context.read<Client>();
            await controller.waitForFirstPage();
            await service.addPoolSearch(
              client.host,
              controller.search.value,
              pools: controller.itemList,
            );
          },
          child: RefreshableControllerPage.builder(
            appBar: const DefaultAppBar(
              title: Text('Pools'),
              actions: [ContextDrawerButton()],
            ),
            floatingActionButton: SheetFloatingActionButton(
              actionIcon: Icons.search,
              builder: (context, actionController) => PoolSearchInput(
                controller: controller,
                actionController: actionController,
              ),
            ),
            drawer: const NavigationDrawer(),
            endDrawer: ContextDrawer(
              title: const Text('Pools'),
              children: [
                DrawerDenySwitch(controller: controller.thumbnails),
                DrawerTagCounter(controller: controller.thumbnails),
              ],
            ),
            controller: controller,
            builder: (context, child) => AnimatedBuilder(
              animation: context.watch<Settings>().tileSize,
              builder: (context, child) {
                return TileLayout(
                  tileSize: context.watch<Settings>().tileSize.value,
                  child: child!,
                );
              },
              child: child,
            ),
            child: (context) => PagedMasonryGridView<int, Pool>.count(
              primary: true,
              showNewPageProgressIndicatorAsGridChild: false,
              showNewPageErrorIndicatorAsGridChild: false,
              showNoMoreItemsIndicatorAsGridChild: false,
              padding: defaultListPadding,
              pagingController: controller,
              crossAxisCount:
                  (TileLayout.of(context).crossAxisCount * 0.5).round(),
              builderDelegate: defaultPagedChildBuilderDelegate<Pool>(
                pagingController: controller,
                itemBuilder: (context, item, index) => LowResCacheSizeProvider(
                  size: TileLayout.of(context).tileSize * 4,
                  child: PoolTile(
                    pool: item,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PoolPage(pool: item),
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

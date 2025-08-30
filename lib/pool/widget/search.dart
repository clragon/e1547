import 'package:e1547/pool/pool.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PoolsPage extends StatelessWidget {
  const PoolsPage({super.key, this.search});

  final QueryMap? search;

  @override
  Widget build(BuildContext context) => RouterDrawerEntry<PoolsPage>(
    child: ListenableProvider(
      create: (_) => PoolParams(value: search),
      child: AdaptiveScaffold(
        appBar: const DefaultAppBar(
          title: Text('Pools'),
          actions: [ContextDrawerButton()],
        ),
        floatingActionButton: const PoolsPageFab(),
        drawer: const RouterDrawer(),
        // TODO: these need to be reimplemented completely
        /*
        endDrawer: const ContextDrawer(
          title: Text('Pools'),
          children: [
            DrawerDenySwitch(controller: controller.thumbnails),
            DrawerTagCounter(controller: controller.thumbnails),
          ],
        ),
        */
        body: AnimatedBuilder(
          animation: context.watch<Settings>().tileSize,
          builder: (context, child) => TileLayout(
            tileSize: context.watch<Settings>().tileSize.value,
            child: const PoolList(),
          ),
        ),
      ),
    ),
  );
}

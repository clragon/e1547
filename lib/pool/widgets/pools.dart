import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import 'tile.dart';

class PoolsPage extends StatefulWidget {
  final String? search;

  const PoolsPage({this.search});

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
          listener: () async {
            await controller.waitForFirstPage();
            context.read<HistoriesService>().addPoolSearch(
                controller.search.value,
                pools: controller.itemList);
          },
          listenable: controller.search,
          child: RefreshableControllerPage(
            appBar: const DefaultAppBar(
              title: Text('Pools'),
            ),
            floatingActionButton: SheetFloatingActionButton(
              actionIcon: Icons.search,
              builder: (context, actionController) => ControlledTextField(
                labelText: 'Pool title',
                actionController: actionController,
                textController:
                    TextEditingController(text: controller.search.value),
                submit: (value) => controller.search.value = value,
              ),
            ),
            drawer: const NavigationDrawer(),
            controller: controller,
            builder: (context) => PagedListView(
              padding: defaultListPadding,
              pagingController: controller,
              builderDelegate: defaultPagedChildBuilderDelegate<Pool>(
                pagingController: controller,
                itemBuilder: (context, item, index) => PoolTile(
                  pool: item,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PoolPage(pool: item),
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

import 'package:e1547/history/history.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class HistoriesPage extends StatelessWidget {
  const HistoriesPage({super.key, this.query});

  final QueryMap? query;

  @override
  Widget build(BuildContext context) => RouterDrawerEntry<HistoriesPage>(
    child: ListenableProvider(
      create: (_) => HistoryParams(value: query),
      child: const AdaptiveScaffold(
        appBar: HistoryAppBar(),
        floatingActionButton: HistorySearchFab(),
        drawer: RouterDrawer(),
        endDrawer: ContextDrawer(
          title: Text('History'),
          children: [
            HistoryEnableTile(),
            HistoryLimitTile(),
            Divider(),
            HistoryCategoryFilterTile(),
            HistoryTypeFilterTile(),
          ],
        ),
        body: HistoryList(),
      ),
    ),
  );
}

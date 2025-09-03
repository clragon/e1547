import 'package:e1547/history/history.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/sliver_grouped_list.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) => HistoryPageQueryBuilder(
    builder: (context, state, query) => LimitedWidthLayout.builder(
      builder: (context) => PagedGroupedListView<int, History, DateTime>(
        primary: true,
        padding: defaultActionListPadding.add(
          LimitedWidthLayout.of(context).padding,
        ),
        state: state.paging,
        fetchNextPage: query.getNextPage,
        order: GroupedListOrder.DESC,
        groupBy: (element) => DateUtils.dateOnly(element.visitedAt),
        groupHeaderBuilder: (element) =>
            ListTileHeader(title: DateFormatting.named(element.visitedAt)),
        itemComparator: (a, b) => a.visitedAt.compareTo(b.visitedAt),
        builderDelegate: defaultPagedChildBuilderDelegate<History>(
          onRetry: query.getNextPage,
          onEmpty: const Text('Your history is empty'),
          onError: const Text('Failed to load history'),
          itemBuilder: (context, item, index) => HistoryTile(entry: item),
        ),
      ),
    ),
  );
}

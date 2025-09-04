import 'package:e1547/history/history.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/sliver_grouped_list.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) => LimitedWidthLayout(
    child: HistoryPageQueryBuilder(
      builder: (context, state, query) => PullToRefresh(
        onRefresh: query.invalidate,
        child: CustomScrollView(
          primary: true,
          slivers: [
            SliverPadding(
              padding: defaultActionListPadding,
              sliver: const SliverHistoryList(),
            ),
          ],
        ),
      ),
    ),
  );
}

class SliverHistoryList extends StatelessWidget {
  const SliverHistoryList({super.key});

  @override
  Widget build(BuildContext context) => HistoryPageQueryBuilder(
    builder: (context, state, query) => SliverPadding(
      padding: LimitedWidthLayout.maybeOf(context)?.padding ?? EdgeInsets.zero,
      sliver: PagedSliverGroupedListView<int, History, DateTime>(
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

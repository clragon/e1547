import 'package:e1547/follow/follow.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class FollowList extends StatelessWidget {
  const FollowList({super.key});

  @override
  Widget build(BuildContext context) => TileLayout(
    child: FollowPageQueryBuilder(
      builder: (context, state, query) => PullToRefresh(
        onRefresh: query.invalidate,
        child: CustomScrollView(
          primary: true,
          slivers: [
            SliverPadding(
              padding: defaultActionListPadding,
              sliver: const SliverFollowList(),
            ),
          ],
        ),
      ),
    ),
  );
}

class SliverFollowList extends StatelessWidget {
  const SliverFollowList({super.key});

  @override
  Widget build(BuildContext context) => FollowPageQueryBuilder(
    builder: (context, state, query) => PagedSliverAlignedGrid.count(
      state: state.paging,
      fetchNextPage: query.getNextPage,
      crossAxisCount: TileLayout.of(context).crossAxisCount,
      addAutomaticKeepAlives: false,
      builderDelegate: defaultPagedChildBuilderDelegate<Follow>(
        onRetry: query.getNextPage,
        onEmpty: const Text('No follows found'),
        onError: const Text('Failed to load follows'),
        itemBuilder: (context, item, index) => FollowTile(follow: item),
      ),
    ),
  );
}

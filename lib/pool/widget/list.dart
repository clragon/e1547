import 'package:collection/collection.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PoolList extends StatelessWidget {
  const PoolList({super.key});

  @override
  Widget build(BuildContext context) => PoolPageQueryBuilder(
    builder: (context, state, query) => PullToRefresh(
      onRefresh: query.invalidate,
      child: CustomScrollView(
        primary: true,
        slivers: [
          SliverPadding(
            padding: defaultActionListPadding,
            sliver: const SliverPoolList(),
          ),
        ],
      ),
    ),
  );
}

class SliverPoolList extends StatelessWidget {
  const SliverPoolList({super.key});

  @override
  Widget build(BuildContext context) => PoolPageQueryBuilder(
    builder: (context, state, query) => PostThumbnailQueryLoader(
      postIds:
          state.data?.pages
              .map(
                (page) => page
                    .map((pool) => pool.postIds.firstOrNull)
                    .nonNulls
                    .toList(),
              )
              .toList() ??
          [],
      child: PagedSliverMasonryGrid<int, Pool>.count(
        state: state.paging,
        fetchNextPage: query.getNextPage,
        showNewPageProgressIndicatorAsGridChild: false,
        showNewPageErrorIndicatorAsGridChild: false,
        showNoMoreItemsIndicatorAsGridChild: false,
        crossAxisCount: (TileLayout.of(context).crossAxisCount * 0.5).round(),
        builderDelegate: defaultPagedChildBuilderDelegate(
          onRetry: query.getNextPage,
          itemBuilder: (context, item, index) => ImageCacheSizeProvider(
            size: TileLayout.of(context).tileSize * 4,
            child: PoolTile(
              pool: item,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PoolPage(pool: item)),
              ),
            ),
          ),
          onEmpty: const Text('No pools'),
          onError: const Text('Failed to load pools'),
        ),
      ),
    ),
  );
}

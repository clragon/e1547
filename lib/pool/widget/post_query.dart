import 'package:e1547/domain/domain.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PostPoolPageQueryBuilder extends StatelessWidget {
  const PostPoolPageQueryBuilder({
    super.key,
    required this.poolId,
    required this.builder,
  });

  final int poolId;
  final PageQueryBuilderCallback<Post, int> builder;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();

    return QueryBuilder(
      query: domain.pools.useGet(id: poolId),
      builder: (context, poolState) {
        final postIds = poolState.data?.postIds ?? [];
        final orderByOldest =
            context.watch<PoolPostParams?>()?.orderByOldest ?? true;
        final orderedIds = orderByOldest ? postIds : postIds.reversed.toList();
        final postsQuery = domain.posts.useIdsPage(ids: orderedIds);

        return PagedQueryBuilder(
          query: postsQuery,
          getItem: (id) => domain.posts.useGet(id: id, vendored: true),
          enabled: poolState.data != null,
          builder: (context, state) => QueryFilter(
            state: state,
            builder: (context, state) => builder(context, state, postsQuery),
          ),
        );
      },
    );
  }
}

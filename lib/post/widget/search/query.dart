import 'package:e1547/domain/domain.dart';
import 'package:e1547/favorite/widget/query.dart';
import 'package:e1547/pool/widget/post_query.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PostPageQueryBuilder extends StatelessWidget {
  const PostPageQueryBuilder({super.key, required this.builder});

  final PageQueryBuilderCallback<Post, int> builder;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final controller = context.watch<PostParams>();
    final query = domain.posts.usePage(query: controller.request);

    return PagedQueryBuilder(
      query: query,
      getItem: (id) => domain.posts.useGet(id: id, vendored: true),
      builder: (context, state) => QueryFilter(
        state: state,
        builder: (context, state) => builder(context, state, query),
      ),
    );
  }
}

class PostHotPageQueryBuilder extends StatelessWidget {
  const PostHotPageQueryBuilder({super.key, required this.builder});

  final PageQueryBuilderCallback<Post, int> builder;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final controller = context.watch<PostParams>();
    final query = domain.posts.useHot(query: controller.request);

    return PagedQueryBuilder(
      query: query,
      getItem: (id) => domain.posts.useGet(id: id, vendored: true),
      builder: (context, state) => QueryFilter(
        state: state,
        builder: (context, state) => builder(context, state, query),
      ),
    );
  }
}

class PostAdaptivePageQueryBuilder extends StatelessWidget {
  const PostAdaptivePageQueryBuilder({super.key, required this.builder});

  final PageQueryBuilderCallback<Post, int> builder;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final controller = context.watch<PostParams>();
    final tags = controller.tags ?? '';
    final tagMap = TagMap(tags);
    final single = tagMap.length == 1;

    final favUsername = tagMap['fav'];
    final isFavRedirect =
        single &&
        favUsername != null &&
        favUsername == domain.persona.identity.username;

    final poolId = int.tryParse(tagMap['pool'] ?? '');
    final isPoolRedirect = single && poolId != null;

    if (isFavRedirect) {
      return FavoritesPageQueryBuilder(builder: builder);
    } else if (isPoolRedirect) {
      return PostPoolPageQueryBuilder(poolId: poolId, builder: builder);
    } else {
      return PostPageQueryBuilder(builder: builder);
    }
  }
}

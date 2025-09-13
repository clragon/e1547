import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class FavoritesPageQueryBuilder extends StatelessWidget {
  const FavoritesPageQueryBuilder({super.key, required this.builder});

  final PageQueryBuilderCallback<Post, int> builder;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final query = domain.favorites.usePage();

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

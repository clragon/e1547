import 'package:e1547/domain/domain.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class FollowPageQueryBuilder extends StatelessWidget {
  const FollowPageQueryBuilder({super.key, required this.builder});

  final PageQueryBuilderCallback<Follow, int> builder;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final controller = context.watch<FollowParams>();
    final query = domain.follows.usePage(query: controller.request);

    return PagedQueryBuilder(
      query: query,
      getItem: (id) => domain.follows.useGet(id: id, vendored: true),
      builder: (context, state) => builder(context, state, query),
    );
  }
}

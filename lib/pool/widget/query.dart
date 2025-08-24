import 'package:e1547/domain/domain.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PoolPageQueryBuilder extends StatelessWidget {
  const PoolPageQueryBuilder({super.key, required this.builder});

  final PageQueryBuilderCallback<Pool, int> builder;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final controller = context.watch<PoolFilter>();
    final query = domain.pools.usePage(query: controller.request);

    return PagedQueryBuilder(
      query: query,
      getItem: (id) => domain.pools.useGet(id: id, vendored: true),
      builder: (context, state) => QueryFilter(
        state: state,
        builder: (context, state) => builder(context, state, query),
      ),
    );
  }
}

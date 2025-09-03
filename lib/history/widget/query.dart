import 'package:e1547/domain/domain.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class HistoryPageQueryBuilder extends StatelessWidget {
  const HistoryPageQueryBuilder({super.key, required this.builder});

  final PageQueryBuilderCallback<History, int> builder;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final controller = context.watch<HistoryParams>();
    final query = domain.histories.usePage(query: controller.request);

    return PagedQueryBuilder(
      query: query,
      getItem: (id) => domain.histories.useGet(id: id, vendored: true),
      builder: (context, state) => builder(context, state, query),
    );
  }
}

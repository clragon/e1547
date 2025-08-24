import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicPageQueryBuilder extends StatelessWidget {
  const TopicPageQueryBuilder({super.key, required this.builder});

  final PageQueryBuilderCallback<Topic, int> builder;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final controller = context.watch<TopicFilter>();
    final query = domain.topics.usePage(query: controller.request);

    return PagedQueryBuilder(
      query: query,
      getItem: (id) => domain.topics.useGet(id: id, vendored: true),
      builder: (context, state) => QueryFilter(
        state: state,
        builder: (context, state) => builder(context, state, query),
      ),
    );
  }
}

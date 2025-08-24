import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicsPage extends StatelessWidget {
  const TopicsPage({super.key, this.query});

  final QueryMap? query;

  @override
  Widget build(BuildContext context) => RouterDrawerEntry<TopicsPage>(
    child: FilterControllerProvider(
      create: (_) => TopicFilter(value: query),
      child: const AdaptiveScaffold(
        appBar: DefaultAppBar(
          title: Text('Topics'),
          actions: [ContextDrawerButton()],
        ),
        floatingActionButton: TopicSearchFab(),
        drawer: RouterDrawer(),
        endDrawer: TopicListDrawer(),
        body: TopicList(),
      ),
    ),
  );
}

import 'package:e1547/query/query.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicList extends StatelessWidget {
  const TopicList({super.key});

  @override
  Widget build(BuildContext context) => TopicPageQueryBuilder(
    builder: (context, state, query) => PullToRefresh(
      onRefresh: query.invalidate,
      child: CustomScrollView(
        primary: true,
        slivers: [
          SliverPadding(
            padding: defaultActionListPadding,
            sliver: const SliverTopicList(),
          ),
        ],
      ),
    ),
  );
}

class SliverTopicList extends StatelessWidget {
  const SliverTopicList({super.key});

  @override
  Widget build(BuildContext context) {
    void pushReplies(Topic topic, {bool orderByOldest = true}) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              RepliesPage(topic: topic, orderByOldest: orderByOldest),
        ),
      );
    }

    return TopicPageQueryBuilder(
      builder: (context, state, query) => PagedSliverList<int, Topic>(
        state: state.paging,
        fetchNextPage: query.getNextPage,
        builderDelegate: defaultPagedChildBuilderDelegate(
          onRetry: query.getNextPage,
          itemBuilder: (context, topic, index) => TopicTile(
            topic: topic,
            onPressed: () => pushReplies(topic),
            onCountPressed: () => pushReplies(topic, orderByOldest: false),
          ),
          onEmpty: const Text('No topics'),
          onError: const Text('Failed to load topics'),
        ),
      ),
    );
  }
}

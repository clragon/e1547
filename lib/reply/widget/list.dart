import 'package:e1547/query/query.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class ReplyList extends StatelessWidget {
  const ReplyList({super.key});

  @override
  Widget build(BuildContext context) => ReplyPageQueryBuilder(
    builder: (context, state, query) => PullToRefresh(
      onRefresh: query.invalidate,
      child: CustomScrollView(
        primary: true,
        slivers: [
          SliverPadding(
            padding: defaultActionListPadding,
            sliver: const SliverReplyList(),
          ),
        ],
      ),
    ),
  );
}

class SliverReplyList extends StatelessWidget {
  const SliverReplyList({super.key});

  @override
  Widget build(BuildContext context) => ReplyPageQueryBuilder(
    builder: (context, state, query) => PagedSliverList<int, Reply>(
      state: state.paging,
      fetchNextPage: query.getNextPage,
      builderDelegate: defaultPagedChildBuilderDelegate(
        onRetry: query.getNextPage,
        itemBuilder: (context, item, index) => ReplyTile(reply: item),
        onEmpty: const IconMessage(
          icon: Icon(Icons.clear),
          title: Text('No replies'),
        ),
        onError: const IconMessage(
          icon: Icon(Icons.warning_amber_outlined),
          title: Text('Failed to load replies'),
        ),
      ),
    ),
  );
}

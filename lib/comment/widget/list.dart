import 'package:e1547/comment/comment.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class CommentList extends StatelessWidget {
  const CommentList({super.key});

  @override
  Widget build(BuildContext context) => CommentPageQueryBuilder(
    builder: (context, state, query) => PullToRefresh(
      onRefresh: query.invalidate,
      child: CustomScrollView(
        primary: true,
        slivers: [
          SliverPadding(
            padding: defaultActionListPadding,
            sliver: const SliverCommentList(),
          ),
        ],
      ),
    ),
  );
}

class SliverCommentList extends StatelessWidget {
  const SliverCommentList({super.key});

  @override
  Widget build(BuildContext context) => CommentPageQueryBuilder(
    builder: (context, state, query) => PagedSliverList<int, Comment>(
      state: state.paging,
      fetchNextPage: query.getNextPage,
      builderDelegate: defaultPagedChildBuilderDelegate(
        itemBuilder: (context, item, index) => CommentTile(comment: item),
        onEmpty: const Text('No comments'),
        onError: const Text('Failed to load comments'),
      ),
    ),
  );
}

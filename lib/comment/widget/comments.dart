import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PostCommentsPage extends StatefulWidget {
  const PostCommentsPage({super.key, required this.postId});

  final int postId;

  @override
  State<PostCommentsPage> createState() => _PostCommentsPageState();
}

class _PostCommentsPageState extends State<PostCommentsPage> {
  bool orderByOldest = true;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final query = domain.comments.useByPost(
      postId: widget.postId,
      ascending: orderByOldest,
    );

    return QueryBuilder(
      query: query,
      builder: (context, state) => AdaptiveScaffold(
        appBar: DefaultAppBar(
          title: Text('#${widget.postId} comments'),
          actions: const [ContextDrawerButton()],
        ),
        floatingActionButton: domain.hasLogin
            ? FloatingActionButton(
                heroTag: 'float',
                backgroundColor: Theme.of(context).cardColor,
                child: Icon(
                  Icons.comment,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () =>
                    writeComment(context: context, postId: widget.postId),
              )
            : null,
        endDrawer: ContextDrawer(
          title: const Text('Comments'),
          children: [
            Builder(
              builder: (context) => SwitchListTile(
                secondary: const Icon(Icons.sort),
                title: const Text('Comment order'),
                subtitle: Text(orderByOldest ? 'oldest first' : 'newest first'),
                value: orderByOldest,
                onChanged: (value) {
                  setState(() => orderByOldest = value);
                  Scaffold.of(context).closeEndDrawer();
                },
              ),
            ),
          ],
        ),
        body: PullToRefresh(
          onRefresh: query.invalidate,
          child: PagedListView<int, int>(
            primary: true,
            padding: defaultActionListPadding,
            state: state.paging,
            fetchNextPage: query.getNextPage,
            builderDelegate: defaultPagedChildBuilderDelegate(
              onRetry: query.getNextPage,
              itemBuilder: (context, commentId, index) => QueryBuilder(
                query: domain.comments.useGet(id: commentId, vendored: true),
                builder: (context, commentState) =>
                    CommentTile(comment: commentState.data!),
              ),
              onEmpty: const Text('No comments'),
              onError: const Text('Failed to load comments'),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class CommentDisplay extends StatelessWidget {
  const CommentDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    if (post.commentCount <= 0) return const SizedBox();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PostCommentsPage(postId: post.id),
                  ),
                ),
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  overlayColor: WidgetStateProperty.all(
                    Theme.of(context).splashColor,
                  ),
                ),
                child: Text(
                  'COMMENTS'
                  ' (${post.commentCount})',
                ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}

class SliverPostCommentSection extends StatefulWidget {
  const SliverPostCommentSection({super.key, required this.post});

  final Post post;

  @override
  State<SliverPostCommentSection> createState() =>
      _SliverPostCommentSectionState();
}

class _SliverPostCommentSectionState extends State<SliverPostCommentSection> {
  bool orderByOldest = true;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final query = domain.comments.useByPost(
      postId: widget.post.id,
      ascending: orderByOldest,
    );

    return QueryBuilder(
      query: query,
      builder: (context, state) => SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Comments',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        PopupMenuButton<VoidCallback>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) => value(),
                          itemBuilder: (context) => [
                            PopupMenuTile(
                              title: 'Refresh',
                              icon: Icons.refresh,
                              value: () => query.invalidate(),
                            ),
                            PopupMenuTile(
                              icon: Icons.sort,
                              title: orderByOldest
                                  ? 'Newest first'
                                  : 'Oldest first',
                              value: () => setState(
                                () => orderByOldest = !orderByOldest,
                              ),
                            ),
                            PopupMenuTile(
                              title: 'Comment',
                              icon: Icons.comment,
                              value: () => guardWithLogin(
                                context: context,
                                callback: () async {
                                  bool success = await writeComment(
                                    context: context,
                                    postId: widget.post.id,
                                  );
                                  if (success) {
                                    // TODO: Invalidate post cache to update comment count
                                    query.invalidate();
                                  }
                                },
                                error: 'You must be logged in to comment!',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ).add(const EdgeInsets.only(bottom: 30)),
            sliver: PagedSliverList(
              state: state.paging,
              fetchNextPage: query.getNextPage,
              builderDelegate: defaultPagedChildBuilderDelegate<int>(
                itemBuilder: (context, id, index) => QueryBuilder(
                  query: domain.comments.useGet(id: id, vendored: true),
                  builder: (context, commentState) =>
                      CommentTile(comment: commentState.data!),
                ),
                onEmpty: const Text('No comments'),
                onError: const Text('Failed to load comments'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

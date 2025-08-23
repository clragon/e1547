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

class SliverPostCommentSection extends StatelessWidget {
  const SliverPostCommentSection({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return FilterControllerProvider(
      create: (_) => CommentFilter(
        domain: domain,
        value: {
          CommentFilter.postIdFilter.tag: postId,
          CommentFilter.groupByFilter.tag: CommentGroupBy.comment,
          CommentFilter.orderFilter.tag: CommentOrder.id_asc,
        }.toQuery(),
      ),
      keys: (_) => [domain],
      builder: (context, _) => SliverMainAxisGroup(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Comments',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        CommentListDropdown(),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ).add(const EdgeInsets.only(bottom: 30)),
            sliver: const SliverCommentList(),
          ),
        ],
      ),
    );
  }
}

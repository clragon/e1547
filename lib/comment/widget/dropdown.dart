import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class CommentListDropdown extends StatelessWidget {
  const CommentListDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final controller = context.watch<CommentFilter>();
    final query = domain.comments.usePage(query: controller.request);
    final postId = controller.postId;

    return PopupMenuButton<VoidCallback>(
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
          title: controller.order == CommentOrder.id_asc
              ? 'Newest first'
              : 'Oldest first',
          value: () =>
              controller.order = controller.order == CommentOrder.id_asc
              ? CommentOrder.id_desc
              : CommentOrder.id_asc,
        ),
        if (postId != null)
          PopupMenuTile(
            title: 'Comment',
            icon: Icons.comment,
            value: () => guardWithLogin(
              context: context,
              callback: () async {
                bool success = await writeComment(
                  context: context,
                  postId: postId,
                );
                if (success) {
                  query.invalidate();
                  // TODO: invalidate post cache to refresh comment count
                  // domain.posts.useGet(id: postId).invalidate();
                }
              },
              error: 'You must be logged in to comment!',
            ),
          ),
      ],
    );
  }
}

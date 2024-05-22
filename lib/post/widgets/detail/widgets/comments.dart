import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:username_generator/username_generator.dart';

class CommentDisplay extends StatelessWidget {
  const CommentDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    if (!context.watch<Client>().hasFeature(ClientFeature.comments)) {
      return const SizedBox();
    }
    return CrossFade(
      showChild: post.hasComments ?? false,
      child: Column(
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
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).textTheme.bodyMedium!.color),
                    overlayColor: MaterialStateProperty.all(
                        Theme.of(context).splashColor),
                  ),
                  child: Text(
                    'COMMENTS'
                    '${post.commentCount != null ? ' (${post.commentCount})' : ''}',
                  ),
                ),
              )
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class SliverPostCommentSection extends StatelessWidget {
  const SliverPostCommentSection({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    if (!context.watch<Client>().hasFeature(ClientFeature.comments)) {
      return const SliverToBoxAdapter();
    }
    return CommentProvider(
      postId: post.id,
      child: Consumer<CommentController>(
        builder: (context, controller, child) => Provider<UsernameGenerator>(
          create: (context) => UsernameGenerator(),
          child: SliverMainAxisGroup(
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
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            PopupMenuButton<VoidCallback>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) => value(),
                              itemBuilder: (context) => [
                                PopupMenuTile(
                                  title: 'Refresh',
                                  icon: Icons.refresh,
                                  value: () => controller.refresh(force: true),
                                ),
                                PopupMenuTile(
                                  icon: Icons.sort,
                                  title: controller.orderByOldest
                                      ? 'Newest first'
                                      : 'Oldest first',
                                  value: () => controller.orderByOldest =
                                      !controller.orderByOldest,
                                ),
                                PopupMenuTile(
                                  title: 'Comment',
                                  icon: Icons.comment,
                                  value: () => guardWithLogin(
                                    context: context,
                                    callback: () async {
                                      PostController postsController =
                                          context.read<PostController>();
                                      bool success = await writeComment(
                                          context: context, postId: post.id);
                                      if (success) {
                                        postsController.replacePost(
                                          post.copyWith(
                                            commentCount:
                                                post.commentCount != null
                                                    ? post.commentCount! + 1
                                                    : null,
                                            hasComments:
                                                post.hasComments != null
                                                    ? true
                                                    : null,
                                          ),
                                        );
                                        controller.refresh(force: true);
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
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12)
                    .add(const EdgeInsets.only(bottom: 30)),
                sliver: PagedSliverList<int, Comment>(
                  pagingController: controller.paging,
                  builderDelegate: defaultPagedChildBuilderDelegate(
                    pagingController: controller.paging,
                    itemBuilder: (context, item, index) =>
                        CommentTile(comment: item),
                    onEmpty: const Text('No comments'),
                    onError: const Text('Failed to load comments'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class CommentDisplay extends StatelessWidget {
  const CommentDisplay({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      showChild: post.commentCount > 0,
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
                  child: Text('COMMENTS (${post.commentCount})'),
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

class PostDetailCommentsWrapper extends StatelessWidget {
  const PostDetailCommentsWrapper({
    super.key,
    required this.post,
    required this.children,
  });

  final Post post;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CommentsProvider(
      postId: post.id,
      child: Consumer<CommentsController>(
        builder: (context, controller, child) => CustomScrollView(
          primary: true,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.top),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: children,
              ),
            ),
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
                                title: controller.orderByOldest.value
                                    ? 'Newest first'
                                    : 'Oldest first',
                                value: () => controller.orderByOldest.value =
                                    !controller.orderByOldest.value,
                              ),
                              PopupMenuTile(
                                title: 'Comment',
                                icon: Icons.comment,
                                value: () => guardWithLogin(
                                  context: context,
                                  callback: () async {
                                    PostsController postsController =
                                        context.read<PostsController>();
                                    bool success = await writeComment(
                                        context: context, postId: post.id);
                                    if (success) {
                                      postsController.replacePost(
                                        post.copyWith(
                                          commentCount: post.commentCount + 1,
                                        ),
                                      );
                                      controller.refresh();
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
              sliver: PagedSliverList<String, Comment>(
                pagingController: controller,
                builderDelegate: defaultPagedChildBuilderDelegate(
                  pagingController: controller,
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
    );
  }
}

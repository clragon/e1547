import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'appbar.dart';

class PostDetail extends StatefulWidget {
  const PostDetail({required this.controller, this.onTapImage});

  final PostController controller;
  final VoidCallback? onTapImage;

  @override
  State<StatefulWidget> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  Post get post => widget.controller.value;

  set post(Post value) => widget.controller.value = value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    preloadPostImage(
      context: context,
      post: post,
      size: PostImageSize.file,
    );
  }

  Widget image(BuildContext context, BoxConstraints constraints) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight / 2),
            maxHeight: constraints.maxWidth > constraints.maxHeight
                ? constraints.maxHeight * 0.8
                : double.infinity,
          ),
          child: AnimatedSize(
            duration: defaultAnimationDuration,
            child: PostDetailImageDisplay(
              post: widget.controller,
              onTap: () {
                PostVideoRoute.of(context).keepPlaying();
                if (!(context.read<PostEditingController>().editing) &&
                    widget.onTapImage != null) {
                  widget.onTapImage!();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          PostFullscreen(controller: widget.controller),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );

  Widget singleBody(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            ArtistDisplay(post: post),
            DescriptionDisplay(post: post),
            PostEditorChild(
              shown: false,
              child: LikeDisplay(controller: widget.controller),
            ),
            PostEditorChild(
              shown: false,
              child: CommentDisplay(post: post),
            ),
            RelationshipDisplay(post: post),
            PostEditorChild(
              shown: false,
              child: PoolDisplay(post: post),
            ),
            PostEditorChild(
              shown: false,
              child: DenylistTagDisplay(controller: widget.controller),
            ),
            TagDisplay(post: widget.controller.value),
            PostEditorChild(
              shown: false,
              child: FileDisplay(
                post: post,
              ),
            ),
            PostEditorChild(
              shown: true,
              child: RatingDisplay(
                post: post,
              ),
            ),
            SourceDisplay(post: post),
          ],
        ),
      );

  Widget sideBarBody(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            RelationshipDisplay(post: post),
            PostEditorChild(
              shown: false,
              child: PoolDisplay(post: post),
            ),
            PostEditorChild(
              shown: false,
              child: DenylistTagDisplay(controller: widget.controller),
            ),
            TagDisplay(post: widget.controller.value),
            PostEditorChild(
              shown: false,
              child: FileDisplay(
                post: post,
              ),
            ),
            PostEditorChild(
              shown: true,
              child: RatingDisplay(
                post: post,
              ),
            ),
            SourceDisplay(post: post),
          ],
        ),
      );

  Widget secondaryBody(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArtistDisplay(post: post),
            DescriptionDisplay(post: post),
            LikeDisplay(controller: widget.controller),
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
                        value: () => context
                            .read<CommentsController>()
                            .refresh(force: true),
                      ),
                      PopupMenuTile(
                        icon: Icons.sort,
                        title: context
                                .read<CommentsController>()
                                .orderByOldest
                                .value
                            ? 'Newest first'
                            : 'Oldest first',
                        value: () {
                          CommentsController controller =
                              context.read<CommentsController>();
                          controller.orderByOldest.value =
                              !controller.orderByOldest.value;
                        },
                      ),
                      PopupMenuTile(
                        title: 'Comment',
                        icon: Icons.comment,
                        value: () => guardWithLogin(
                          context: context,
                          callback: () async {
                            if (await writeComment(
                                context: context, postId: post.id)) {
                              post = post.copyWith(
                                  commentCount: post.commentCount + 1);
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
            )
          ],
        ),
      );

  Widget commentWrapper(BuildContext context, List<Widget> children) =>
      CommentsProvider(
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
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12)
                    .add(const EdgeInsets.only(bottom: 30)),
                sliver: PagedSliverList<String, Comment>(
                  pagingController: controller,
                  builderDelegate: defaultPagedChildBuilderDelegate(
                    pagingController: controller,
                    itemBuilder: (context, item, index) => CommentProvider(
                      id: item.id,
                      child: Consumer<CommentController>(
                        builder: (context, controller, child) =>
                            CommentTile(comment: controller),
                      ),
                    ),
                    onEmpty: const Text('No comments'),
                    onError: const Text('Failed to load comments'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) => PostVideoRoute(
        post: post,
        child: PostHistoryConnector(
          post: post,
          child: PostEditor(
            post: post,
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: PostDetailAppBar(controller: widget.controller),
              floatingActionButton: context.read<Client>().hasLogin
                  ? PostDetailFloatingActionButton(
                      controller: widget.controller)
                  : null,
              body: MediaQuery.removeViewInsets(
                context: context,
                removeTop: true,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 1000) {
                      return ListView(
                        primary: true,
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top,
                          bottom: kBottomNavigationBarHeight + 24,
                        ),
                        children: [
                          image(context, constraints),
                          singleBody(context),
                        ],
                      );
                    } else {
                      double sideBarWidth;
                      if (constraints.maxWidth > 1400) {
                        sideBarWidth = 404;
                      } else {
                        sideBarWidth = 304;
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: commentWrapper(
                              context,
                              [
                                image(context, constraints),
                                secondaryBody(context),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: sideBarWidth,
                            child: ListView(
                              primary: false,
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top,
                                bottom: defaultActionListPadding.bottom,
                              ),
                              children: [
                                const SizedBox(
                                  height: 56,
                                ),
                                sideBarBody(context),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

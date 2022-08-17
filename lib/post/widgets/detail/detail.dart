import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import 'appbar.dart';

class PostDetail extends StatefulWidget {
  final PostController post;
  final VoidCallback? onTapImage;

  const PostDetail({required this.post, this.onTapImage});

  @override
  State<StatefulWidget> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> with RouteAware {
  late PostEditingController editingController =
      PostEditingController(widget.post.value);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HistoriesService>().addPost(widget.post.value);
        preloadPostImage(
          context: context,
          post: widget.post.value,
          size: PostImageSize.file,
        );
      }
    });
  }

  Future<void> editPost(
      BuildContext context, PostEditingController controller) async {
    controller.setLoading(true);
    Map<String, String?>? body = controller.compile();
    if (body != null) {
      try {
        await context.read<Client>().updatePost(controller.post.id, body);
        widget.post.value =
            widget.post.value.copyWith(tags: controller.value!.tags);
        await widget.post.reset();
        controller.stopEditing();
      } on DioError {
        controller.setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 1),
            content: Text('failed to edit Post #${widget.post.id}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        throw ActionControllerException(
            message: 'failed to edit Post #${widget.post.id}');
      }
    }
  }

  Future<void> submitEdit(BuildContext context) async {
    editingController.show(
      context,
      ControlledTextField(
        actionController: editingController,
        labelText: 'Reason',
        submit: (value) async {
          editingController.value =
              editingController.value!.copyWith(editReason: value);
          return editPost(context, editingController);
        },
      ),
    );
  }

  Widget fab() {
    return AnimatedBuilder(
      animation: Listenable.merge([editingController]),
      builder: (context, child) => FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).iconTheme.color,
        onPressed: editingController.editing
            ? editingController.action ?? () => submitEdit(context)
            : () {},
        child: editingController.editing
            ? Icon(editingController.isShown ? Icons.add : Icons.check)
            : Padding(
                padding: const EdgeInsets.only(left: 2),
                child: FavoriteButton(post: widget.post),
              ),
      ),
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
              post: widget.post,
              onTap: () {
                PostVideoRoute.of(context).keepPlaying();
                if (!(editingController.editing) && widget.onTapImage != null) {
                  widget.onTapImage!();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostFullscreen(post: widget.post),
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
            ArtistDisplay(post: widget.post),
            DescriptionDisplay(post: widget.post.value),
            PostEditorChild(
              shown: false,
              child: LikeDisplay(post: widget.post),
            ),
            PostEditorChild(
              shown: false,
              child: CommentDisplay(post: widget.post),
            ),
            ParentDisplay(post: widget.post.value),
            PostEditorChild(
              shown: false,
              child: PoolDisplay(post: widget.post.value),
            ),
            PostEditorChild(
              shown: false,
              child: DenylistTagDisplay(post: widget.post),
            ),
            TagDisplay(post: widget.post),
            PostEditorChild(
              shown: false,
              child: FileDisplay(
                post: widget.post,
              ),
            ),
            PostEditorChild(
              shown: true,
              child: RatingDisplay(
                post: widget.post.value,
              ),
            ),
            SourceDisplay(post: widget.post.value),
          ],
        ),
      );

  Widget sideBarBody(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            ParentDisplay(post: widget.post.value),
            PostEditorChild(
              shown: false,
              child: PoolDisplay(post: widget.post.value),
            ),
            PostEditorChild(
              shown: false,
              child: DenylistTagDisplay(post: widget.post),
            ),
            TagDisplay(post: widget.post),
            PostEditorChild(
              shown: false,
              child: FileDisplay(
                post: widget.post,
              ),
            ),
            PostEditorChild(
              shown: true,
              child: RatingDisplay(
                post: widget.post.value,
              ),
            ),
            SourceDisplay(post: widget.post.value),
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
            ArtistDisplay(post: widget.post),
            DescriptionDisplay(post: widget.post.value),
            LikeDisplay(post: widget.post),
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
                        title: 'Comment',
                        icon: Icons.comment,
                        value: () => guardWithLogin(
                          context: context,
                          callback: () async {
                            if (await writeComment(
                                context: context,
                                postId: widget.post.value.id)) {
                              widget.post.value = widget.post.value.copyWith(
                                  commentCount:
                                      widget.post.value.commentCount + 1);
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
        postId: widget.post.value.id,
        child: Consumer<CommentsController>(
          builder: (context, controller, child) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: children,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
    return PostVideoRoute(
      post: widget.post.value,
      child: AnimatedBuilder(
        animation: widget.post,
        builder: (context, child) => PostEditor(
          editingController: editingController,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PostDetailAppBar(post: widget.post),
            floatingActionButton:
                context.read<Client>().hasLogin ? fab() : null,
            body: MediaQuery.removeViewInsets(
              context: context,
              removeTop: true,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 1000) {
                    return ListView(
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
                            children: [
                              const SizedBox(
                                height: 56,
                              ),
                              sideBarBody(context),
                              SizedBox(
                                height: defaultActionListPadding.bottom,
                              ),
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
    );
  }
}

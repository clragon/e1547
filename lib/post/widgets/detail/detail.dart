import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
  bool keepPlaying = false;

  late VideoPlayerController? videoController;
  late NavigationController navigation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => HistoriesData.of(context).addPost(widget.post.value),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigation = NavigationData.of(context);
    navigation.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    videoController = widget.post.value.getVideo(context);
  }

  @override
  void reassemble() {
    super.reassemble();
    navigation.routeObserver.unsubscribe(this);
    navigation.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    if (widget.post.value.type == PostType.image &&
        widget.post.value.file.url != null) {
      preloadImage(
        context: context,
        post: widget.post.value,
        size: ImageSize.file,
      );
    }
  }

  @override
  void dispose() {
    navigation.routeObserver.unsubscribe(this);
    videoController?.pause();
    editingController.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    super.didPushNext();
    if (keepPlaying) {
      keepPlaying = false;
    } else {
      videoController?.pause();
    }
  }

  Future<void> editPost(
      BuildContext context, PostEditingController controller) async {
    controller.setLoading(true);
    Map<String, String?>? body = controller.compile();
    if (body != null) {
      try {
        await client.updatePost(controller.post.id, body);
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.post,
      builder: (context, child) => PostEditor(
        editingController: editingController,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PostDetailAppBar(post: widget.post),
          floatingActionButton: client.hasLogin ? fab() : null,
          body: MediaQuery.removeViewInsets(
            context: context,
            removeTop: true,
            child: LayoutBuilder(
              builder: (context, constraints) => ListView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: kBottomNavigationBarHeight + 24,
                ),
                children: [
                  Padding(
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
                            keepPlaying = true;
                            if (!(editingController.editing) &&
                                widget.onTapImage != null) {
                              widget.onTapImage!();
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PostFullscreen(post: widget.post),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

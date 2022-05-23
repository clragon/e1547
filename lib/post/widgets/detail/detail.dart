import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'appbar.dart';

class PostDetail extends StatefulWidget {
  final Post post;
  final PostController? controller;
  final void Function(int index)? onPageChanged;

  const PostDetail({required this.post, this.controller, this.onPageChanged});

  @override
  State<StatefulWidget> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail>
    with ListenerCallbackMixin, RouteAware {
  late PostEditingController? editingController =
      widget.controller != null ? PostEditingController(widget.post) : null;
  bool keepPlaying = false;

  late VideoPlayerController? videoController;
  late NavigationController navigation;
  late NavigatorState navigator;
  late ModalRoute route;

  @override
  Map<Listenable, VoidCallback> get listeners => {
        if (widget.controller != null) widget.controller!: onPageChange,
      };

  Future<void> onPageChange() async {
    if (!(widget.controller!.itemList?.any((e) => e.id == widget.post.id) ??
        false)) {
      if (route.isCurrent) {
        navigator.pop();
      } else if (route.isActive) {
        navigator.removeRoute(route);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => historyController.addPost(widget.post),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigator = Navigator.of(context);
    route = ModalRoute.of(context)!;
    navigation = NavigationData.of(context);
    navigation.routeObserver.subscribe(this, route as PageRoute);
    videoController = widget.post.getVideo(context);
  }

  @override
  void reassemble() {
    super.reassemble();
    navigation.routeObserver.unsubscribe(this);
    navigation.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    if (widget.post.type == PostType.image && widget.post.file.url != null) {
      preloadImage(context: context, post: widget.post, size: ImageSize.file);
    }
  }

  @override
  void dispose() {
    navigation.routeObserver.unsubscribe(this);
    videoController?.pause();
    editingController?.dispose();
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
        widget.controller!.updateItem(
          widget.controller!.itemList!.indexOf(widget.post),
          widget.post.copyWith.tags(controller.value!.tags),
        );
        await widget.controller!.resetPost(controller.post);
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
    editingController!.show(
      context,
      ControlledTextField(
        actionController: editingController!,
        labelText: 'Reason',
        submit: (value) async {
          editingController!.value =
              editingController!.value!.copyWith(editReason: value);
          return editPost(context, editingController!);
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
        onPressed: editingController?.editing ?? false
            ? editingController!.action ?? () => submitEdit(context)
            : () {},
        child: editingController?.editing ?? false
            ? Icon(editingController!.isShown ? Icons.add : Icons.check)
            : Padding(
                padding: const EdgeInsets.only(left: 2),
                child: FavoriteButton(
                  post: widget.post,
                  controller: widget.controller!,
                ),
              ),
      ),
    );
  }

  Widget fullscreen() {
    if (widget.controller == null || (editingController?.editing ?? false)) {
      return PostFullscreenFrame(
        post: widget.post,
        child: PostFullscreen(
          post: widget.post,
          controller: widget.controller,
        ),
      );
    } else {
      return PostFullscreenGallery(
        controller: widget.controller!,
        initialPage: widget.controller!.itemList!.indexOf(widget.post),
        onPageChanged: widget.onPageChanged,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PostEditor(
        editingController: editingController,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PostDetailAppBar(
            post: widget.post,
            controller: widget.controller,
          ),
          floatingActionButton:
              client.hasLogin && widget.controller != null ? fab() : null,
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
                          controller: widget.controller,
                          onTap: () {
                            keepPlaying = true;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => fullscreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        ArtistDisplay(
                          post: widget.post,
                          controller: widget.controller,
                        ),
                        DescriptionDisplay(post: widget.post),
                        PostEditorChild(
                          shown: false,
                          child: LikeDisplay(
                            post: widget.post,
                            controller: widget.controller,
                          ),
                        ),
                        PostEditorChild(
                          shown: false,
                          child: CommentDisplay(
                            post: widget.post,
                            controller: widget.controller,
                          ),
                        ),
                        ParentDisplay(post: widget.post),
                        PostEditorChild(
                          shown: false,
                          child: PoolDisplay(post: widget.post),
                        ),
                        TagDisplay(
                          post: widget.post,
                          controller: widget.controller,
                        ),
                        PostEditorChild(
                          shown: false,
                          child: FileDisplay(
                            post: widget.post,
                            controller: widget.controller,
                          ),
                        ),
                        PostEditorChild(
                          shown: true,
                          child: RatingDisplay(
                            post: widget.post,
                          ),
                        ),
                        SourceDisplay(post: widget.post),
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

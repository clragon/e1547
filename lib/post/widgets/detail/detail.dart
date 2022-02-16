import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

import 'appbar.dart';

class PostDetail extends StatefulWidget {
  final Post post;
  final PostController? controller;
  final void Function(int index)? onPageChanged;

  const PostDetail({required this.post, this.controller, this.onPageChanged});

  @override
  State<StatefulWidget> createState() {
    return _PostDetailState();
  }
}

class _PostDetailState extends State<PostDetail>
    with ListenerCallbackMixin, RouteAware {
  late PostEditingController editingController =
      PostEditingController(widget.post);
  SheetActionController sheetController = SheetActionController();
  bool keepPlaying = false;

  late NavigatorState navigator;
  late ModalRoute route;

  @override
  Map<ChangeNotifier, VoidCallback> get listeners => {
        editingController: closeSheet,
        if (widget.controller != null) widget.controller!: onPageChange,
      };

  Future<void> onPageChange() async {
    if (!(widget.controller!.itemList?.contains(widget.post) ?? false)) {
      if (route.isCurrent) {
        navigator.pop();
      } else if (route.isActive) {
        navigator.removeRoute(route);
      }
    }
  }

  void closeSheet() {
    if (!editingController.isEditing) {
      sheetController.close();
    }
  }

  @override
  void initState() {
    super.initState();
    addPostToHistory(widget.post);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigator = Navigator.of(context);
    route = ModalRoute.of(context)!;
    navigationController.routeObserver.subscribe(this, route as PageRoute);
  }

  @override
  void reassemble() {
    super.reassemble();
    navigationController.routeObserver.unsubscribe(this);
    navigationController.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    if (widget.post.type == PostType.image && widget.post.file.url != null) {
      preloadImage(context: context, post: widget.post, size: ImageSize.file);
    }
  }

  @override
  void dispose() {
    navigationController.routeObserver.unsubscribe(this);
    widget.post.controller?.pause();
    if (widget.controller == null) {
      widget.post.dispose();
    }
    super.dispose();
  }

  @override
  void didPushNext() {
    super.didPushNext();
    if (keepPlaying) {
      keepPlaying = false;
    } else {
      widget.post.controller?.pause();
    }
  }

  Future<void> editPost(
      BuildContext context, PostEditingController controller) async {
    controller.isLoading = true;
    Map<String, String?>? body = controller.compile();
    if (body != null) {
      try {
        await client.updatePost(controller.post.id, body);
        await widget.post.resetPost(online: true);
        controller.isEditing = false;
      } on DioError {
        controller.isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
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
    sheetController.show(
      context,
      ControlledTextField(
        labelText: 'Reason',
        submit: (value) async => editPost(context, editingController),
        actionController: sheetController,
      ),
    );
  }

  Widget fab(BuildContext context) {
    return AnimatedBuilder(
      animation: sheetController,
      builder: (context, child) => FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).iconTheme.color,
        onPressed: editingController.isEditing
            ? sheetController.action ?? () => submitEdit(context)
            : () {},
        child: editingController.isEditing
            ? Icon(sheetController.isShown ? Icons.add : Icons.check)
            : Padding(
                padding: EdgeInsets.only(left: 2),
                child: FavoriteButton(post: widget.post),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget fullscreen() {
      if (editingController.isEditing || widget.controller == null) {
        return PostFullscreenFrame(
          child: PostFullscreenImageDisplay(post: widget.post),
          post: widget.post,
        );
      } else {
        return PostFullscreenGallery(
          controller: widget.controller!,
          initialPage: widget.controller!.itemList!.indexOf(widget.post),
          onPageChanged: widget.onPageChanged,
        );
      }
    }

    Widget editorDependant({required Widget child, required bool shown}) =>
        CrossFade(
          showChild: shown == editingController.isEditing,
          child: child,
        );

    Widget editorScope({required Widget child}) {
      return WillPopScope(
        onWillPop: () async {
          if (sheetController.isShown) {
            return true;
          }
          if (editingController.isEditing) {
            editingController.isEditing = false;
            return false;
          }
          return true;
        },
        child: child,
      );
    }

    return Scaffold(
      body: AnimatedSelector(
        animation: editingController,
        selector: () => [editingController.isEditing],
        builder: (context, child) {
          return editorScope(
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: PostDetailAppBar(
                post: widget.post,
                editingController: editingController,
              ),
              floatingActionButton:
                  client.hasLogin ? Builder(builder: fab) : null,
              body: MediaQuery.removeViewInsets(
                context: context,
                removeTop: true,
                child: LayoutBuilder(
                  builder: (context, constraints) => ListView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      bottom: kBottomNavigationBarHeight + 24,
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: (constraints.maxHeight / 2),
                            maxHeight:
                                constraints.maxWidth > constraints.maxHeight
                                    ? constraints.maxHeight * 0.8
                                    : double.infinity,
                          ),
                          child: AnimatedSize(
                            duration: defaultAnimationDuration,
                            child: PostDetailImageDisplay(
                              post: widget.post,
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
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            ArtistDisplay(
                              post: widget.post,
                              controller: widget.controller,
                              editingController: editingController,
                            ),
                            DescriptionDisplay(
                              post: widget.post,
                              editingController: editingController,
                            ),
                            editorDependant(
                                child: LikeDisplay(post: widget.post),
                                shown: false),
                            editorDependant(
                                child: CommentDisplay(post: widget.post),
                                shown: false),
                            Builder(
                              builder: (context) => ParentDisplay(
                                post: widget.post,
                                actionController: sheetController,
                                editingController: editingController,
                              ),
                            ),
                            editorDependant(
                                child: PoolDisplay(post: widget.post),
                                shown: false),
                            Builder(
                              builder: (context) => TagDisplay(
                                post: widget.post,
                                controller: widget.controller,
                                actionController: sheetController,
                                editingController: editingController,
                              ),
                            ),
                            editorDependant(
                                child: FileDisplay(
                                  post: widget.post,
                                  controller: widget.controller,
                                ),
                                shown: false),
                            editorDependant(
                                child: RatingDisplay(
                                  post: widget.post,
                                  editingController: editingController,
                                ),
                                shown: true),
                            SourceDisplay(
                              post: widget.post,
                              editingController: editingController,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

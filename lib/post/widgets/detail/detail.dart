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
  SheetActionController sheetController = SheetActionController();
  bool keepPlaying = false;

  late NavigatorState navigator;
  late ModalRoute route;

  @override
  Map<ChangeNotifier, VoidCallback> get listeners => {
        widget.post: closeSheet,
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
    if (!widget.post.isEditing) {
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
    navigationController.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    navigator = Navigator.of(context);
    route = ModalRoute.of(context)!;
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
    if (widget.post.isEditing) {
      widget.post.resetPost();
    }
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

  Future<void> editPost(BuildContext context, String reason) async {
    widget.post.isEditing = false;
    try {
      await client.updatePost(widget.post, Post.fromMap(widget.post.raw),
          editReason: reason);
      await widget.post.resetPost(online: true);
    } on DioError {
      widget.post.isEditing = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text('failed to edit Post #${widget.post.id}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      throw ControllerException(
          message: 'failed to edit Post #${widget.post.id}');
    }
  }

  Future<void> submitEdit(BuildContext context) async {
    sheetController.show(
      context,
      ControlledTextField(
        labelText: 'Reason',
        submit: (value) => editPost(context, value),
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
        onPressed: widget.post.isEditing
            ? sheetController.action ?? () => submitEdit(context)
            : () {},
        child: widget.post.isEditing
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
      if (widget.post.isEditing || widget.controller == null) {
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
        CrossFade(showChild: shown == widget.post.isEditing, child: child);

    Widget editorScope({required Widget child}) {
      return WillPopScope(
        onWillPop: () async {
          if (sheetController.isShown) {
            return true;
          }
          if (widget.post.isEditing) {
            widget.post.resetPost();
            return false;
          }
          return true;
        },
        child: child,
      );
    }

    return AnimatedSelector(
      animation: widget.post,
      selector: () => [widget.post.isEditing],
      builder: (context, child) {
        return editorScope(
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PostDetailAppBar(post: widget.post),
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
                          ),
                          DescriptionDisplay(post: widget.post),
                          editorDependant(
                              child: LikeDisplay(post: widget.post),
                              shown: false),
                          editorDependant(
                              child: CommentDisplay(post: widget.post),
                              shown: false),
                          Builder(
                            builder: (context) => ParentDisplay(
                              post: widget.post,
                              controller: sheetController,
                            ),
                          ),
                          editorDependant(
                              child: PoolDisplay(post: widget.post),
                              shown: false),
                          Builder(
                            builder: (context) => TagDisplay(
                              post: widget.post,
                              provider: widget.controller,
                              submit: (value, category) => onPostTagsEdit(
                                context,
                                widget.post,
                                value,
                                category,
                              ),
                              controller: sheetController,
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
                              ),
                              shown: true),
                          SourceDisplay(post: widget.post),
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
    );
  }
}

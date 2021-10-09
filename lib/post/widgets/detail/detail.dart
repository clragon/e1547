import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

import 'appbar.dart';
import 'image.dart';
import 'widgets.dart';

class PostDetail extends StatefulWidget {
  final Post post;
  final PostController? controller;
  final Function(int index)? onPageChanged;

  const PostDetail({required this.post, this.controller, this.onPageChanged});

  @override
  State<StatefulWidget> createState() {
    return _PostDetailState();
  }
}

class _PostDetailState extends State<PostDetail> with LinkingMixin, RouteAware {
  SheetActionController sheetController = SheetActionController();
  bool keepPlaying = false;

  late NavigatorState navigator;
  late ModalRoute route;

  Future<void> onPageChange() async {
    if (mounted &&
        route.isActive &&
        !(widget.controller!.itemList?.contains(widget.post) ?? false)) {
      navigator.removeRoute(route);
    }
  }

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        widget.post: closeSheet,
        if (widget.controller != null) widget.controller!: onPageChange,
      };

  void closeSheet() {
    if (!widget.post.isEditing) {
      sheetController.close();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.post.type == PostType.video) {
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    }
    navigator = Navigator.of(context);
    route = ModalRoute.of(context)!;
  }

  @override
  void reassemble() {
    super.reassemble();
    if (widget.post.type == PostType.video) {
      routeObserver.unsubscribe(this);
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    }
    if (widget.post.type == PostType.image && widget.post.file.url != null) {
      preloadImage(context: context, post: widget.post, size: ImageSize.file);
    }
  }

  @override
  void dispose() {
    if (widget.post.type == PostType.video) {
      routeObserver.unsubscribe(this);
    }
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

  Future<bool> editPost(BuildContext context, String reason) async {
    try {
      await client.updatePost(widget.post, Post.fromMap(widget.post.json),
          editReason: reason);
      widget.post.isEditing = false;
    } on DioError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text(
              'failed to edit Post #${widget.post.id} with code ${error.response!.statusCode}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    await widget.post.resetPost(online: true);
    closeSheet();
    return true;
  }

  Future<void> submitEdit(BuildContext context) async {
    sheetController.show(
      context,
      SheetTextField(
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
      Widget gallery(List<Post> posts) {
        return PostFullscreenGallery(
          index: posts.indexOf(widget.post),
          posts: posts,
          onPageChanged: widget.onPageChanged,
        );
      }

      List<Post> posts;
      if (widget.post.isEditing) {
        posts = [widget.post];
      } else {
        posts = widget.controller?.itemList ?? [widget.post];
      }

      if (widget.controller != null) {
        return AnimatedBuilder(
          animation: widget.controller!,
          builder: (context, child) {
            return gallery(posts);
          },
        );
      } else {
        return gallery(posts);
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
                widget.post.isLoggedIn ? Builder(builder: fab) : null,
            body: MediaQuery.removeViewInsets(
              context: context,
              removeTop: true,
              child: ListView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: kBottomNavigationBarHeight + 24,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
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
        );
      },
    );
  }
}

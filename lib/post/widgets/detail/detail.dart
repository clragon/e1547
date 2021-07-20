import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/post/widgets/detail/widgets/favorite.dart';
import 'package:flutter/material.dart';

import 'image.dart';
import 'widgets.dart';

class PostDetail extends StatefulWidget {
  final Post post;
  final PostProvider provider;
  final Function(int index) changePage;

  PostDetail({@required this.post, this.provider, this.changePage});

  @override
  State<StatefulWidget> createState() {
    return _PostDetailState();
  }
}

class _PostDetailState extends State<PostDetail> with RouteAware {
  SheetActionController sheetController = SheetActionController();
  bool keepPlaying = false;

  NavigatorState navigator;
  ModalRoute route;

  Future<void> onPageChange() async {
    if (mounted &&
        route.isActive &&
        !widget.provider.posts.value.contains(widget.post)) {
      navigator.removeRoute(route);
    }
  }

  void closeSheet() {
    if (!widget.post.isEditing.value) {
      sheetController.close();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.provider?.posts?.addListener(onPageChange);
    widget.post.isEditing.addListener(closeSheet);
    if (widget.post.controller == null) {
      widget.post.prepareVideo().then((_) {
        if (!(widget.post.controller?.value?.isInitialized ?? true)) {
          widget.post.initVideo();
        }
      });
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    routeObserver.subscribe(this, ModalRoute.of(context));
    if (widget.post.file.value.url != null) {
      if (widget.post.type == ImageType.Image) {
        preloadImage(context: context, post: widget.post, size: ImageSize.file);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
    if (widget.post.isEditing.value) {
      widget.post.resetPost();
    }
    widget.provider?.pages?.removeListener(onPageChange);
    widget.post.isEditing.removeListener(closeSheet);
    widget.post.controller?.pause();
    if (widget.provider == null) {
      widget.post.dispose();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
    navigator = Navigator.of(context);
    route = ModalRoute.of(context);
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
      await client.updatePost(widget.post, Post.fromMap(widget.post.raw),
          editReason: reason);
      widget.post.isEditing.value = false;
    } on DioError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text(
              'failed to edit Post #${widget.post.id} with code ${error.response.statusCode}'),
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
      EditReasonEditor(
        submit: (value) => editPost(context, value),
        controller: sheetController,
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
        onPressed: widget.post.isEditing.value
            ? sheetController.action ?? () => submitEdit(context)
            : () {},
        child: widget.post.isEditing.value
            ? Icon(sheetController.isShown ? Icons.add : Icons.check)
            : FavoriteButton(post: widget.post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget fullscreen() {
      Widget gallery(List<Post> posts) {
        return PostPhotoGallery(
          index: posts.indexOf(widget.post),
          posts: posts,
          onPageChanged: widget.changePage,
        );
      }

      List<Post> posts;
      if (widget.post.isEditing.value) {
        posts = [widget.post];
      } else {
        posts = widget.provider?.posts?.value ?? [widget.post];
      }

      if (widget.provider != null) {
        return ValueListenableBuilder(
          valueListenable: widget.provider.pages,
          builder: (context, value, child) {
            return gallery(posts);
          },
        );
      } else {
        return gallery(posts);
      }
    }

    Widget editorDependant({@required Widget child, @required bool shown}) {
      return CrossFade(
        showChild: shown == widget.post.isEditing.value,
        child: child,
      );
    }

    return ValueListenableBuilder(
      valueListenable: widget.post.isEditing,
      builder: (context, value, child) {
        return WillPopScope(
          onWillPop: () async {
            if (sheetController.isShown) {
              return true;
            }
            if (widget.post.isEditing.value) {
              widget.post.resetPost();
              return false;
            }
            return true;
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PostDetailAppBar(post: widget.post),
            body: MediaQuery.removeViewInsets(
              context: context,
              removeTop: true,
              child: ListView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: kBottomNavigationBarHeight + 24,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: DetailImageDisplay(
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
                          provider: widget.provider,
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
                            provider: widget.provider,
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
                              provider: widget.provider,
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
                physics: BouncingScrollPhysics(),
              ),
            ),
            floatingActionButton:
                widget.post.isLoggedIn ? Builder(builder: fab) : null,
          ),
        );
      },
    );
  }
}

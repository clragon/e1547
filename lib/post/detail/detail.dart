import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/post/widgets.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'display.dart';
import 'image.dart';

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
  TextEditingController textController = TextEditingController();
  ValueNotifier<Future<bool> Function()> doEdit = ValueNotifier(null);
  PersistentBottomSheetController sheetController;
  bool keepPlaying = false;

  NavigatorState navigator;
  ModalRoute route;

  Future<void> onPageChange() async {
    if (this.mounted && !widget.provider.posts.value.contains(widget.post)) {
      if (mounted && route.isActive) {
        navigator.removeRoute(route);
      }
    }
  }

  void closeSheet() {
    if (!widget.post.isEditing.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sheetController?.close?.call();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.provider?.posts?.addListener(onPageChange);
    widget.post.isEditing.addListener(closeSheet);
    if (!(widget.post.controller?.value?.isInitialized ?? true)) {
      widget.post.initVideo();
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
  void reassemble() {
    super.reassemble();
    routeObserver.unsubscribe(this);
    routeObserver.subscribe(this, ModalRoute.of(context));
    widget.post.isEditing.removeListener(closeSheet);
    widget.post.isEditing.addListener(closeSheet);
    widget.provider?.posts?.removeListener(onPageChange);
    widget.provider?.posts?.addListener(onPageChange);
    if (widget.post.file.value.url != null) {
      if (widget.post.type == ImageType.Image) {
        precacheImage(
          CachedNetworkImageProvider(widget.post.file.value.url),
          context,
        );
      }
    }
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
  Widget build(BuildContext context) {
    Widget fab(BuildContext context) {
      Widget fabIcon() {
        return CrossFade(
          showChild: widget.post.isEditing.value,
          child: ValueListenableBuilder(
            valueListenable: doEdit,
            builder: (context, value, child) {
              if (value == null) {
                return Icon(Icons.check,
                    color: Theme.of(context).iconTheme.color);
              } else {
                return Icon(Icons.add,
                    color: Theme.of(context).iconTheme.color);
              }
            },
          ),
          secondChild: Padding(
            padding: EdgeInsets.only(left: 2),
            child: ValueListenableBuilder(
              valueListenable: widget.post.isFavorite,
              builder: (context, value, child) => Builder(
                builder: (context) => LikeButton(
                  isLiked: value,
                  circleColor: CircleColor(start: Colors.pink, end: Colors.red),
                  bubblesColor: BubblesColor(
                      dotPrimaryColor: Colors.pink,
                      dotSecondaryColor: Colors.red),
                  likeBuilder: (bool isLiked) => Icon(
                    Icons.favorite,
                    color: isLiked
                        ? Colors.pinkAccent
                        : Theme.of(context).iconTheme.color,
                  ),
                  onTap: (isLiked) async {
                    if (isLiked) {
                      widget.post.tryRemoveFav(context);
                      return false;
                    } else {
                      widget.post.tryAddFav(context);
                      return true;
                    }
                  },
                ),
              ),
            ),
          ),
        );
      }

      ValueNotifier<bool> isLoading = ValueNotifier(false);
      Widget reasonEditor() {
        return Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: <Widget>[
                  ValueListenableBuilder(
                    valueListenable: isLoading,
                    builder: (context, value, child) => CrossFade(
                      showChild: value,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Container(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator()),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: textController,
                      autofocus: true,
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Edit reason',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }

      return FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).cardColor,
        child: fabIcon(),
        onPressed: () async {
          if (widget.post.isEditing.value) {
            if (doEdit.value != null) {
              if (await doEdit.value()) {
                sheetController.close();
              }
            } else {
              textController.text = '';
              sheetController = Scaffold.of(context).showBottomSheet(
                (context) {
                  return reasonEditor();
                },
              );
              sheetController.closed.then((_) {
                doEdit.value = null;
                isLoading.value = false;
              });
              doEdit.value = () async {
                isLoading.value = true;
                try {
                  await client.updatePost(
                      widget.post, Post.fromMap(widget.post.raw),
                      editReason: textController.text);
                  widget.post.isEditing.value = false;
                  await widget.post.resetPost(online: true);
                } on DioError catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: Duration(seconds: 1),
                    content: Text(
                        '${e.response.statusCode} : ${e.response.statusMessage}'),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
                isLoading.value = false;
                return true;
              };
            }
          }
        },
      );
    }

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

    return ValueListenableBuilder(
      valueListenable: widget.post.isEditing,
      builder: (context, value, child) {
        Widget editorDependant({@required Widget child, @required bool shown}) {
          return CrossFade(
            showChild: shown == widget.post.isEditing.value,
            child: child,
          );
        }

        return WillPopScope(
          onWillPop: () async {
            if (doEdit.value != null) {
              return true;
            }
            if (value) {
              widget.post.resetPost();
              return false;
            } else {
              return true;
            }
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PostAppBar(post: widget.post),
            body: MediaQuery.removeViewInsets(
                context: context,
                removeTop: true,
                child: ListView(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top, bottom: 24),
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: DetailImageDisplay(
                        post: widget.post,
                        onTap: () {
                          if (widget.post.file.value.url == null ||
                              !widget.post.isVisible) {
                            return;
                          }
                          if (widget.post.type == ImageType.Unsupported) {
                            launch(widget.post.file.value.url);
                            return;
                          }
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
                                    builder: (submit) => doEdit.value = submit,
                                    onEditorClose: () => doEdit.value = null,
                                  )),
                          editorDependant(
                              child: PoolDisplay(post: widget.post),
                              shown: false),
                          Builder(
                              builder: (context) => TagDisplay(
                                    post: widget.post,
                                    builder: (submit) => doEdit.value = submit,
                                    onEditorClose: () => doEdit.value = null,
                                    provider: widget.provider,
                                  )),
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
                )),
            floatingActionButton: widget.post.isLoggedIn
                ? Builder(
                    builder: fab,
                  )
                : null,
          ),
        );
      },
    );
  }
}

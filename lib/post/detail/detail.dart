import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:like_button/like_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'appbar.dart';
import 'display.dart';
import 'overlay.dart';

class PostDetail extends StatefulWidget {
  final Post post;
  final PostProvider provider;
  final PageController controller;

  PostDetail({@required this.post, this.provider, this.controller});

  @override
  State<StatefulWidget> createState() {
    return _PostDetailState();
  }
}

class _PostDetailState extends State<PostDetail> with RouteAware {
  TextEditingController textController = TextEditingController();
  ValueNotifier<Future<bool> Function()> doEdit = ValueNotifier(null);
  PersistentBottomSheetController bottomSheetController;
  bool keepPlaying = false;

  Future<void> updateWidget() async {
    if (this.mounted && !widget.provider.posts.value.contains(widget.post)) {
      Post replacement = Post.fromMap(widget.post.raw);
      replacement.isLoggedIn = widget.post.isLoggedIn;
      replacement.isBlacklisted = widget.post.isBlacklisted;
      if (ModalRoute.of(context).isCurrent) {
        Navigator.of(context).pushReplacement(MaterialPageRoute<Null>(
            builder: (context) => PostDetail(post: replacement)));
      } else {
        Navigator.of(context).replace(
            oldRoute: ModalRoute.of(context),
            newRoute: MaterialPageRoute<Null>(
                builder: (context) => PostDetail(post: replacement)));
      }
    }
  }

  void closeBottomSheet() {
    if (!widget.post.isEditing.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bottomSheetController?.close?.call();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.provider?.posts?.addListener(updateWidget);
    widget.post.isEditing.addListener(closeBottomSheet);
    if (!(widget.post.controller?.value?.initialized ?? true)) {
      widget.post.initVideo();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.unsubscribe(this);
    routeObserver.subscribe(this, ModalRoute.of(context));
    widget.post.isEditing.removeListener(closeBottomSheet);
    widget.post.isEditing.addListener(closeBottomSheet);
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
    if (!keepPlaying) {
      widget.post.controller?.pause();
    } else {
      keepPlaying = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
    if (widget.post.isEditing.value) {
      resetPost(widget.post);
    }
    widget.provider?.pages?.removeListener(updateWidget);
    widget.post.isEditing.removeListener(closeBottomSheet);
    widget.post.controller?.pause();
    if (widget.provider == null) {
      widget.post.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    void onTapImage(BuildContext context) {
      if (widget.post.file.value.url == null) {
        return;
      }
      if (!widget.post.isVisible) {
        return;
      }
      if (widget.post.type == ImageType.Unsupported) {
        launch(widget.post.file.value.url);
        return;
      }
      keepPlaying = true;
      Navigator.of(context).push(MaterialPageRoute<Null>(builder: (context) {
        Widget gallery(List<Post> posts) {
          return PostPhotoGallery(
            index: posts.indexOf(widget.post),
            posts: posts,
            controller: widget.controller,
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
      }));
    }

    Widget postImageWidget() {
      Widget imageContainer() {
        Widget image(Post post) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: CachedNetworkImage(
                  imageUrl: widget.post.sample.value.url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                      child: Container(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(),
                  )),
                  errorWidget: (context, url, error) =>
                      Center(child: Icon(Icons.error_outline)),
                ),
              ),
              // postInfoWidget(),
            ],
          );
        }

        Widget video(Post post) {
          return ValueListenableBuilder(
            valueListenable: widget.post.controller,
            builder: (context, value, child) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => value.isPlaying
                  ? widget.post.controller.pause()
                  : widget.post.controller.play(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  value.initialized
                      ? AspectRatio(
                          aspectRatio: value.aspectRatio,
                          child: VideoPlayer(widget.post.controller),
                        )
                      : image(post),
                  CrossFade(
                      showChild: value.isPlaying &&
                          (!value.initialized || value.isBuffering),
                      child: Container(
                        height: 30,
                        width: 30,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      secondChild: AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: value.isPlaying ? 0 : 1,
                        child: IconShadowWidget(
                          Icon(
                            value.isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 54,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          shadowColor: Colors.black,
                        ),
                      )),
                ],
              ),
            ),
          );
        }

        Widget imageToggle() {
          return ValueListenableBuilder(
            valueListenable: widget.post.showUnsafe,
            builder: (context, value, child) {
              if (!widget.post.isDeleted) {
                return CrossFade(
                  showChild: (widget.post.file.value.url == null ||
                      !widget.post.isVisible ||
                      widget.post.showUnsafe.value),
                  duration: Duration(milliseconds: 200),
                  child: Card(
                    color: value ? Colors.black12 : Colors.transparent,
                    elevation: 0,
                    child: InkWell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              value ? Icons.visibility_off : Icons.visibility,
                              size: 16,
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 5, left: 5),
                              child: value ? Text('hide') : Text('show'),
                            )
                          ],
                        ),
                      ),
                      onTap: () async {
                        if (await db.customHost.value == null) {
                          await setCustomHost(context);
                        }
                        if (await db.customHost.value != null) {
                          Post replacement;
                          if (widget.post.file.value.url == null) {
                            replacement =
                                await client.post(widget.post.id, unsafe: true);
                          } else {
                            replacement = Post.fromMap(widget.post.raw);
                          }
                          widget.post.file.value = replacement.file.value;
                          widget.post.preview.value = replacement.preview.value;
                          widget.post.sample.value = replacement.sample.value;
                          widget.post.showUnsafe.value =
                              !widget.post.showUnsafe.value;
                        }
                      },
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        }

        Widget fullscreenButton() {
          if (widget.post.type == ImageType.Video) {
            return CrossFade(
              showChild:
                  widget.post.file.value.url != null && widget.post.isVisible,
              duration: Duration(milliseconds: 200),
              child: Card(
                elevation: 0,
                color: Colors.black12,
                child: InkWell(
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.fullscreen,
                      size: 24,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  onTap: () => onTapImage(context),
                ),
              ),
            );
          } else {
            return Container();
          }
        }

        Widget imageOverlay() {
          return ValueListenableBuilder(
            valueListenable: widget.post.file,
            builder: (BuildContext context, value, Widget child) {
              return Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () => onTapImage(context),
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: (MediaQuery.of(context).size.height / 2),
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'image_${widget.post.id}',
                          child: PostOverlay(
                            post: widget.post,
                            builder: widget.post.type == ImageType.Video
                                ? video
                                : image,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        fullscreenButton(),
                        imageToggle(),
                      ],
                    ),
                    bottom: 0,
                    right: 5,
                  )
                ],
              );
            },
          );
        }

        return imageOverlay();
      }

      return ValueListenableBuilder(
        valueListenable: widget.post.showUnsafe,
        builder: (context, value, child) {
          return imageContainer();
        },
      );
    }

    Widget fab(BuildContext context) {
      Widget fabIcon() {
        if (widget.post.isEditing.value) {
          return ValueListenableBuilder(
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
          );
        } else {
          return Padding(
              padding: EdgeInsets.only(left: 2),
              child: ValueListenableBuilder(
                valueListenable: widget.post.isFavorite,
                builder: (context, value, child) {
                  return Builder(
                    builder: (context) {
                      return LikeButton(
                        isLiked: value,
                        circleColor:
                            CircleColor(start: Colors.pink, end: Colors.red),
                        bubblesColor: BubblesColor(
                            dotPrimaryColor: Colors.pink,
                            dotSecondaryColor: Colors.red),
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            Icons.favorite,
                            color: isLiked
                                ? Colors.pinkAccent
                                : Theme.of(context).iconTheme.color,
                          );
                        },
                        onTap: (isLiked) async {
                          if (isLiked) {
                            tryRemoveFav(context, widget.post);
                            return false;
                          } else {
                            tryAddFav(context, widget.post);
                            return true;
                          }
                        },
                      );
                    },
                  );
                },
              ));
        }
      }

      ValueNotifier<bool> isLoading = ValueNotifier(false);
      Widget reasonEditor() {
        return Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                children: <Widget>[
                  ValueListenableBuilder(
                    valueListenable: isLoading,
                    builder: (context, value, child) {
                      if (value) {
                        return Center(
                            child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Container(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator()),
                        ));
                      } else {
                        return Container();
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: textController,
                      autofocus: true,
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Edit reason',
                          border: UnderlineInputBorder()),
                    ),
                  ),
                ],
              )
            ]));
      }

      return FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).cardColor,
        child: fabIcon(),
        onPressed: () async {
          if (widget.post.isEditing.value) {
            if (doEdit.value != null) {
              if (await doEdit.value()) {
                bottomSheetController.close();
              }
            } else {
              textController.text = '';
              bottomSheetController = Scaffold.of(context).showBottomSheet(
                (context) {
                  return reasonEditor();
                },
              );
              bottomSheetController.closed.then((_) {
                doEdit.value = null;
                isLoading.value = false;
              });
              doEdit.value = () async {
                isLoading.value = true;
                Map response = await client.updatePost(
                    widget.post, Post.fromMap(widget.post.raw),
                    editReason: textController.text);
                isLoading.value = false;
                if (response == null || response['code'] == 200) {
                  isLoading.value = false;
                  widget.post.isEditing.value = false;
                  await resetPost(widget.post, online: true);
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    duration: Duration(seconds: 1),
                    content: Text(
                        'Failed to send post: ${response['code']} : ${response['reason']}'),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
                return true;
              };
            }
          }
        },
      );
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

        List<Widget> details = <Widget>[
          ArtistDisplay(post: widget.post),
          DescriptionDisplay(post: widget.post),
          editorDependant(child: LikeDisplay(post: widget.post), shown: false),
          editorDependant(
              child: CommentDisplay(post: widget.post), shown: false),
          Builder(
              builder: (context) => ParentDisplay(
                    post: widget.post,
                    builder: (submit) => doEdit.value = submit,
                    onEditorClose: () => doEdit.value = null,
                  )),
          editorDependant(child: PoolDisplay(post: widget.post), shown: false),
          Builder(
              builder: (context) => TagDisplay(
                    post: widget.post,
                    builder: (submit) => doEdit.value = submit,
                    onEditorClose: () => doEdit.value = null,
                  )),
          editorDependant(child: FileDisplay(post: widget.post), shown: false),
          editorDependant(
              child: RatingDisplay(
                post: widget.post,
              ),
              shown: true),
          SourceDisplay(post: widget.post),
        ];

        details = details
            .map<Widget>((child) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: child,
                ))
            .toList();

        details.insert(
            0,
            Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: postImageWidget(),
            ));

        return WillPopScope(
          onWillPop: () async {
            if (doEdit.value != null) {
              return true;
            }
            if (value) {
              resetPost(widget.post);
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
                child: ListView.builder(
                  itemCount: details.length,
                  itemBuilder: (BuildContext context, int index) =>
                      details[index],
                  physics: BouncingScrollPhysics(),
                )),
            floatingActionButton: widget.post.isLoggedIn
                ? Builder(
                    builder: (context) {
                      return fab(context);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}

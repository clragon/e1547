import 'dart:async' show Future, Timer;
import 'dart:core';
import 'dart:io' show File, Platform;
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:copy_to_gallery/copy_to_gallery.dart';
import 'package:e1547/appInfo.dart';
import 'package:e1547/client.dart' show client;
import 'package:e1547/comment.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/settings.dart' show db;
import 'package:e1547/wiki_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, SystemChrome, SystemUiOverlay;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    show DefaultCacheManager;
import 'package:icon_shadow/icon_shadow.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart' as url;
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'main.dart';

enum ImageType { Image, Video, Unsupported }

class PostImage {
  Map file;
  Map preview;
  Map sample;

  PostImage.fromRaw(Map raw) {
    file = raw['file'] as Map;
    preview = raw['preview'] as Map;
    sample = raw['sample'] as Map;
  }
}

class Post {
  Map raw;
  int id;

  String creation;
  String updated;

  String uploader;

  List<int> pools = [];
  List<int> children = [];

  bool isDeleted = false;
  bool isLoggedIn = false;
  bool isBlacklisted = false;

  ValueNotifier<PostImage> image = ValueNotifier(null);

  ValueNotifier<Map<String, List<String>>> tags = ValueNotifier({});

  ValueNotifier<int> comments = ValueNotifier(null);
  ValueNotifier<int> score = ValueNotifier(null);
  ValueNotifier<int> favorites = ValueNotifier(null);
  ValueNotifier<int> parent = ValueNotifier(null);

  ValueNotifier<String> rating = ValueNotifier(null);
  ValueNotifier<String> description = ValueNotifier(null);

  ValueNotifier<List<String>> sources = ValueNotifier([]);

  ValueNotifier<bool> isFavorite = ValueNotifier(false);
  ValueNotifier<bool> isEditing = ValueNotifier(false);
  ValueNotifier<bool> showUnsafe = ValueNotifier(false);

  bool get isVisible =>
      (isFavorite.value || showUnsafe.value || !isBlacklisted);

  ValueNotifier<VoteStatus> voteStatus = ValueNotifier(VoteStatus.unknown);

  static List<Post> loadedVideos = [];

  VideoPlayerController controller;

  ImageType type;

  List<String> get artists {
    return tags.value['artist']
      ..removeWhere((artist) => [
            'epilepsy_warning',
            'conditional_dnp',
            'sound_warning',
            'avoid_posting',
          ].contains(artist));
  }

  Post.fromRaw(this.raw) {
    id = raw['id'] as int;
    favorites = ValueNotifier(raw['fav_count'] as int);

    isFavorite = ValueNotifier(raw['is_favorited'] as bool);
    isDeleted = raw['flags']['deleted'] as bool;
    isBlacklisted = false;

    parent.value = raw["relationships"]['parent_id'] as int;
    children.addAll(raw["relationships"]['children'].cast<int>());

    creation = raw['created_at'];
    updated = raw['updated_at'];

    description.value = raw['description'] as String;
    rating.value = (raw['rating'] as String).toLowerCase();
    comments.value = (raw['comment_count'] as int);

    // remove occasional duplicate data
    pools.addAll(raw['pools'].cast<int>().toSet().toList());

    sources.value.addAll(raw['sources'].cast<String>());

    (raw['tags'] as Map).forEach((category, strings) {
      tags.value[category] = List.from(strings);
    });

    score = ValueNotifier(raw['score']['total'] as int);
    uploader = (raw['uploader_id'] as int).toString();

    image.value = PostImage.fromRaw(raw);

    switch (image.value.file['ext'].toLowerCase()) {
      case 'webm':
        if (!Platform.isIOS) {
          type = ImageType.Video;
        } else {
          type = ImageType.Unsupported;
        }
        break;
      case 'swf':
        type = ImageType.Unsupported;
        break;
      default:
        type = ImageType.Image;
        break;
    }

    prepareVideo();
  }

  Future<void> prepareVideo() async {
    if (type == ImageType.Video) {
      if (controller != null) {
        await controller.pause();
        await controller.dispose();
      }
      controller = VideoPlayerController.network(image.value.file['url']);
      controller.setLooping(true);
      controller.addListener(() {
        controller.value.isPlaying ? Wakelock.enable() : Wakelock.disable();
      });
    }
  }

  Future<void> initVideo() async {
    if (type != ImageType.Video || loadedVideos.contains(this)) {
      return;
    }
    if (loadedVideos.length >= 6) {
      await loadedVideos[0].prepareVideo();
      loadedVideos.removeAt(0);
    }
    loadedVideos.add(this);
    await this.controller.initialize();
  }

  void dispose() {
    tags.dispose();
    comments.dispose();
    parent.dispose();
    score.dispose();
    favorites.dispose();
    rating.dispose();
    description.dispose();
    sources.dispose();
    isFavorite.dispose();
    isEditing.dispose();
    showUnsafe.dispose();
    controller?.dispose();
    loadedVideos.remove(this);
  }

  // build post URL
  Uri url(String host) =>
      new Uri(scheme: 'https', host: host, path: '/posts/$id');
}

class PostPreview extends StatelessWidget {
  final Post post;
  final VoidCallback onPressed;

  PostPreview({
    @required this.post,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget image() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ValueListenableBuilder(
                valueListenable: post.image,
                builder: (context, value, child) {
                  if (post.isDeleted) {
                    return Center(child: Text('deleted'));
                  }
                  if (post.type == ImageType.Unsupported) {
                    return Center(child: Text('unsupported'));
                  }
                  if (post.image.value.file['url'] == null) {
                    return Center(child: Text('unsafe'));
                  }
                  return Hero(
                    tag: 'image_${post.id}',
                    child: CachedNetworkImage(
                      imageUrl: post.image.value.sample['url'],
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  );
                }),
          ),
        ],
      );
    }

    Widget overlay() {
      if (post.image.value.file['ext'] == 'gif') {
        return Container(
          color: Colors.black12,
          child: Icon(Icons.gif),
        );
      }
      if (post.type == ImageType.Video) {
        return Container(
          color: Colors.black12,
          child: Icon(Icons.play_arrow),
        );
      }
      return Container();
    }

    return Card(
      child: InkWell(
          onTap: onPressed,
          child: Stack(
            children: <Widget>[
              image(),
              Positioned(top: 0, right: 0, child: overlay()),
            ],
          )),
    );
  }
}

class PostDetailGallery extends StatefulWidget {
  final PostProvider provider;
  final int initialPage;

  const PostDetailGallery({@required this.provider, this.initialPage = 0});

  @override
  _PostDetailGalleryState createState() => _PostDetailGalleryState();
}

class _PostDetailGalleryState extends State<PostDetailGallery> {
  int lastIndex;
  PageController controller;

  @override
  void initState() {
    super.initState();
    lastIndex = widget.initialPage;
    controller = PageController(
        initialPage: widget.initialPage, viewportFraction: 1.000000000001);
  }

  @override
  Widget build(BuildContext context) {
    Widget _pageBuilder(BuildContext context, int index) {
      if (index == widget.provider.posts.value.length - 1) {
        widget.provider.loadNextPage();
      }
      return index < widget.provider.posts.value.length
          ? PostDetail(
              post: widget.provider.posts.value[index],
              provider: widget.provider,
              controller: controller,
            )
          : null;
    }

    return ValueListenableBuilder(
      valueListenable: widget.provider.pages,
      builder: (context, value, child) {
        return PageView.builder(
          controller: controller,
          itemBuilder: _pageBuilder,
          onPageChanged: (index) {
            int reach = 2;
            for (int i = -(reach + 1); i < reach; i++) {
              int target = index + 1 + i;
              if (0 < target && target < widget.provider.posts.value.length) {
                String url = widget
                    .provider.posts.value[target].image.value.sample['url'];
                if (url != null) {
                  precacheImage(
                    CachedNetworkImageProvider(url),
                    context,
                  );
                }
              }
            }
            if (widget.provider.posts.value.length != 0) {
              if (widget.provider.posts.value[lastIndex].isEditing.value) {
                resetPost(widget.provider.posts.value[lastIndex]);
              }
            }
            lastIndex = index;
          },
        );
      },
    );
  }
}

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
      Post replacement = Post.fromRaw(widget.post.raw);
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
        try {
          bottomSheetController?.close?.call();
        } on NoSuchMethodError {
          // this error is thrown when hot reloading in debug mode
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.post.isEditing.addListener(closeBottomSheet);
    widget.provider?.posts?.addListener(updateWidget);
    if (!(widget.post.controller?.value?.initialized ?? true)) {
      widget.post.initVideo();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
    if (widget.post.image.value.file['url'] != null) {
      if (widget.post.type == ImageType.Image) {
        precacheImage(
          CachedNetworkImageProvider(widget.post.image.value.file['url']),
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
      if (widget.post.image.value.file['url'] == null) {
        return;
      }
      if (!widget.post.isVisible) {
        return;
      }
      if (widget.post.type == ImageType.Unsupported) {
        url.launch(widget.post.image.value.file['url']);
        return;
      }
      keepPlaying = true;
      Navigator.of(context).push(MaterialPageRoute<Null>(builder: (context) {
        Widget gallery(List<Post> posts) {
          return PostImageGallery(
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
                  imageUrl: widget.post.image.value.sample['url'],
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
                  crossFade(
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
            builder: (context, value, child) => crossFade(
              showChild: !widget.post.isDeleted &&
                  (widget.post.image.value.file['url'] == null ||
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
                      widget.post.showUnsafe.value =
                          !widget.post.showUnsafe.value;
                      Post urls =
                          await client.post(widget.post.id, unsafe: true);
                      if (widget.post.image.value.file['url'] == null) {
                        widget.post.image.value = urls.image.value;
                      } else {
                        widget.post.image.value =
                            PostImage.fromRaw(widget.post.raw);
                      }
                    }
                  },
                ),
              ),
            ),
          );
        }

        Widget fullscreenButton() {
          return crossFade(
            showChild: widget.post.image.value.file['url'] != null &&
                widget.post.isVisible &&
                widget.post.type == ImageType.Video,
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
        }

        Widget imageOverlay() {
          return ValueListenableBuilder(
            valueListenable: widget.post.image,
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

    Widget postMetadataWidget() {
      Widget artists() {
        return ValueListenableBuilder(
          valueListenable: widget.post.tags,
          builder: (BuildContext context, value, Widget child) {
            if (widget.post.tags.value['artist'].length != 0) {
              return Text.rich(
                TextSpan(children: () {
                  List<InlineSpan> spans = [];
                  int count = 0;
                  for (String artist in widget.post.artists) {
                    count++;
                    if (count > 1) {
                      spans.add(TextSpan(text: ', '));
                    }
                    spans.add(WidgetSpan(
                        child: InkWell(
                      child: Text(
                        artist,
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<Null>(
                              builder: (context) => SearchPage(tags: artist))),
                      onLongPress: () =>
                          wikiDialog(context, artist, actions: true),
                    )));
                  }
                  return spans;
                }()),
                overflow: TextOverflow.fade,
              );
            } else {
              return Text('no artist',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.subtitle2.color,
                      fontStyle: FontStyle.italic));
            }
          },
        );
      }

      Widget artistDisplay() {
        return Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.account_circle),
                      ),
                      Flexible(
                        child: artists(),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Builder(
                      builder: (BuildContext context) {
                        return InkWell(
                          child: Text('#${widget.post.id}'),
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(
                              text: widget.post.id.toString(),
                            ));
                            Scaffold.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 1),
                              content:
                                  Text('Copied post ID #${widget.post.id}'),
                            ));
                          },
                        );
                      },
                    ),
                    InkWell(
                      child: Row(children: [
                        Icon(Icons.person, size: 14.0),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(widget.post.uploader),
                        ),
                      ]),
                      onTap: () async {
                        String uploader =
                            (await client.user(widget.post.uploader))['name'];
                        Navigator.of(context)
                            .push(MaterialPageRoute<Null>(builder: (context) {
                          return SearchPage(tags: 'user:$uploader');
                        }));
                      },
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
          ],
        );
      }

      Widget descriptionDisplay() {
        return ValueListenableBuilder(
          valueListenable: widget.post.description,
          builder: (context, value, child) {
            return crossFade(
              showChild: value.isNotEmpty || widget.post.isEditing.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  crossFade(
                    showChild: widget.post.isEditing.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Description',
                          style: TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.of(context).push(
                                MaterialPageRoute<String>(builder: (context) {
                              return TextEditor(
                                title: '#${widget.post.id} description',
                                content: value,
                                validator: (context, text) async {
                                  widget.post.description.value = text;
                                  return true;
                                },
                              );
                            }));
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: value.isNotEmpty
                                ? dTextField(context, value)
                                : Text('no description',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .color
                                            .withOpacity(0.35),
                                        fontStyle: FontStyle.italic)),
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                ],
              ),
            );
          },
        );
      }

      Widget likeDisplay() {
        return Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ValueListenableBuilder(
                      valueListenable: widget.post.voteStatus,
                      builder: (context, value, child) {
                        return LikeButton(
                          isLiked: value == VoteStatus.upvoted,
                          likeBuilder: (bool isLiked) {
                            return Icon(
                              Icons.arrow_upward,
                              color: isLiked
                                  ? Colors.deepOrange
                                  : Theme.of(context).iconTheme.color,
                            );
                          },
                          onTap: (isLiked) async {
                            if (widget.post.isLoggedIn) {
                              if (isLiked) {
                                tryVote(context, widget.post, true, false);
                                return false;
                              } else {
                                tryVote(context, widget.post, true, true);
                                return true;
                              }
                            } else {
                              return false;
                            }
                          },
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: ValueListenableBuilder(
                        valueListenable: widget.post.score,
                        builder: (context, value, child) {
                          return Text((value ?? 0).toString());
                        },
                      ),
                    ),
                    ValueListenableBuilder(
                        valueListenable: widget.post.voteStatus,
                        builder: (context, value, child) {
                          return Builder(
                            builder: (context) {
                              return LikeButton(
                                isLiked: value == VoteStatus.downvoted,
                                circleColor: CircleColor(
                                    start: Colors.blue, end: Colors.cyanAccent),
                                bubblesColor: BubblesColor(
                                    dotPrimaryColor: Colors.blue,
                                    dotSecondaryColor: Colors.cyanAccent),
                                likeBuilder: (bool isLiked) {
                                  return Icon(
                                    Icons.arrow_downward,
                                    color: isLiked
                                        ? Colors.blue
                                        : Theme.of(context).iconTheme.color,
                                  );
                                },
                                onTap: (isLiked) async {
                                  if (widget.post.isLoggedIn) {
                                    if (isLiked) {
                                      tryVote(
                                          context, widget.post, false, false);
                                      return false;
                                    } else {
                                      tryVote(
                                          context, widget.post, false, true);
                                      return true;
                                    }
                                  } else {
                                    return false;
                                  }
                                },
                              );
                            },
                          );
                        }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ValueListenableBuilder(
                      valueListenable: widget.post.favorites,
                      builder: (context, value, child) {
                        return Text((value ?? 0).toString());
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.favorite),
                    ),
                  ],
                )
              ],
            ),
            Divider(),
          ],
        );
      }

      Widget poolDisplay() {
        if (widget.post.pools.length != 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: () {
              List<Widget> items = [];
              items.add(Padding(
                padding: EdgeInsets.only(
                  right: 4,
                  left: 4,
                  top: 2,
                  bottom: 2,
                ),
                child: Text(
                  'Pools',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ));
              for (int pool in widget.post.pools) {
                items.add(loadingListTile(
                  leading: Icon(Icons.group),
                  title: Text(pool.toString()),
                  onTap: () async {
                    Pool p = await client.pool(pool);
                    if (p != null) {
                      Navigator.of(context)
                          .push(MaterialPageRoute<Null>(builder: (context) {
                        return PoolPage(pool: p);
                      }));
                    } else {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        duration: Duration(seconds: 1),
                        content: Text('Coulnd\'t retrieve Pool #${p.id}'),
                      ));
                    }
                  },
                ));
              }
              items.add(Divider());
              return items;
            }(),
          );
        } else {
          return Container();
        }
      }

      Widget parentDisplay() {
        ValueNotifier<bool> isLoading = ValueNotifier(false);
        Widget parentInput() {
          return Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  children: <Widget>[
                    ValueListenableBuilder(
                      valueListenable: isLoading,
                      builder: (context, value, child) {
                        return crossFade(
                          showChild: value,
                          child: child,
                        );
                      },
                      child: Center(
                          child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Container(
                            height: 20,
                            width: 20,
                            child: Padding(
                              padding: EdgeInsets.all(2),
                              child: CircularProgressIndicator(),
                            )),
                      )),
                    ),
                    Expanded(
                      child: TextField(
                        controller: textController,
                        autofocus: true,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^ ?\d*')),
                        ],
                        decoration: InputDecoration(
                            labelText: 'Parent ID',
                            border: UnderlineInputBorder()),
                        onSubmitted: (_) async {
                          if (await doEdit.value()) {
                            bottomSheetController.close();
                          }
                        },
                      ),
                    ),
                  ],
                )
              ]));
        }

        return ValueListenableBuilder(
          valueListenable: widget.post.parent,
          builder: (context, value, child) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  crossFade(
                    showChild: value != null || widget.post.isEditing.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            right: 4,
                            left: 4,
                            top: 2,
                            bottom: 2,
                          ),
                          child: Text(
                            'Parent',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        loadingListTile(
                          leading: Icon(Icons.supervisor_account),
                          title: Text(value?.toString() ?? 'none'),
                          trailing: widget.post.isEditing.value
                              ? Builder(
                                  builder: (BuildContext context) {
                                    return IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        isLoading.value = false;
                                        textController.text =
                                            value?.toString() ?? ' ';
                                        setFocusToEnd(textController);
                                        bottomSheetController =
                                            Scaffold.of(context)
                                                .showBottomSheet(
                                          (context) {
                                            return parentInput();
                                          },
                                        );
                                        doEdit.value = () async {
                                          isLoading.value = true;
                                          if (textController.text
                                              .trim()
                                              .isEmpty) {
                                            widget.post.parent.value = null;
                                            isLoading.value = false;
                                            return true;
                                          }
                                          if (int.tryParse(
                                                  textController.text) !=
                                              null) {
                                            Post parent = await client.post(
                                                int.tryParse(
                                                    textController.text));
                                            if (parent != null) {
                                              widget.post.parent.value =
                                                  parent.id;
                                              return true;
                                            }
                                          }
                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(
                                            duration: Duration(seconds: 1),
                                            content:
                                                Text('Invalid parent post'),
                                            behavior: SnackBarBehavior.floating,
                                          ));
                                          isLoading.value = false;
                                          return false;
                                        };
                                        bottomSheetController.closed.then((_) {
                                          doEdit.value = null;
                                        });
                                      },
                                    );
                                  },
                                )
                              : null,
                          onTap: () async {
                            if (value != null) {
                              Post post = await client.post(value);
                              if (post != null) {
                                Navigator.of(context).push(
                                    MaterialPageRoute<Null>(builder: (context) {
                                  return PostDetail(post: post);
                                }));
                              } else {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  duration: Duration(seconds: 1),
                                  content:
                                      Text('Coulnd\'t retrieve Post #$value'),
                                ));
                              }
                            }
                          },
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                  crossFade(
                    showChild: widget.post.children.length != 0 &&
                        !widget.post.isEditing.value,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: () {
                          List<Widget> items = [];
                          items.add(
                            Padding(
                              padding: EdgeInsets.only(
                                right: 4,
                                left: 4,
                                top: 2,
                                bottom: 2,
                              ),
                              child: Text(
                                'Children',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                          for (int child in widget.post.children) {
                            items.add(loadingListTile(
                              leading: Icon(Icons.supervised_user_circle),
                              title: Text(child.toString()),
                              onTap: () async {
                                Post post = await client.post(child);
                                if (post != null) {
                                  await Navigator.of(context).push(
                                      MaterialPageRoute<Null>(
                                          builder: (context) {
                                    return PostDetail(post: post);
                                  }));
                                } else {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text(
                                        'Coulnd\'t retrieve Post #${child.toString()}'),
                                  ));
                                }
                              },
                            ));
                          }
                          items.add(Divider());
                          if (items.length == 0) {
                            items.add(Container());
                          }
                          return items;
                        }()),
                  ),
                ]);
          },
        );
      }

      Widget tagDisplay() {
        Widget tagCard(String tag, String tagSet) {
          return Card(
              child: InkWell(
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute<Null>(
                        builder: (context) => SearchPage(tags: tag),
                      )),
                  onLongPress: () => wikiDialog(context, tag, actions: true),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: getCategoryColor(tagSet),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5)),
                        ),
                        height: 24,
                        child: crossFade(
                          showChild: widget.post.isEditing.value,
                          child: InkWell(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: 4, left: 4, top: 4, bottom: 4),
                              child: Icon(Icons.clear, size: 16),
                            ),
                            onTap: () {
                              widget.post.tags.value[tagSet].remove(tag);
                              widget.post.tags.value =
                                  Map.from(widget.post.tags.value);
                            },
                          ),
                          secondChild: Container(width: 5),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 4, bottom: 4, right: 8, left: 6),
                          child: Text(
                            tag.replaceAll('_', ' '),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  )));
        }

        Widget tagCreator(String tagSet) {
          ValueNotifier isLoading = ValueNotifier(false);

          Widget tagInput() {
            return Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ValueListenableBuilder(
                        valueListenable: isLoading,
                        builder: (context, value, child) {
                          if (value) {
                            return child;
                          } else {
                            return Container();
                          }
                        },
                        child: Center(
                            child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Container(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator()),
                        )),
                      ),
                      Expanded(
                        child: tagInputField(
                            labelText: tagSet,
                            onSubmit: () async {
                              if (await doEdit.value()) {
                                bottomSheetController.close();
                              }
                            },
                            controller: textController,
                            category: categories[tagSet]),
                      ),
                    ],
                  )
                ]));
          }

          return Builder(
            builder: (BuildContext context) {
              return Card(
                child: InkWell(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 4),
                    child: Icon(Icons.add, size: 16),
                  ),
                  onTap: () async {
                    textController.text = '';
                    bottomSheetController =
                        Scaffold.of(context).showBottomSheet(
                      (context) => tagInput(),
                    );
                    doEdit.value = () async {
                      isLoading.value = true;
                      if (textController.text.trim().isEmpty) {
                        isLoading.value = false;
                        return true;
                      }
                      List<String> tags = textController.text.trim().split(' ');
                      widget.post.tags.value[tagSet].addAll(tags);
                      widget.post.tags.value[tagSet].toSet().toList().sort();
                      widget.post.tags.value = Map.from(widget.post.tags.value);
                      if (tagSet != 'general') {
                        () async {
                          for (String tag in tags) {
                            List validator = (await client.autocomplete(tag));
                            String category;
                            if (validator.length == 0) {
                              category = 'general';
                            } else if (validator[0]['category'] !=
                                categories[tagSet]) {
                              category = categories.keys.firstWhere((k) =>
                                  validator[0]['category'] == categories[k]);
                            }
                            if (category != null) {
                              widget.post.tags.value[tagSet].remove(tag);
                              widget.post.tags.value[category].add(tag);
                              widget.post.tags.value[category]
                                  .toSet()
                                  .toList()
                                  .sort();
                              widget.post.tags.value =
                                  Map.from(widget.post.tags.value);
                              Scaffold.of(context).showSnackBar(SnackBar(
                                duration: Duration(seconds: 1),
                                content: Text('Moved $tag to $category tags'),
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                            await new Future.delayed(
                                const Duration(milliseconds: 200));
                          }
                        }();
                      }
                      return true;
                    };
                    bottomSheetController.closed.then((_) {
                      doEdit.value = null;
                      isLoading.value = false;
                    });
                  },
                ),
              );
            },
          );
        }

        return ValueListenableBuilder(
          valueListenable: widget.post.tags,
          builder: (context, value, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: categories.keys
                  .where((tagSet) =>
                      value[tagSet].length != 0 ||
                      (widget.post.isEditing.value && tagSet != 'invalid'))
                  .map((tagSet) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            child: Text(
                              '${tagSet[0].toUpperCase()}${tagSet.substring(1)}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  children: () {
                                    List<Widget> tags = [];
                                    for (String tag in value[tagSet]) {
                                      tags.add(
                                        tagCard(tag, tagSet),
                                      );
                                    }
                                    tags.add(crossFade(
                                      showChild: widget.post.isEditing.value,
                                      child: tagCreator(tagSet),
                                    ));
                                    return tags;
                                  }(),
                                ),
                              )
                            ],
                          ),
                          Divider(),
                        ],
                      ))
                  .toList(),
            );
          },
        );
      }

      Widget commentDisplay() {
        return ValueListenableBuilder(
          valueListenable: widget.post.comments,
          builder: (BuildContext context, int value, Widget child) {
            int count = value ?? 0;
            return crossFade(
              showChild: count > 0,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlineButton(
                          child: Text('COMMENTS ($count)'),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute<Null>(
                              settings: RouteSettings(name: 'comments'),
                              builder: (context) => CommentsWidget(widget.post),
                            ));
                          },
                        ),
                      )
                    ],
                  ),
                  Divider(),
                ],
              ),
            );
          },
        );
      }

      Widget ratingDisplay() {
        IconData getIcon(String rating) {
          switch (rating) {
            case 's':
              return Icons.check_circle_outline;
            case 'q':
              return Icons.help_outline;
            case 'e':
              return Icons.warning;
            default:
              return Icons.error_outline;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                right: 4,
                left: 4,
                top: 2,
                bottom: 2,
              ),
              child: Text(
                'Rating',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            ValueListenableBuilder(
                valueListenable: widget.post.rating,
                builder: (context, value, child) {
                  return ListTile(
                    title: Text(ratings[value]),
                    leading: Icon(!widget.post.raw['flags']['rating_locked']
                        ? getIcon(value)
                        : Icons.lock),
                    onTap: !widget.post.raw['flags']['rating_locked']
                        ? () => showDialog(
                            context: context,
                            child: AlertDialog(
                              title: Text('Rating'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: () {
                                  List<Widget> choices = [];
                                  ratings.forEach((k, v) {
                                    choices.add(ListTile(
                                      title: Text(v),
                                      leading: Icon(getIcon(k)),
                                      onTap: () {
                                        widget.post.rating.value =
                                            k.toLowerCase();
                                        Navigator.of(context).pop();
                                      },
                                    ));
                                  });
                                  return choices;
                                }(),
                              ),
                            ))
                        : () {},
                  );
                }),
            Divider(),
          ],
        );
      }

      Widget fileDisplay() {
        DateFormat dateFormat = DateFormat('dd.MM.yy HH:mm');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'File',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(ratings[widget.post.rating.value]),
                  Text(
                      '${widget.post.image.value.file['width']} x ${widget.post.image.value.file['height']}'),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(dateFormat
                      .format(DateTime.parse(widget.post.creation).toLocal())),
                  Text(formatBytes(widget.post.image.value.file['size'], 1)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  widget.post.updated != null
                      ? Text(dateFormat.format(
                          DateTime.parse(widget.post.updated).toLocal()))
                      : Container(),
                  InkWell(
                      child: Text(widget.post.image.value.file['ext']),
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute<Null>(
                            builder: (context) => SearchPage(
                                tags:
                                    'type:${widget.post.image.value.file['ext']}'),
                          ))),
                ],
              ),
            ),
            Divider(),
          ],
        );
      }

      Widget sourceDisplay() {
        return ValueListenableBuilder(
          valueListenable: widget.post.sources,
          builder: (BuildContext context, value, Widget child) => crossFade(
            showChild: value.length != 0 || widget.post.isEditing.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Sources',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    crossFade(
                      showChild: widget.post.isEditing.value,
                      child: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.of(context).push(
                              MaterialPageRoute<String>(builder: (context) {
                            return TextEditor(
                              title: '#${widget.post.id} sources',
                              content: value.join('\n'),
                              richEditor: false,
                              validator: (context, text) async {
                                widget.post.sources.value =
                                    text.trim().split('\n');
                                return true;
                              },
                            );
                          }));
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: value.join('\n').trim().isNotEmpty
                      ? dTextField(context, value.join('\n'))
                      : Padding(
                          padding: EdgeInsets.all(4),
                          child: Text('no sources',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color
                                      .withOpacity(0.35),
                                  fontStyle: FontStyle.italic)),
                        ),
                ),
                Divider(),
              ],
            ),
          ),
        );
      }

      Widget editorDependant({@required Widget child, @required bool shown}) {
        return crossFade(
          showChild: shown == widget.post.isEditing.value,
          child: child,
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            artistDisplay(),
            descriptionDisplay(),
            editorDependant(child: likeDisplay(), shown: false),
            editorDependant(child: commentDisplay(), shown: false),
            parentDisplay(),
            editorDependant(child: poolDisplay(), shown: false),
            tagDisplay(),
            editorDependant(child: fileDisplay(), shown: false),
            editorDependant(child: ratingDisplay(), shown: true),
            sourceDisplay(),
          ],
        ),
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
                    widget.post, Post.fromRaw(widget.post.raw),
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
            appBar: postAppBar(context, widget.post),
            body: MediaQuery.removeViewInsets(
                context: context,
                removeTop: true,
                child: ListView(
                  children: <Widget>[
                    postImageWidget(),
                    postMetadataWidget(),
                  ],
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

enum LoadingState {
  none,
  sample,
  full,
}

class PostImageGallery extends StatefulWidget {
  final int index;
  final List<Post> posts;
  final PageController controller;

  const PostImageGallery(
      {this.index = 0, @required this.posts, this.controller});

  @override
  _PostImageGalleryState createState() => _PostImageGalleryState();
}

class _PostImageGalleryState extends State<PostImageGallery> {
  ValueNotifier<bool> showFrame = ValueNotifier(false);
  ValueNotifier<int> current = ValueNotifier(null);

  void toggleFrame({bool shown}) {
    showFrame.value = shown ?? !showFrame.value;
    SystemChrome.setEnabledSystemUIOverlays(
        showFrame.value ? SystemUiOverlay.values : []);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    current.value = widget.index;
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    Widget frame(Widget picture) {
      return ValueListenableBuilder(
        valueListenable: current,
        builder: (context, value, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: ValueListenableBuilder(
                valueListenable: showFrame,
                builder: (context, visible, child) => crossFade(
                  duration: Duration(milliseconds: 200),
                  showChild: visible,
                  child: child,
                ),
                child: Builder(
                  builder: (context) {
                    return postAppBar(context, widget.posts[value],
                        canEdit: false);
                  },
                ),
              ),
            ),
            body: VideoFrame(
              child: child,
              post: widget.posts[value],
              onFrameToggle: (shown) => toggleFrame(shown: shown),
            ),
          );
        },
        child: picture,
      );
    }

    Widget video(Post post) {
      return ValueListenableBuilder(
        valueListenable: post.controller,
        builder: (context, value, child) => Stack(
          alignment: Alignment.center,
          children: [
            crossFade(
              showChild: post.controller.value.initialized,
              child: AspectRatio(
                aspectRatio: post.controller.value.aspectRatio,
                child: VideoPlayer(post.controller),
              ),
              secondChild: CachedNetworkImage(
                imageUrl: post.image.value.sample['url'],
                placeholder: (context, url) => Center(
                    child: Container(
                  height: 26,
                  width: 26,
                  child: const CircularProgressIndicator(),
                )),
                errorWidget: (context, url, error) =>
                    Center(child: Icon(Icons.error_outline)),
              ),
            ),
          ],
        ),
      );
    }

    Widget gallery() {
      return PageView.builder(
        itemCount: widget.posts.length,
        controller: PageController(initialPage: widget.index),
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return PostOverlay(
              post: widget.posts[index],
              builder: (post) {
                switch (widget.posts[index].type) {
                  case ImageType.Image:
                    return FullscreenImage(post);
                  case ImageType.Video:
                    return Hero(
                      tag: 'image_${widget.posts[index].id}',
                      child: video(post),
                    );
                  case ImageType.Unsupported:
                  default:
                    return Container();
                }
              });
        },
        onPageChanged: (index) {
          int reach = 2;
          for (int i = -(reach + 1); i < reach; i++) {
            int target = index + 1 + i;
            if (0 < target && target < widget.posts.length) {
              String url = widget.posts[target].image.value.file['url'];
              if (url != null) {
                precacheImage(
                  CachedNetworkImageProvider(url),
                  context,
                );
              }
            }
          }
          if (widget.controller != null) {
            widget.controller.jumpToPage(index);
          }
          current.value = index;
        },
      );
    }

    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        return true;
      },
      child: frame(gallery()),
    );
  }
}

class FullscreenImage extends StatefulWidget {
  final Post post;

  const FullscreenImage(this.post);

  @override
  _FullscreenImageState createState() => _FullscreenImageState();
}

class _FullscreenImageState extends State<FullscreenImage> {
  LoadingState loadingState = LoadingState.none;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: loadingState == LoadingState.none ? 1 : 0,
          child: Container(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(),
          ),
        ),
        PhotoViewGestureDetectorScope(
            axis: Axis.horizontal,
            child: PhotoView.customChild(
              heroAttributes:
                  PhotoViewHeroAttributes(tag: 'image_${widget.post.id}'),
              backgroundDecoration: BoxDecoration(
                color: Colors.transparent,
              ),
              childSize: () {
                double width;
                double height;
                PostImage image = widget.post.image.value;
                switch (loadingState) {
                  case LoadingState.none:
                  // this is unecessary, because no image is shown
                  // disabled to prevent possible size flickering
                  /*
                    width = MediaQuery.of(context).size.width;
                    height = MediaQuery.of(context).size.height;
                    break;
                    */
                  case LoadingState.sample:
                    width = image.sample['width'].toDouble();
                    height = image.sample['height'].toDouble();
                    break;
                  case LoadingState.full:
                    width = image.file['width'].toDouble();
                    height = image.file['height'].toDouble();
                    break;
                }
                return Size(width, height);
              }(),
              child: CachedNetworkImage(
                fadeInDuration: Duration(milliseconds: 0),
                fadeOutDuration: Duration(milliseconds: 0),
                imageUrl: widget.post.image.value.file['url'],
                imageBuilder: (context, provider) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      loadingState = LoadingState.full;
                    });
                  });
                  return Image(image: provider);
                },
                placeholder: (context, chunk) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.post.image.value.sample['url'],
                        imageBuilder: (context, provider) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              if (loadingState == LoadingState.none) {
                                loadingState = LoadingState.sample;
                              }
                            });
                          });
                          return Image(image: provider);
                        },
                        errorWidget: (context, url, error) =>
                            Center(child: Icon(Icons.error_outline)),
                      ),
                      Positioned(
                        child: crossFade(
                          child: LinearProgressIndicator(
                            minHeight: widget.post.image.value.sample['height']
                                    .toDouble() /
                                100,
                            backgroundColor: Colors.transparent,
                          ),
                          showChild: loadingState == LoadingState.sample,
                        ),
                        bottom: 0,
                        right: 0,
                        left: 0,
                      ),
                    ],
                  );
                },
                errorWidget: (context, url, error) =>
                    Center(child: Icon(Icons.error_outline)),
              ),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 6,
            )),
      ],
    );
  }
}

class VideoFrame extends StatefulWidget {
  final Post post;
  final Widget child;
  final bool showFrame;
  final Function(bool shown) onFrameToggle;

  const VideoFrame(
      {@required this.child,
      @required this.post,
      this.onFrameToggle,
      this.showFrame});

  @override
  _VideoFrameState createState() => _VideoFrameState();
}

class _VideoFrameState extends State<VideoFrame> {
  ValueNotifier<bool> showFrame = ValueNotifier(false);
  Timer frameToggler;

  void toggleFrame({bool shown}) {
    frameToggler?.cancel();
    showFrame.value = shown ?? !showFrame.value;
    widget.onFrameToggle?.call(shown);
  }

  @override
  void didUpdateWidget(VideoFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    frameToggler?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    frameToggler?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Widget bottomBar() {
      return ValueListenableBuilder(
        valueListenable: showFrame,
        builder: (context, value, child) => crossFade(
          duration: Duration(milliseconds: 200),
          showChild: value,
          child: child,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ValueListenableBuilder(
            valueListenable: widget.post.controller,
            builder: (context, controller, child) {
              if (controller.initialized) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(controller.position.toString().substring(2, 7)),
                      Flexible(
                          child: Slider(
                        min: 0,
                        max: controller.duration.inMilliseconds.toDouble(),
                        value: controller.position.inMilliseconds.toDouble(),
                        onChangeStart: (double value) {
                          frameToggler?.cancel();
                        },
                        onChanged: (double value) {
                          widget.post.controller
                              .seekTo(Duration(milliseconds: value.toInt()));
                        },
                        onChangeEnd: (double value) {
                          if (widget.post.controller.value.isPlaying) {
                            frameToggler = Timer(Duration(seconds: 2), () {
                              toggleFrame(shown: false);
                            });
                          }
                        },
                      )),
                      Text(controller.duration.toString().substring(2, 7)),
                      InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.fullscreen_exit,
                            size: 24,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        onTap: Navigator.of(context).maybePop,
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          )
        ]),
      );
    }

    Widget playButton() {
      return ValueListenableBuilder(
          valueListenable: widget.post.controller,
          builder: (context, controller, child) {
            return ValueListenableBuilder(
              valueListenable: showFrame,
              builder: (context, value, child) {
                return AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity:
                      value || !widget.post.controller.value.isPlaying ? 1 : 0,
                  child: value || !widget.post.controller.value.isPlaying
                      ? child
                      : IgnorePointer(child: child),
                );
              },
              child: InkWell(
                onTap: () {
                  frameToggler?.cancel();
                  if (controller.isPlaying) {
                    widget.post.controller.pause();
                  } else {
                    widget.post.controller.play();
                    frameToggler = Timer(Duration(milliseconds: 500), () {
                      toggleFrame(shown: false);
                    });
                  }
                },
                child: crossFade(
                  duration: Duration(milliseconds: 100),
                  showChild: controller.isPlaying,
                  child: crossFade(
                    duration: Duration(milliseconds: 100),
                    showChild:
                        controller.initialized && !controller.isBuffering,
                    child: IconShadowWidget(
                      Icon(
                        Icons.pause,
                        size: 54,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      shadowColor: Colors.black,
                    ),
                    secondChild: Container(
                      height: 54,
                      width: 54,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  secondChild: IconShadowWidget(
                    Icon(
                      Icons.play_arrow,
                      size: 54,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    shadowColor: Colors.black,
                  ),
                ),
              ),
            );
          });
    }

    List<Widget> children = [widget.child];
    if (widget.post.type == ImageType.Video) {
      children.addAll([
        Positioned(bottom: 0, right: 0, left: 0, child: bottomBar()),
        playButton(),
      ]);
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        toggleFrame();
        if ((widget.post.controller?.value?.isPlaying ?? false) &&
            showFrame.value) {
          frameToggler =
              Timer(Duration(seconds: 2), () => toggleFrame(shown: false));
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: children,
      ),
    );
  }
}

class PostOverlay extends StatelessWidget {
  final Post post;
  final Widget Function(Post post) builder;

  const PostOverlay({@required this.post, @required this.builder});

  @override
  Widget build(BuildContext context) {
    Widget centerText(String text) {
      return Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (post.isDeleted) {
      return centerText('Post was deleted');
    }
    if (!post.isVisible) {
      return centerText('Post is blacklisted');
    }
    if (post.image.value.file['url'] == null) {
      return centerText('Image unavailable in safe mode');
    }
    if (post.type == ImageType.Unsupported) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  '${post.image.value.file['ext']} files are not supported',
                  textAlign: TextAlign.center,
                ),
              ),
              Card(
                child: InkWell(
                  child:
                      Padding(padding: EdgeInsets.all(8), child: Text('Open')),
                  onTap: () async => url.launch(post.image.value.file['url']),
                ),
              )
            ],
          )
        ],
      );
    }
    return builder(post);
  }
}

Widget postAppBar(BuildContext context, Post post, {bool canEdit = true}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(kToolbarHeight),
    child: Hero(
      tag: 'appbar',
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: IconShadowWidget(
            Icon(
              post.isEditing.value && canEdit ? Icons.clear : Icons.arrow_back,
              color: Theme.of(context).iconTheme.color,
            ),
            shadowColor: Colors.black,
          ),
          onPressed: Navigator.of(context).maybePop,
        ),
        actions: post.isEditing.value
            ? null
            : <Widget>[
                Builder(
                  builder: (context) {
                    return PopupMenuButton<String>(
                      icon: IconShadowWidget(
                        Icon(
                          Icons.more_vert,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        shadowColor: Colors.black,
                      ),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          value: 'share',
                          child: popMenuListTile('Share', Icons.share),
                        ),
                        post.image.value.file['url'] != null
                            ? PopupMenuItem(
                                value: 'download',
                                child: popMenuListTile(
                                    'Download', Icons.file_download),
                              )
                            : null,
                        PopupMenuItem(
                          value: 'browse',
                          child:
                              popMenuListTile('Browse', Icons.open_in_browser),
                        ),
                        post.isLoggedIn && canEdit
                            ? PopupMenuItem(
                                value: 'edit',
                                child: popMenuListTile('Edit', Icons.edit),
                              )
                            : null,
                        post.isLoggedIn
                            ? PopupMenuItem(
                                value: 'comment',
                                child:
                                    popMenuListTile('Comment', Icons.comment),
                              )
                            : null,
                      ],
                      onSelected: (value) async {
                        switch (value) {
                          case 'share':
                            Share.share(
                                post.url(await db.host.value).toString());
                            break;
                          case 'download':
                            String message;
                            if (await downloadDialog(context, post)) {
                              message = 'Saved image #${post.id} to gallery';
                            } else {
                              message = 'Failed to download post ${post.id}';
                            }
                            Scaffold.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 1),
                              content: Text(message),
                            ));
                            break;
                          case 'browse':
                            url.launch(
                                post.url(await db.host.value).toString());
                            break;
                          case 'edit':
                            post.isEditing.value = true;
                            break;
                          case 'comment':
                            if (await sendComment(context, post)) {
                              post.comments.value++;
                            }
                            break;
                        }
                      },
                    );
                  },
                ),
              ],
      ),
    ),
  );
}

Future<bool> download(Post post) async {
  String filename =
      '${post.artists.join(', ')} - ${post.id}.${post.image.value.file['ext']}';
  File file =
      await DefaultCacheManager().getSingleFile(post.image.value.file['url']);
  try {
    await CopyToGallery.copyNamedPictures(appName, {file.path: filename});
    return true;
  } catch (Exception) {
    return false;
  }
}

Future<bool> downloadDialog(BuildContext context, Post post) async {
  bool success = false;
  if (!await Permission.storage.request().isGranted) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
                'You need to grant write permission in order to download files.'),
            actions: [
              RaisedButton(
                child: Text('TRY AGAIN'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  success = await downloadDialog(
                      context, post); // recursively re-execute
                },
              ),
            ],
          );
        });
    return success;
  }

  return await download(post);
}

Widget loadingListTile(
    {Widget leading, Widget title, Widget trailing, Function onTap}) {
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  return ValueListenableBuilder(
    valueListenable: isLoading,
    builder: (BuildContext context, value, Widget child) {
      return ListTile(
        leading: leading,
        title: title,
        trailing: crossFade(
          child: Container(
            child: Padding(
              padding: EdgeInsets.all(2),
              child: CircularProgressIndicator(),
            ),
            height: 20,
            width: 20,
          ),
          secondChild: trailing ?? Icon(Icons.arrow_right),
          showChild: isLoading.value,
        ),
        onTap: () async {
          if (!isLoading.value) {
            isLoading.value = true;
            await onTap();
            isLoading.value = false;
          }
        },
      );
    },
  );
}

String formatBytes(int bytes, int decimals) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
}

enum VoteStatus {
  upvoted,
  unknown,
  downvoted,
}

Map<String, String> ratings = {
  's': 'Safe',
  'q': 'Questionable',
  'e': 'Explicit',
};

Future<bool> tryRemoveFav(BuildContext context, Post post) async {
  if (await client.removeFavorite(post.id)) {
    post.isFavorite.value = false;
    post.favorites.value -= 1;
    return true;
  } else {
    post.isFavorite.value = true;
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text('Failed to remove Post #${post.id} from favorites'),
    ));
    return false;
  }
}

Future<bool> tryAddFav(BuildContext context, Post post) async {
  Future<void> cooldown = Future.delayed(const Duration(milliseconds: 1000));
  if (await client.addFavorite(post.id)) {
    () async {
      // cooldown ensures no interference with like animation
      await cooldown;
      post.isFavorite.value = true;
    }();
    post.favorites.value += 1;
    return true;
  } else {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text('Failed to add Post #${post.id} to favorites'),
    ));
    return false;
  }
}

Future<void> tryVote(
    BuildContext context, Post post, bool upvote, bool replace) async {
  if (await client.votePost(post.id, upvote, replace)) {
    if (post.voteStatus.value == VoteStatus.unknown) {
      if (upvote) {
        post.score.value += 1;
        post.voteStatus.value = VoteStatus.upvoted;
      } else {
        post.score.value -= 1;
        post.voteStatus.value = VoteStatus.downvoted;
      }
    } else {
      if (upvote) {
        if (post.voteStatus.value == VoteStatus.upvoted) {
          post.score.value -= 1;
          post.voteStatus.value = VoteStatus.unknown;
        } else {
          post.score.value += 2;
          post.voteStatus.value = VoteStatus.upvoted;
        }
      } else {
        if (post.voteStatus.value == VoteStatus.upvoted) {
          post.score.value -= 2;
          post.voteStatus.value = VoteStatus.downvoted;
        } else {
          post.score.value += 1;
          post.voteStatus.value = VoteStatus.unknown;
        }
      }
    }
  } else {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text('Failed to vote on Post #${post.id}'),
    ));
  }
}

Future<void> resetPost(Post post, {bool online = false}) async {
  Post reset;
  if (!online) {
    reset = Post.fromRaw(post.raw);
  } else {
    reset = await client.post(post.id);
    post.raw = reset.raw;
  }

  post.favorites.value = reset.favorites.value;
  post.score.value = reset.score.value;
  post.tags.value = reset.tags.value;
  post.description.value = reset.description.value;
  post.sources.value = reset.sources.value;
  post.rating.value = reset.rating.value;
  post.parent.value = reset.parent.value;
  post.isEditing.value = false;
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'general':
      return Colors.indigo[300];
    case 'species':
      return Colors.teal[300];
    case 'character':
      return Colors.lightGreen[300];
    case 'copyright':
      return Colors.yellow[300];
    case 'meta':
      return Colors.deepOrange[300];
    case 'lore':
      return Colors.pink[300];
    case 'artist':
      return Colors.deepPurple[300];
    default:
      return Colors.grey[300];
  }
}

Map<String, int> categories = {
  'general': 0,
  'species': 5,
  'character': 4,
  'copyright': 3,
  'meta': 7,
  'lore': 8,
  'artist': 1,
  'invalid': 6,
};

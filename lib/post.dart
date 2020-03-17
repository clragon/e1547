import 'dart:async' show Future;
import 'dart:io' show File, Platform;
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage, CachedNetworkImageProvider;
import 'package:esys_flutter_share/esys_flutter_share.dart' show Share;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, SystemChrome, SystemUiOverlay;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    show DefaultCacheManager;
import 'package:like_button/like_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart' as url;

import 'client.dart' show client;
import 'comment.dart' show CommentsWidget;
import 'persistence.dart' show db;

class Post {
  Map raw;

  int id;
  int score;
  int favCount;
  String uploader;

  Map file;
  Map preview;
  Map sample;

  String rating;
  List<String> artist;
  bool hasComments;

  bool isFavourite;
  bool isLoggedIn;

  bool isConditionalDnp;
  bool hasSoundWarning;
  bool hasEpilepsyWarning;

  Post.fromRaw(this.raw) {
    id = raw['id'] as int;
    favCount = raw['fav_count'] as int;
    isFavourite = raw['is_favorited'] as bool;

    rating = (raw['rating'] as String).toUpperCase();
    hasComments = (raw['comment_count'] as int == 0);

    artist = [];
    for (String s in raw['tags']['artist'].cast<String>()) {
      if (s == 'conditional_dnp') {
        isConditionalDnp = true;
      } else if (s == 'sound_warning') {
        hasSoundWarning = true;
      } else if (s == 'epilepsy_warning') {
        hasEpilepsyWarning = true;
      } else {
        artist.add(s);
      }
    }

    score = raw['score']['total'] as int;
    uploader = (raw['uploader_id'] as int).toString();

    file = raw['file'] as Map;
    preview = raw['preview'] as Map;
    sample = raw['sample'] as Map;
  }

  // build post URL
  Uri url(String host) =>
      new Uri(scheme: 'https', host: host, path: '/posts/$id');
}

class PostPreview extends StatelessWidget {
  final Post post;
  final VoidCallback onPressed;

  const PostPreview(
    this.post, {
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    Widget imagePreviewWidget() {
      return new CachedNetworkImage(
        imageUrl: post.sample['url'],
        errorWidget: (context, url, error) => const Icon(Icons.error),
        fit: BoxFit.cover,
      );
    }

    return new GestureDetector(
        onTap: onPressed,
        child: () {
          Widget image = new Card(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                new Expanded(
                    child: Container(
                  alignment:
                      (post.file['ext'] == 'gif') ? Alignment.center : null,
                  child: imagePreviewWidget(),
                )),
                // postInfoWidget(),
              ],
            ),
          );

          // TODO: maybe remove this?
          Widget specialOverlayIcon;
          if (post.file['ext'] == 'gif') {
            specialOverlayIcon = new Positioned(
                top: 4,
                right: 4,
                child: new Container(
                  padding: EdgeInsets.zero,
                  color: Colors.black38,
                  child: const Icon(Icons.gif),
                ));
          }

          return new Stack(
            children: <Widget>[
              image,
              () {
                return specialOverlayIcon ?? new Container();
              }(),
            ],
          );
        }());
  }
}

// this thing allows swiping through posts
// TODO: make this load new posts when there aren't any left.
class PostSwipe extends StatelessWidget {
  final List<Post> posts;
  final int startingIndex;

  const PostSwipe(this.posts, {Key key, this.startingIndex = 0})
      : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return new PageView.builder(
      controller: new PageController(initialPage: startingIndex),
      itemBuilder: _pageBuilder,
    );
  }

  Widget _pageBuilder(BuildContext ctx, int index) {
    return index < posts.length ? new PostWidget(posts[index]) : null;
  }
}

// Preview of a post that appears in lists of posts. Mostly just the image.
class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget(this.post, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(body: new PostWidgetScaffold(post));
  }
}

class PostWidgetScaffold extends StatelessWidget {
  final Post post;

  const PostWidgetScaffold(this.post, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    Widget postContentsWidget() {
      Widget overlayImageWidget() {
        Widget imageWidget() {
          return post.file['ext'] == 'swf' || post.file['ext'] == 'webm'
              ? new Container(
                  child: Center(
                      child: const Text(
                  'Webm support under development. \nTap to open in browser.',
                  textAlign: TextAlign.center,
                )))
              : new CachedNetworkImage(
                  imageUrl: post.sample['url'],
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                );
        }

        Widget fullscreenButtonWidget() {
          return new Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.black38,
            child: const Icon(Icons.fullscreen),
          );
        }

        return new Stack(children: [
          new Center(child: imageWidget()),
          new Positioned(
            right: 0.0,
            bottom: 0.0,
            child: fullscreenButtonWidget(),
          ),
        ]);
      }

      return new Flexible(
          child: new GestureDetector(
        onTap: _onTapImage(ctx, post),
        child: new Container(
          color: Colors.black,
          constraints: const BoxConstraints.expand(),
          child: overlayImageWidget(),
        ),
      ));
    }

    Widget postMetadataWidget() {
      Widget metadataRow() {
        Color secondary = Colors.white.withOpacity(0.6);
        TextStyle secondaryTextStyle = new TextStyle(color: secondary);

        return new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new Text(post.artist.join(',\n')),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                new Text('#${post.id}', style: secondaryTextStyle),
                new Row(children: [
                  new Icon(Icons.person, size: 14.0, color: secondary),
                  new Text(' ${post.uploader}', style: secondaryTextStyle),
                ]),
              ],
            ),
          ],
        );
      }

      return new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: metadataRow(),
      );
    }

    Future<void> tryRemoveFav(BuildContext ctx, Post post) async {
      if (await client.removeAsFavorite(post.id)) {
        post.isFavourite = false;
      } else {
        Scaffold.of(ctx).showSnackBar(new SnackBar(
          duration: const Duration(seconds: 1),
          content: new Text('Failed to remove post ${post.id} from favorites'),
        ));
      }
    }

    Future<void> tryAddFav(BuildContext ctx, Post post) async {
      if (await client.addAsFavorite(post.id)) {
        post.isFavourite = true;
      } else {
        Scaffold.of(ctx).showSnackBar(new SnackBar(
          duration: const Duration(seconds: 1),
          content: new Text('Failed to add post ${post.id} to favorites'),
        ));
      }
    }

    Widget buttonBarWidget() {
      Widget favButton() {
        return LikeButton(
          isLiked: post.isFavourite,
          likeBuilder: (bool isLiked) {
            return Icon(
              Icons.favorite,
              color:
                  isLiked ? Colors.pinkAccent : Theme.of(ctx).iconTheme.color,
            );
          },
          onTap: (isLiked) async {
            if (isLiked) {
              tryRemoveFav(ctx, post);
              return false;
            } else {
              tryAddFav(ctx, post);
              return true;
            }
          },
        );
      }

      Widget commentsButton() {
        return new IconButton(
          icon: const Icon(Icons.chat),
          tooltip: 'Go to comments',
          onPressed: () => Navigator.of(ctx)
              .push(new MaterialPageRoute<Null>(builder: (ctx) {
            return new CommentsWidget(post);
          })),
        );
      }

      Widget openInBrowserButton() {
        return new IconButton(
          icon: const Icon(Icons.open_in_browser),
          tooltip: 'View post in browser',
          onPressed: () async {
            url.launch(post.url(await db.host.value).toString());
          },
        );
      }

      Widget overflowButton() {
        return new IconButton(
          icon: const Icon(Icons.more_horiz),
          tooltip: 'More actions',
          onPressed: () => showDialog(
              context: ctx,
              builder: (ctx) {
                return new _MoreDialog(post);
              }),
        );
      }

      return new ButtonBarTheme(
        child: new ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          children: () {
            List<Widget> buttons = new List<Widget>();
            if (post.isLoggedIn) {
              buttons.add(favButton());
              // API for comments is broken.
              // commentsButton(),
            }
            buttons.addAll([
              openInBrowserButton(),
              overflowButton(),
            ]);
            return buttons;
          }(),
        ),
        data: const ButtonBarThemeData(),
      );
    }

    return new Padding(
      padding: new EdgeInsets.only(top: MediaQuery.of(ctx).padding.top),
      child: new Column(mainAxisSize: MainAxisSize.min, children: [
        postContentsWidget(),
        postMetadataWidget(),
        const Divider(height: 8.0),
        buttonBarWidget(),
      ]),
    );
  }

  Function() _onTapImage(BuildContext ctx, Post post) {
    Widget fullScreenWidgetBuilder(BuildContext ctx) {
      return PhotoView(
        imageProvider: new CachedNetworkImageProvider(post.file['url']),
        loadingBuilder: (buildContext, imageChunkEvent) =>
            new Stack(alignment: Alignment.center, children: [
          new CachedNetworkImage(
            imageUrl: post.sample['url'],
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          new Container(
            alignment: Alignment.topCenter,
            child: const LinearProgressIndicator(),
          ),
        ]),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 6,
        onTapUp: (buildContext, tapDownDetails, photoViewControllerValue) =>
            Navigator.of(ctx).pop(),
      );
    }

    return () async {
      if (post.file['ext'] == 'webm' || post.file['ext'] == 'swf') {
        url.launch(post.file['url']);
      } else {
        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
        await Navigator.of(ctx).push(new MaterialPageRoute<Null>(
          builder: fullScreenWidgetBuilder,
        ));
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      }
    };
  }
}

class _MoreDialog extends StatelessWidget {
  final Post post;

  const _MoreDialog(this.post);

  @override
  Widget build(BuildContext ctx) {
    List<Widget> optionsWidgets() {
      List<Widget> options = [
        new ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Info'),
          onTap: _showPostInfoDialog(ctx),
        ),
        new ListTile(
          leading: const Icon(Icons.content_copy),
          title: const Text('Copy...'),
          trailing: const Icon(Icons.arrow_right),
          onTap: _showCopyDialog(ctx),
        ),
      ];

      if (Platform.isAndroid) {
        options.add(new ListTile(
          leading: const Icon(Icons.file_download),
          title: const Text('Download'),
          onTap: _download(ctx),
        ));
      }

      return options;
    }

    return new SimpleDialog(
      title: new Text('post #${post.id}'),
      children: optionsWidgets(),
    );
  }

  Future<Null> _copyAndPopPop(BuildContext ctx, String text) async {
    await Clipboard.setData(new ClipboardData(text: text));
    Navigator.of(ctx).pop();
    Navigator.of(ctx).pop();
  }

  Function() _download(BuildContext ctx) {
    return () async {
      // TODO: this doesn't work.
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);

      if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
        showDialog(
            context: ctx,
            builder: (ctx) {
              return new AlertDialog(
                content: const Text(
                    'You need to grant write permission in order to download files.'),
                actions: [
                  new RaisedButton(
                    child: const Text('TRY AGAIN'),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      _download(ctx)(); // recursively re-execute
                    },
                  ),
                ],
              );
            });
        return;
      }

      String filename =
          post.artist.join(', ') + ' ~ ${post.id}.' + post.file['ext'];
      String filepath =
          Platform.environment['EXTERNAL_STORAGE'] + '/Download/' + filename;

      Future<File> download() async {
        File file = new File(filepath);
        if (file.existsSync()) {
          return file;
        }

        DefaultCacheManager cm = DefaultCacheManager();
        return (await cm.getSingleFile(post.file['url'])).copySync(filepath);
      }

      showDialog(
        context: ctx,
        builder: (ctx) {
          return new FutureBuilder(
            future: download(),
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                return new AlertDialog(
                  title: const Text('Error'),
                  content: new Text(snapshot.error.toString()),
                );
              }

              bool done = snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData;

              return new AlertDialog(
                title: const Text('Download'),
                content: new Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    new Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: done
                          ? const Icon(Icons.done)
                          : const CircularProgressIndicator(),
                    ),
                    new Text(filename, softWrap: true),
                  ],
                ),
                actions: [
                  new RaisedButton(
                    child: const Text('SHARE'),
                    onPressed: () async {
                      ByteData bytes = await rootBundle.load(filepath);
                      Share.file(filename, filename, bytes.buffer.asUint8List(),
                          'image/*');
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    };
  }

  Function() _showCopyDialog(BuildContext ctx) {
    return () {
      Widget title = new ListTile(
          leading: const Icon(Icons.content_copy),
          title: new Text('Copy from post #${post.id}'));

      Widget copyLink = new ListTile(
          title: const Text('Copy link'),
          onTap: () async {
            String link = post.url(await db.host.value).toString();
            _copyAndPopPop(ctx, link);
          });

      Widget copyDirectLink = new ListTile(
          title: const Text('Copy direct link'),
          onTap: () => _copyAndPopPop(ctx, post.file['url']));

      showDialog(
          context: ctx,
          builder: (ctx) {
            return new SimpleDialog(
                title: title, children: [copyLink, copyDirectLink]);
          });
    };
  }

  Function() _showPostInfoDialog(BuildContext ctx) {
    return () {
      StringBuffer info = new StringBuffer();
      post.raw.forEach((k, v) {
        info.write('$k: $v\n\n');
      });

      showDialog(
          context: ctx,
          builder: (ctx) {
            return new SimpleDialog(
                title: new Text('post #${post.id} info'),
                children: <Widget>[
                  new TextField(
                      maxLines: 15,
                      decoration: const InputDecoration(border: null),
                      style: const TextStyle(fontFamily: 'Courier'),
                      controller:
                          new TextEditingController(text: info.toString()))
                ]);
          });
    };
  }
}

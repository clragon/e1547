// e1547: A mobile app for browsing e926.net and friends.
// Copyright (C) 2017 perlatus <perlatus@e1547.email.vczf.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import 'dart:async' show Future;
import 'dart:io' show File, Platform;
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage, CachedNetworkImageProvider;
import 'package:esys_flutter_share/esys_flutter_share.dart' show Share;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show TextOverflow;
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
  String author;
  int score;
  int favCount;
  String fileUrl;
  String fileExt;
  String previewUrl;
  int previewWidth;
  int previewHeight;
  String sampleUrl;
  int sampleWidth;
  int sampleHeight;
  String rating;
  bool hasComments;
  List<String> artist;

  bool isConditionalDnp;
  bool hasSoundWarning;
  bool hasEpilepsyWarning;

  bool isFavourite = false;

  Post.fromRaw(this.raw) {
    id = raw['id'] as int;
    author = raw['author'] as String;
    score = raw['score'] as int;
    favCount = raw['fav_count'] as int;
    fileUrl = raw['file_url'] as String;
    fileExt = raw['file_ext'] as String;
    previewUrl = raw['preview_url'] as String;
    previewWidth = raw['preview_width'] as int;
    previewHeight = raw['preview_height'] as int;
    sampleUrl = raw['sample_url'] as String;
    sampleWidth = raw['sample_width'] as int;
    sampleHeight = raw['sample_height'] as int;

    rating = (raw['rating'] as String).toUpperCase();

    hasComments = raw['has_comments'] as bool;

    artist = [];
    for (var a in raw['artist']) {
      String aStr = a.toString();
      if (a == 'conditional_dnp') {
        isConditionalDnp = true;
      } else if (a == 'sound_warning') {
        hasSoundWarning = true;
      } else if (a == 'epilepsy_warning') {
        hasEpilepsyWarning = true;
      } else {
        artist.add(aStr);
      }
    }

  }

  // Get the URL for the HTML version of the desired post.
  Uri url(String host) =>
      new Uri(scheme: 'https', host: host, path: '/post/show/$id');
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
      Widget image = new Container(
        color: Colors.grey[800],
        constraints: const BoxConstraints.expand(),
        child: new Center(
          child: new CachedNetworkImage(
            imageUrl: post.previewUrl,
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.contain,
          ),
        ),
      );

      Widget specialOverlayIcon;
      if (post.fileExt == 'gif') {
        specialOverlayIcon = new Container(
          padding: EdgeInsets.zero,
          color: Colors.black38,
          child: const Icon(Icons.gif),
        );
      }

      return specialOverlayIcon == null
          ? image
          : new Stack(children: [
              image,
              new Positioned(top: 0.0, right: 0.0, child: specialOverlayIcon),
            ]);
    }

    Widget postInfoWidget() {
      Widget infoSquare() {
        // This builds a small icon followed by some text.
        Widget iconTextPair(IconData icon, String text) {
          return new Row(mainAxisSize: MainAxisSize.min, children: [
            new Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: IconTheme.merge(
                  data: const IconThemeData(size: 12.0),
                  child: new Icon(icon),
                )),
            new Text(text, style: const TextStyle(fontSize: 12.0)),
          ]);
        }

        Widget padTopLeft(Widget child) {
          return new Padding(
            child: child,
            padding: const EdgeInsets.only(right: 1.0, bottom: 1.5),
          );
        }

        Widget padTopRight(Widget child) {
          return new Padding(
            child: child,
            padding: const EdgeInsets.only(left: 1.0, bottom: 1.5),
          );
        }

        Widget padBottomLeft(Widget child) {
          return new Padding(
            child: child,
            padding: const EdgeInsets.only(right: 1.0, top: 1.5),
          );
        }

        Widget padBottomRight(Widget child) {
          return new Padding(
            child: child,
            padding: const EdgeInsets.only(left: 1.0, top: 1.5),
          );
        }

        Widget scoreInfo() {
          return post.score >= 0
              ? iconTextPair(Icons.arrow_upward, '+' + post.score.toString())
              : iconTextPair(Icons.arrow_downward, post.score.toString());
        }

        Widget commentsInfo() {
          return iconTextPair(
              Icons.question_answer, post.hasComments ? '+' : '0');
        }

        Widget favoritesInfo() {
          return iconTextPair(Icons.favorite, post.favCount.toString());
        }

        Widget ratingInfo() {
          return iconTextPair(Icons.warning, post.rating);
        }

        return new Table(
          // IntrinsicColumnWidth is expensive but also the only one that
          // seems to work.
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: <TableRow>[
            new TableRow(children: [
              padTopLeft(scoreInfo()),
              padTopRight(commentsInfo()),
            ]),
            new TableRow(children: [
              padBottomLeft(favoritesInfo()),
              padBottomRight(ratingInfo()),
            ]),
          ],
        );
      }

      Widget artists() {
        return new Text(
          post.artist.length < 2
              ? post.artist.join(',\n')
              : post.artist.take(2).join(',\n') +
                  ',\n... +${post.artist.length - 1}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12.0),
          maxLines: 3,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        );
      }

      return new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Column(children: [
          infoSquare(),
          new Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: artists(),
          ),
        ]),
      );
    }

    return new GestureDetector(
      onTap: onPressed,
      child: new Card(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            new Flexible(child: imagePreviewWidget()),
            postInfoWidget(),
          ],
        ),
      ),
    );
  }
}

// Main widget for presenting and interacting with individual posts.
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
      Widget overlayedImageWidget() {
        Widget imageWidget() {
          return post.fileExt == 'swf' || post.fileExt == 'webm'
              ? new Container()
              : new CachedNetworkImage(
                  imageUrl: post.sampleUrl,
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
          child: overlayedImageWidget(),
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
                  new Text(' ${post.author}', style: secondaryTextStyle),
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
        client.favourites.remove(post.id);
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
        client.favourites.add(post.id);
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
                  isLiked ? Colors.pinkAccent : Colors.white.withOpacity(0.6),
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
          children: <Widget>[
            favButton(),
            commentsButton(),
            openInBrowserButton(),
            overflowButton(),
          ],
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
        imageProvider: new CachedNetworkImageProvider(post.fileUrl),
        loadingBuilder: (buildContext, imageChunkEvent) =>
            new Stack(alignment: Alignment.center, children: [
          new CachedNetworkImage(
            imageUrl: post.sampleUrl,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          new Container(
            alignment: Alignment.topCenter,
            child: const LinearProgressIndicator(),
          ),
        ]),
        onTapDown: (buildContext, tapDownDetails, photoViewControllerValue) =>
            Navigator.of(ctx).pop(),
      );
    }

    return () async {
      if (post.fileExt == 'webm' || post.fileExt == 'swf') {
        url.launch(post.fileUrl);
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
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);

      bool hasWritePerm = false;

      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        hasWritePerm = true;
      }

      if (!hasWritePerm) {
        showDialog(
            context: ctx,
            builder: (ctx) {
              return new AlertDialog(
                content: const Text('Sorry, but you need to grant write '
                    'permission in order to download files.'),
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
          post.artist.join(', ') + ' ~ ${post.id}.' + post.fileExt;
      String filepath =
          Platform.environment['EXTERNAL_STORAGE'] + '/Download/' + filename;

      Future<File> download() async {
        File file = new File(filepath);
        if (file.existsSync()) {
          return file;
        }

        DefaultCacheManager cm = DefaultCacheManager();
        return (await cm.getSingleFile(post.fileUrl)).copySync(filepath);
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
          onTap: () => _copyAndPopPop(ctx, post.fileUrl));

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

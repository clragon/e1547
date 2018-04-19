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

import 'package:flutter/foundation.dart' show AsyncValueGetter;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show TextOverflow;
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, SystemChrome, SystemUiOverlay;

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:url_launcher/url_launcher.dart' as url;
import 'package:zoomable_image/zoomable_image.dart' show ZoomableImage;

import 'client.dart' show client;
import 'comment.dart' show CommentsWidget;
import 'persistence.dart' show db;

class Post {
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

  // Get the URL for the HTML version of the desired post.
  Uri url(String host) =>
      new Uri(scheme: 'https', host: host, path: '/post/show/$id');

  ImageProvider get fullImage => new NetworkImage(fileUrl);
  ImageProvider get previewImage => new NetworkImage(previewUrl);
  ImageProvider get sampleImage => new NetworkImage(sampleUrl);
}

class PostWidget extends StatelessWidget {
  final Post post;
  const PostWidget(this.post, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(body: new PostWidgetScaffold(post));
  }
}

// Main widget for presenting and interacting with individual posts.
class PostWidgetScaffold extends StatefulWidget {
  final Post post;
  const PostWidgetScaffold(this.post, {Key key}) : super(key: key);

  @override
  State createState() => new _PostWidgetScaffoldState();
}

class _PostWidgetScaffoldState extends State<PostWidgetScaffold> {
  static final Logger _log = new Logger('PostWidgetScaffold');

  Future<Null> _fullscreen(BuildContext ctx) async {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    await Navigator.of(ctx).push(new MaterialPageRoute<Null>(
      builder: (ctx) {
        return new ZoomableImage(
          widget.post.fullImage,
          scale: 16.0,
          onTap: () => Navigator.of(ctx).pop(),
        );
      },
    ));
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext ctx) {
    return new Padding(
        padding: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: new Column(mainAxisSize: MainAxisSize.min, children: [
          _buildPostContents(ctx),
          _buildPostMetadata(ctx),
          const Divider(height: 8.0),
          _buildButtonBar(ctx),
        ]));
  }

  Widget _buildPostContents(BuildContext ctx) {
    Widget fullscreenButton = new Container(
      padding: const EdgeInsets.all(12.0),
      color: Colors.black38,
      child: const Icon(Icons.fullscreen),
    );

    Widget image = widget.post.fileExt == 'swf' || widget.post.fileExt == 'webm'
        ? new Container()
        : new Image(image: widget.post.sampleImage);

    Widget content = new Stack(children: [
      new Center(child: image),
      new Positioned(
        right: 0.0,
        bottom: 0.0,
        child: fullscreenButton,
      ),
    ]);

    content = new Container(
      color: Colors.black,
      constraints: const BoxConstraints.expand(),
      child: content,
    );

    content = new GestureDetector(
      onTap: () {
        if (widget.post.fileExt == 'webm' || widget.post.fileExt == 'swf') {
          url.launch(widget.post.fileUrl);
        } else {
          _fullscreen(ctx);
        }
      },
      child: content,
    );

    return new Flexible(child: content);
  }

  Widget _buildPostMetadata(BuildContext ctx) {
    Color secondary = Colors.white.withOpacity(0.6);
    TextStyle secondaryTextStyle = new TextStyle(color: secondary);

    Widget metadata = new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        new Text(widget.post.artist.join(',\n')),
        new Column(children: [
          new Text('#${widget.post.id}', style: secondaryTextStyle),
          new Row(children: [
            new Icon(Icons.person, size: 14.0, color: secondary),
            new Text(' ${widget.post.author}', style: secondaryTextStyle),
          ]),
        ], crossAxisAlignment: CrossAxisAlignment.end),
      ],
    );

    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: metadata,
    );
  }

  Widget _buildButtonBar(BuildContext ctx) {
    return new ButtonTheme.bar(
        child: new ButtonBar(
      alignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        new IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Add post to favorites',
            onPressed: () async {
              String cmd = await showDialog<String>(
                  context: ctx,
                  builder: (ctx) {
                    return new SimpleDialog(
                      contentPadding: const EdgeInsets.all(10.0),
                      children: [
                        new SimpleDialogOption(
                          child: const Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0),
                              child: const Text('Add to favorites')),
                          onPressed: () => Navigator.of(ctx).pop('add'),
                        ),
                        new SimpleDialogOption(
                          child: const Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0),
                              child: const Text('Remove from favorites')),
                          onPressed: () => Navigator.of(ctx).pop('remove'),
                        ),
                      ],
                    );
                  }
              );

              if (cmd == null) {
                return;
              }

              String message;
              if (cmd == 'add') {
                message = await client.addAsFavorite(widget.post.id)
                    ? 'Added post ${widget.post.id} to favorites'
                    : 'Failed to add post ${widget.post.id} to favorites';
              } else if (cmd == 'remove') {
                message = await client.removeAsFavorite(widget.post.id)
                    ? 'Removed post ${widget.post.id} from favorites'
                    : 'Failed to remove post ${widget.post.id} from favorites';
              } else {
                message = 'Unknown error';
                _log.warning('Unknown command for favorites: "$cmd"');
              }

              Scaffold.of(ctx).showSnackBar(new SnackBar(
                    duration: const Duration(seconds: 5),
                    content: new Text(message),
                  ));
            }),
        new IconButton(
            icon: const Icon(Icons.chat),
            tooltip: 'Go to comments',
            onPressed: () {
              Navigator
                  .of(ctx)
                  .push(new MaterialPageRoute<Null>(builder: (ctx) {
                return new CommentsWidget(widget.post);
              }));
            }),
        new IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'View post in browser',
            onPressed: () async {
              url.launch(widget.post.url(await db.host.value).toString());
            }),
        new IconButton(
            icon: const Icon(Icons.more_horiz),
            tooltip: 'More actions',
            onPressed: () {
              showDialog(context: ctx, builder: (ctx) {
                return new _MoreDialog(widget.post);
              });
            }),
      ],
    ));
  }
}

// Preview of a post that appears in lists of posts. Mostly just the image.
class PostPreview extends StatelessWidget {
  static final Logger _log = new Logger('PostPreview');
  final Post post;
  final VoidCallback onPressed;
  const PostPreview(
    this.post, {
    Key key,
    this.onPressed,
  })
      : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    Widget imagePreviewWidget() {
      Widget image = new Container(
        color: Colors.grey[800],
        constraints: const BoxConstraints.expand(),
        child: new Image(image: post.previewImage, fit: BoxFit.contain),
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

class _MoreDialog extends StatelessWidget {
  final Post post;
  const _MoreDialog(this.post);

  @override
  Widget build(BuildContext ctx) {
    return new SimpleDialog(title: new Text('post #${post.id}'), children: [
      _buildPostInfo(ctx),
      _buildCopy(ctx),
    ]);
  }

  Widget _buildPostInfo(BuildContext ctx) {
    return new ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('Info'),
      onTap: () {
        StringBuffer info = new StringBuffer();
        post.raw.forEach((k, v) {
          info.write('$k: $v\n\n');
        });

        showDialog(context: ctx, builder: (ctx) {
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
      },
    );
  }

  Widget _buildCopy(BuildContext ctx) {
    return new ListTile(
      leading: const Icon(Icons.content_copy),
      title: const Text('Copy...'),
      trailing: const Icon(Icons.arrow_right),
      onTap: () => _showCopyDialog(ctx),
    );
  }

  void _showCopyDialog(BuildContext ctx) {
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

    showDialog(context: ctx, builder: (ctx) {
      return new SimpleDialog(title: title, children: [copyLink, copyDirectLink]);
    });
  }

  Future<Null> _copyAndPopPop(BuildContext ctx, String text) async {
    await Clipboard.setData(new ClipboardData(text: text));
    Navigator.of(ctx).pop();
    Navigator.of(ctx).pop();
  }
}

class PostGrid extends StatelessWidget {
  final List<Post> posts;
  const PostGrid(this.posts, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return new StaggeredGridView.extentBuilder(
        itemCount: posts.length,
        maxCrossAxisExtent: 200.0,
        itemBuilder: _itemBuilder,
        staggeredTileBuilder: (i) {
          return const StaggeredTile.extent(1, 250.0);
        },
    );
  }

  Widget _itemBuilder(BuildContext ctx, int i) {
    if (i >= posts.length) {
      return null;
    }

    return new PostPreview(posts[i], onPressed: () {
      Navigator.of(ctx).push(new MaterialPageRoute<Null>(
        builder: (ctx) => new PostSwipe(posts, startingIndex: i),
      ));
    });
  }
}

class PostSwipe extends StatelessWidget {
  final List<Post> posts;
  final int startingIndex;

  const PostSwipe(this.posts, {Key key, this.startingIndex = 0})
      : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return new PageView.builder(
        controller: new PageController(initialPage: startingIndex),
        itemBuilder: (ctx, i) {
          return i >= posts.length ? null : new PostWidget(posts[i]);
        });
  }
}

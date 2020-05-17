import 'dart:async' show Future;
import 'dart:collection';
import 'dart:io' show Directory, File, Platform;
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage, CachedNetworkImageProvider;
import 'package:e1547/appinfo.dart';
import 'package:e1547/comment.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlay;
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    show DefaultCacheManager;
import 'package:like_button/like_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart' as url;

import 'client.dart' show client;
import 'interface.dart';
import 'persistence.dart' show db;
import 'package:icon_shadow/icon_shadow.dart';
import 'package:share/share.dart';

enum _VoteStatus {
  upvoted,
  unknown,
  downvoted,
}

class Post {
  Map raw;

  int id;
  int score;
  int favorites;

  int parent;

  String uploader;

  Map file;
  Map preview;
  Map sample;

  String rating;
  String creation;
  String updated;
  int comments;
  String description;

  List<int> pools;
  List<int> children;
  List<String> artist;
  List<String> sources;

  Map tags;

  bool isDeleted;
  bool isFavorite;
  bool isLoggedIn;
  bool isBlacklisted;

  bool isConditionalDnp;
  bool hasSoundWarning;
  bool hasEpilepsyWarning;

  _VoteStatus voteStatus = _VoteStatus.unknown;

  Post.fromRaw(this.raw) {
    id = raw['id'] as int;
    favorites = raw['fav_count'] as int;

    isFavorite = raw['is_favorited'] as bool;
    isDeleted = raw['flags']['deleted'] as bool;
    isBlacklisted = false;

    parent = raw["relationships"]['parent_id'] as int ?? -1;
    children = [];
    children.addAll(raw["relationships"]['children'].cast<int>());

    creation = raw['created_at'];
    updated = raw['updated_at'];

    description = raw['description'] as String;
    rating = (raw['rating'] as String).toUpperCase();
    comments = (raw['comment_count'] as int);

    pools = [];
    // somehow, there are sometimes duplicates in there
    // not my fault, the json just is like that
    // we remove them with this convenient LinkedHashSet
    pools.addAll(LinkedHashSet<int>.from(raw['pools'].cast<int>()).toList());

    sources = [];
    sources.addAll(raw['sources'].cast<String>());

    tags = raw['tags'];
    artist = [];
    for (String s in tags['artist'].cast<String>()) {
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
  Widget build(BuildContext context) {
    Widget imagePreviewWidget() {
      return new CachedNetworkImage(
        imageUrl: post.sample['url'],
        errorWidget: (context, url, error) => const Icon(Icons.error),
        fit: BoxFit.cover,
      );
    }

    Widget imageContainer() {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          new Expanded(
              child: Container(
            alignment: (post.file['ext'] == 'gif') ? Alignment.center : null,
            child: imagePreviewWidget(),
          )),
          // postInfoWidget(),
        ],
      );
    }

    Widget playOverlay() {
      if (post.file['ext'] == 'gif' || post.file['ext'] == 'webm') {
        return new Positioned(
            top: 0,
            right: 0,
            child: new Container(
              padding: EdgeInsets.zero,
              color: Colors.black38,
              child: const Icon(Icons.play_arrow),
            ));
      } else {
        return new Container();
      }
    }

    return new GestureDetector(
        onTap: onPressed,
        child: () {
          return new Card(
              child: new Stack(
            children: <Widget>[
              imageContainer(),
              playOverlay(),
            ],
          ));
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
  Widget build(BuildContext context) {
    return new PageView.builder(
      controller: new PageController(initialPage: startingIndex),
      itemBuilder: _pageBuilder,
    );
  }

  Widget _pageBuilder(BuildContext context, int index) {
    return index < posts.length ? new PostWidget(posts[index]) : null;
  }
}

// Preview of a post that appears in lists of posts. Just the image.
class PostWidget extends StatefulWidget {
  final Post post;

  PostWidget(this.post);

  @override
  State<StatefulWidget> createState() {
    return new _PostWidgetState();
  }
}

class _PostWidgetState extends State<PostWidget> {
  void _download(BuildContext context) async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
      showDialog(
          context: context,
          builder: (context) {
            return new AlertDialog(
              content: const Text(
                  'You need to grant write permission in order to download files.'),
              actions: [
                new RaisedButton(
                  child: const Text('TRY AGAIN'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _download(context); // recursively re-execute
                  },
                ),
              ],
            );
          });
      return;
    }

    String downloadFolder =
        '${Platform.environment['EXTERNAL_STORAGE']}/Pictures/$appName';
    Directory(downloadFolder).createSync();

    String filename =
        '${widget.post.artist.join(', ')} - ${widget.post.id}.${widget.post.file['ext']}';
    String filepath = '$downloadFolder/$filename';

    Future<File> download() async {
      File file = new File(filepath);
      if (file.existsSync()) {
        return file;
      }

      DefaultCacheManager cacheManager = DefaultCacheManager();
      return (await cacheManager.getSingleFile(widget.post.file['url']))
          .copySync(filepath);
    }

    showDialog(
      context: context,
      builder: (context) {
        return new FutureBuilder(
          future: download(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return new AlertDialog(
                title: const Text('Error'),
                content: new Text(snapshot.error.toString()),
                actions: [
                  new FlatButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
            }

            bool done = snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData;

            return new AlertDialog(
              title: const Text('Download'),
              content: new Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Text(filename, softWrap: true),
                  new Padding(
                    padding: const EdgeInsets.all(8),
                    child: done
                        ? const Icon(Icons.done)
                        : Container(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(),
                          ),
                  ),
                ],
              ),
              actions: [
                new FlatButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  Future<void> tryRemoveFav(BuildContext context, Post post) async {
    if (await client.removeAsFavorite(post.id)) {
      setState(() {
        post.isFavorite = false;
        post.favorites -= 1;
      });
    } else {
      Scaffold.of(context).showSnackBar(new SnackBar(
        duration: const Duration(seconds: 1),
        content: new Text('Failed to remove Post ${post.id} from favorites'),
      ));
    }
  }

  Future<void> tryAddFav(BuildContext context, Post post) async {
    if (await client.addAsFavorite(post.id)) {
      setState(() {
        post.isFavorite = true;
        post.favorites += 1;
      });
    } else {
      Scaffold.of(context).showSnackBar(new SnackBar(
        duration: const Duration(seconds: 1),
        content: new Text('Failed to add Post ${post.id} to favorites'),
      ));
    }
  }

  Future<void> tryVote(
      BuildContext context, Post post, bool upvote, bool replace) async {
    if (!await client.votePost(post.id, upvote, replace)) {
      Scaffold.of(context).showSnackBar(new SnackBar(
        duration: const Duration(seconds: 1),
        content: new Text('Failed to vote on ${post.id}'),
      ));
    } else {
      setState(() {
        if (post.voteStatus == _VoteStatus.unknown) {
          if (upvote) {
            post.score += 1;
            post.voteStatus = _VoteStatus.upvoted;
          } else {
            post.score -= 1;
            post.voteStatus = _VoteStatus.downvoted;
          }
        } else {
          if (upvote) {
            if (post.voteStatus == _VoteStatus.upvoted) {
              post.score -= 1;
              post.voteStatus = _VoteStatus.unknown;
            } else {
              post.score += 2;
              post.voteStatus = _VoteStatus.upvoted;
            }
          } else {
            if (post.voteStatus == _VoteStatus.upvoted) {
              post.score -= 2;
              post.voteStatus = _VoteStatus.downvoted;
            } else {
              post.score += 1;
              post.voteStatus = _VoteStatus.unknown;
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget postContentsWidget() {
      Widget placeholder(Widget child) {
        return Container(
          height: 400,
          child: Center(
            child: child,
          ),
        );
      }

      Widget overlayImageWidget() {
        Widget imageWidget() {
          return () {
            if (widget.post.isDeleted) {
              return placeholder(const Text(
                'Post was deleted',
                textAlign: TextAlign.center,
              ));
            }
            if (widget.post.isBlacklisted) {
              return placeholder(Text(
                'Post is blacklisted',
                textAlign: TextAlign.center,
              ));
            }
            if (widget.post.file['url'] == null) {
              return placeholder(Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: const Text(
                      'Image unavailable in safe mode',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  InkWell(
                    child: Card(
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Settings'))),
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  )
                ],
              ));
            }
            if (widget.post.file['ext'] == 'swf' ||
                widget.post.file['ext'] == 'webm') {
              return placeholder(Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: const Text(
                      'Webm support under development',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  InkWell(
                    child: Card(
                        child: Padding(
                            padding: EdgeInsets.all(8), child: Text('Browse'))),
                    onTap: () async => url.launch(
                        widget.post.url(await db.host.value).toString()),
                  )
                ],
              ));
            }
            return CachedNetworkImage(
              imageUrl: widget.post.sample['url'],
              placeholder: (context, url) => placeholder(Container(
                height: 26,
                width: 26,
                child: const CircularProgressIndicator(),
              )),
              errorWidget: (context, url, error) =>
                placeholder(Icon(Icons.error_outline)),
            );
          }();
        }

        return Stack(
          children: <Widget>[
            Center(child: imageWidget()),
            new AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: IconShadowWidget(
                  Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  shadowColor: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: <Widget>[
                PopupMenuButton<String>(
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
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text('Share'),
                      ),
                    ),
                    widget.post.file['url'] != null
                        ? PopupMenuItem(
                            value: 'download',
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Text(
                                'Download',
                                maxLines: 1,
                              ),
                            ),
                          )
                        : null,
                    PopupMenuItem(
                      //
                      value: 'browser',
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          'Browse',
                          maxLines: 1,
                        ),
                      ),
                    )
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'share':
                        Share.share(
                            widget.post.url(await db.host.value).toString());
                        break;
                      case 'download':
                        _download(context);
                        break;
                      case 'browser':
                        url.launch(
                            widget.post.url(await db.host.value).toString());
                        break;
                    }
                  },
                ),
              ],
            )
            // appbarOverlay(),
          ],
        );
      }

      return new GestureDetector(
        onTap:
            widget.post.file['url'] != null && widget.post.file['ext'] != 'webm'
                ? _onTapImage(context, widget.post)
                : null,
        child: overlayImageWidget(),
      );
    }

    Widget postMetadataWidget() {
      Widget artistDisplay() {
        return Column(
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: new Icon(Icons.account_circle),
                    ),
                    widget.post.artist.length != 0
                        ? new RichText(
                            text: TextSpan(children: () {
                              List<TextSpan> spans = [];
                              for (String artist
                                  in widget.post.artist.join(', ').split(' ')) {
                                spans.add(TextSpan(
                                  text: artist + ' ',
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).push(
                                          new MaterialPageRoute<Null>(
                                              builder: (context) {
                                        return new SearchPage(
                                            new Tagset.parse(artist));
                                      }));
                                    },
                                ));
                              }
                              return spans;
                            }()),
                          )
                        : Text('no artist',
                            style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic)),
                  ],
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    new Text('#${widget.post.id}'),
                    new Row(children: [
                      new Icon(Icons.person, size: 14.0),
                      new Text(' ${widget.post.uploader}'),
                      // tap ID to search posts would be nice
                      // however, this costs extra API calls,
                      // as we would need ro resolve the ID into a name.
                    ]),
                  ],
                ),
              ],
            ),
            Divider(),
          ],
        );
      }

      Widget descriptionDisplay() {
        if (widget.post.description != '') {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: dTextField(context, widget.post.description),
                      ),
                    ),
                  )
                ],
              ),
              Divider(),
            ],
          );
        } else {
          return Container();
        }
      }

      Widget likeDisplay() {
        return Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    LikeButton(
                      isLiked: widget.post.voteStatus == _VoteStatus.upvoted,
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          Icons.arrow_upward,
                          color: isLiked
                              ? Colors.deepOrange
                              : Theme.of(context).iconTheme.color,
                        );
                      },
                      onTap: (isLiked) async {
                        if (widget.post.isLoggedIn && !widget.post.isDeleted) {
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
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(widget.post.score.toString()),
                    ),
                    LikeButton(
                      isLiked: widget.post.voteStatus == _VoteStatus.downvoted,
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
                        if (widget.post.isLoggedIn && !widget.post.isDeleted) {
                          if (isLiked) {
                            tryVote(context, widget.post, false, false);

                            return false;
                          } else {
                            tryVote(context, widget.post, false, true);
                            return true;
                          }
                        } else {
                          return false;
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(widget.post.favorites.toString()),
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
                items.add(ListTile(
                  leading: Icon(Icons.group),
                  title: Text(pool.toString()),
                  trailing: Icon(Icons.arrow_right),
                  onTap: () async {
                    Pool p = await client.poolById(pool);
                    Navigator.of(context)
                        .push(new MaterialPageRoute<Null>(builder: (context) {
                      return new PoolPage(p);
                    }));
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
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: () {
              List<Widget> items = [];
              if (widget.post.parent != -1) {
                items.addAll([
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
                  ListTile(
                    leading: Icon(Icons.supervisor_account),
                    title: Text(widget.post.parent.toString()),
                    trailing: Icon(Icons.arrow_right),
                    onTap: () async {
                      Post p = await client.post(widget.post.parent);
                      Navigator.of(context)
                          .push(new MaterialPageRoute<Null>(builder: (context) {
                        return new PostWidget(p);
                      }));
                    },
                  ),
                  Divider(),
                ]);
              }
              if (widget.post.children.length != 0) {
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
                  items.add(ListTile(
                    leading: Icon(Icons.supervised_user_circle),
                    title: Text(child.toString()),
                    trailing: Icon(Icons.arrow_right),
                    onTap: () async {
                      Post p = await client.post(child);
                      Navigator.of(context)
                          .push(new MaterialPageRoute<Null>(builder: (context) {
                        return new PostWidget(p);
                      }));
                    },
                  ));
                }
                items.add(Divider());
              }
              if (items.length == 0) {
                items.add(Container());
              }
              return items;
            }());
      }

      Widget tagDisplay() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: () {
            List<Widget> columns = [];
            List<String> tagSets = [
              'general',
              'species',
              'character',
              'copyright',
              'invalid',
              'lore',
              'meta',
              'artist',
            ];
            for (String tagSet in tagSets) {
              if (widget.post.tags[tagSet].length != 0) {
                columns.add(Column(
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
                        tagSet,
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
                              for (String tag in widget.post.tags[tagSet]) {
                                tags.add(
                                  InkWell(
                                      onTap: () => Navigator.of(context).push(
                                              new MaterialPageRoute<Null>(
                                                  builder: (context) {
                                            return new SearchPage(
                                                Tagset.parse(tag));
                                          })),
                                      onLongPress: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => wikiDialog(
                                              context, tag,
                                              actions: true),
                                        );
                                      },
                                      child: Card(
                                          child: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Text(tag),
                                      ))),
                                );
                              }
                              return tags;
                            }(),
                          ),
                        )
                      ],
                    ),
                    Divider(),
                  ],
                ));
              }
            }
            return columns;
          }(),
        );
      }

      Widget commentDisplay() {
        if (widget.post.comments > 0) {
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlineButton(
                      child: Text('COMMENTS (${widget.post.comments})'),
                      onPressed: () {
                        Navigator.of(context).push(
                            new MaterialPageRoute<Null>(builder: (context) {
                          return new CommentsWidget(widget.post);
                        }));
                      },
                    ),
                  )
                ],
              ),
              Divider(),
            ],
          );
        } else {
          return Container();
        }
      }

      Widget fileInfoDisplay() {
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
                'File',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: 4,
                left: 4,
                top: 2,
                bottom: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(() {
                    switch (widget.post.rating.toLowerCase()) {
                      case 's':
                        return 'Safe';
                      case 'q':
                        return 'Questionable';
                      case 'e':
                        return 'Explicit';
                    }
                    return 'Unknown';
                  }()),
                  Text(
                      '${widget.post.file['width']} x ${widget.post.file['height']}'),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: 4,
                left: 4,
                top: 2,
                bottom: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(DateTime.parse(widget.post.creation)
                      .toLocal()
                      .toString()),
                  Text(formatBytes(widget.post.file['size'], 1)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: 4,
                left: 4,
                top: 2,
                bottom: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  widget.post.updated != null
                      ? Text(DateTime.parse(widget.post.updated)
                      .toLocal()
                      .toString())
                      : Container(),
                  Text(widget.post.file['ext']),
                ],
              ),
            ),
            Divider(),
          ],
        );
      }

      Widget sourceDisplay() {
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
                'Sources',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: 4,
                left: 4,
                top: 2,
                bottom: 2,
              ),
              child: dTextField(context, () {
                String msg = '';
                for (String source in widget.post.sources) {
                  msg = msg + source + '\n';
                }
                return msg;
              }()),
            ),
            Divider(),
          ],
        );
      }

      return new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: <Widget>[
            artistDisplay(),
            descriptionDisplay(),
            likeDisplay(),
            commentDisplay(),
            parentDisplay(),
            poolDisplay(),
            tagDisplay(),
            fileInfoDisplay(),
            sourceDisplay(),
          ],
        ),
      );
    }

    Widget floatingActionButton(BuildContext context) {
      return new FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
            padding: EdgeInsets.only(left: 2),
            child: LikeButton(
              isLiked: widget.post.isFavorite,
              circleColor: CircleColor(start: Colors.pink, end: Colors.red),
              bubblesColor: BubblesColor(
                  dotPrimaryColor: Colors.pink, dotSecondaryColor: Colors.red),
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
            )),
        onPressed: () {},
      );
    }

    return Scaffold(
      body: new ListView(
        children: <Widget>[
          postContentsWidget(),
          postMetadataWidget(),
        ],
        physics: BouncingScrollPhysics(),
      ),
      floatingActionButton: widget.post.isLoggedIn
          ? Builder(
              builder: (context) {
                return floatingActionButton(context);
              },
            )
          : null,
    );
  }

  Function() _onTapImage(BuildContext context, Post post) {
    Widget fullScreenWidgetBuilder(BuildContext context) {
      return PhotoView(
        imageProvider: new CachedNetworkImageProvider(post.file['url']),
        loadingBuilder: (buildContext, imageChunkEvent) =>
            new Stack(alignment: Alignment.center, children: [
          new CachedNetworkImage(
            imageUrl: post.sample['url'],
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error_outline),
          ),
          new Container(
            alignment: Alignment.topCenter,
            child: const LinearProgressIndicator(),
          ),
        ]),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 6,
        onTapUp: (buildContext, tapDownDetails, photoViewControllerValue) =>
            Navigator.of(context).pop(),
      );
    }

    return () async {
      if (widget.post.file['ext'] == 'webm' ||
          widget.post.file['ext'] == 'swf') {
        url.launch(widget.post.file['url']);
      } else {
        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
        await Navigator.of(context).push(new MaterialPageRoute<Null>(
          builder: fullScreenWidgetBuilder,
        ));
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      }
    };
  }
}

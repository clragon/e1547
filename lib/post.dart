import 'dart:async' show Future;
import 'dart:io' show File, Platform;
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage, CachedNetworkImageProvider;
import 'package:e1547/pool.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlay;
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    show DefaultCacheManager;
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:like_button/like_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart' as url;

import 'client.dart' show client;
import 'persistence.dart' show db;
import 'package:icon_shadow/icon_shadow.dart';

class Post {
  Map raw;

  int id;
  int score;
  int favorites;
  String uploader;

  Map file;
  Map preview;
  Map sample;

  String rating;
  String creation;
  bool hasComments;
  String description;

  List<int> pools;
  List<String> artist;
  List<String> sources;

  Map tags;

  bool isFavourite;
  bool isLoggedIn;

  bool isConditionalDnp;
  bool hasSoundWarning;
  bool hasEpilepsyWarning;

  Post.fromRaw(this.raw) {
    id = raw['id'] as int;
    favorites = raw['fav_count'] as int;
    isFavourite = raw['is_favorited'] as bool;

    creation = raw['created_at'];

    description = raw['description'] as String;
    rating = (raw['rating'] as String).toUpperCase();
    hasComments = (raw['comment_count'] as int == 0);

    pools = [];
    pools.addAll(raw['pools'].cast<int>());

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

// Preview of a post that appears in lists of posts. Mostly just the image.
class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget(this.post, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(body: new PostWidgetScaffold(post));
  }
}

class PostWidgetScaffold extends StatelessWidget {
  final Post post;

  const PostWidgetScaffold(this.post, {Key key}) : super(key: key);

  Function() _download(BuildContext context) {
    return () async {
      Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]);

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
                      _download(context)(); // recursively re-execute
                    },
                  ),
                ],
              );
            });
        return;
      }

      String filename =
          '${post.artist.join(', ')} - ${post.id}.${post.file['ext']}';
      String filepath =
          '${Platform.environment['EXTERNAL_STORAGE']}/Download/$filename';

      Future<File> download() async {
        File file = new File(filepath);
        if (file.existsSync()) {
          return file;
        }

        DefaultCacheManager cm = DefaultCacheManager();
        return (await cm.getSingleFile(post.file['url'])).copySync(filepath);
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
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
            },
          );
        },
      );
    };
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  @override
  Widget build(BuildContext context) {
    Widget postContentsWidget() {
      Widget overlayImageWidget() {
        Widget imageWidget() {
          return post.file['ext'] == 'swf' || post.file['ext'] == 'webm'
              ? new Container(
                  height: 400,
                  child: Center(
                      child: const Text(
                    'Webm support under development. \nTap to open in browser.',
                    textAlign: TextAlign.center,
                  )))
              : new CachedNetworkImage(
                  imageUrl: post.sample['url'],
                  placeholder: (context, url) => Container(
                      height: 400,
                      child: Center(
                        child: Container(
                          height: 26,
                          width: 26,
                          child: const CircularProgressIndicator(),
                        ),
                      )),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error_outline),
                );
        }

        // return new Center(child: imageWidget());

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
                    /*
                    PopupMenuItem(
                      value: 'share',
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text('Share'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'download',
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          'Download',
                          maxLines: 1,
                        ),
                      ),
                    ),
                    */
                    PopupMenuItem(
                      //
                      value: 'browser',
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          'Browser',
                          maxLines: 1,
                        ),
                      ),
                    )
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'share':
                        // not implemented
                        break;
                      case 'download':
                        _download(context);
                        break;
                      case 'browser':
                        url.launch(post.url(await db.host.value).toString());
                        break;
                    }
                    ;
                  },
                ),
              ],
            )
            // appbarOverlay(),
          ],
        );
      }

      return new GestureDetector(
        onTap: _onTapImage(context, post),
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
                    new ParsedText(
                      text: post.artist.join(',\n'),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      parse: <MatchText>[
                        new MatchText(
                            type: ParsedType.CUSTOM,
                            pattern: r'([^, ]+)',
                            onTap: (url) {
                              Navigator.of(context).push(
                                  new MaterialPageRoute<Null>(
                                      builder: (context) {
                                return new SearchPage(Tagset.parse(url));
                              }));
                            }),
                      ],
                    ),
                  ],
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    new Text('#${post.id}'),
                    new Row(children: [
                      new Icon(Icons.person, size: 14.0),
                      new Text(' ${post.uploader}'),
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
        if (post.description != '') {
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
                        child:
                            PoolPreview.dTextField(context, post.description),
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
                      isLiked: false,
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          Icons.arrow_upward,
                          color: isLiked
                              ? Colors.deepOrange
                              : Theme.of(context).iconTheme.color,
                        );
                      },
                      onTap: (isLiked) async {
                        if (isLiked) {
                          return false;
                        } else {
                          return false;
                        }
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(post.score.toString()),
                    ),
                    LikeButton(
                      isLiked: false,
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
                        if (isLiked) {
                          return false;
                        } else {
                          return false;
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(post.favorites.toString()),
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
        if (post.pools.length != 0) {
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
              for (int pool in post.pools) {
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
              'meta'
            ];
            for (String tagSet in tagSets) {
              if (post.tags[tagSet].length != 0) {
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
                              for (String tag in post.tags[tagSet]) {
                                tags.add(
                                  InkWell(
                                      onTap: () => Navigator.of(context).push(
                                              new MaterialPageRoute<Null>(
                                                  builder: (context) {
                                            return new SearchPage(
                                                Tagset.parse(tag));
                                          })),
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
                  Text(DateTime.parse(post.creation).toLocal().toString()),
                  Text('${post.file['width']} x ${post.file['height']}')
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
                  Text(formatBytes(post.file['size'], 1)),
                  Text(post.file['ext']),
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
              child: PoolPreview.dTextField(context, () {
                String msg = '';
                for (String source in post.sources) {
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
            poolDisplay(),
            tagDisplay(),
            fileInfoDisplay(),
            sourceDisplay(),
          ],
        ),
      );
    }

    Future<void> tryRemoveFav(BuildContext context, Post post) async {
      if (await client.removeAsFavorite(post.id)) {
        post.isFavourite = false;
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
          duration: const Duration(seconds: 1),
          content: new Text('Failed to remove post ${post.id} from favorites'),
        ));
      }
    }

    Future<void> tryAddFav(BuildContext context, Post post) async {
      if (await client.addAsFavorite(post.id)) {
        post.isFavourite = true;
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
          duration: const Duration(seconds: 1),
          content: new Text('Failed to add post ${post.id} to favorites'),
        ));
      }
    }

    Widget floatingActionButton() {
      return new FloatingActionButton(
        heroTag: 'postButton',
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
            padding: EdgeInsets.only(left: 2),
            child: LikeButton(
              isLiked: post.isFavourite,
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
                  tryRemoveFav(context, post);
                  return false;
                } else {
                  tryAddFav(context, post);
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
          // const Divider(height: 8.0),
          // buttonBarWidget(),
        ],
        physics: BouncingScrollPhysics(),
      ),
      floatingActionButton: floatingActionButton(),
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
      if (post.file['ext'] == 'webm' || post.file['ext'] == 'swf') {
        url.launch(post.file['url']);
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

import 'dart:async' show Future;
import 'dart:collection';
import 'dart:core';
import 'dart:io' show Directory, File, Platform;
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart' as url;

import 'package:e1547/client.dart' show client;
import 'package:e1547/interface.dart';
import 'package:e1547/persistence.dart' show db;
import 'package:icon_shadow/icon_shadow.dart';
import 'package:share/share.dart';

class Post {
  Map raw;
  int id;

  Map file;
  Map preview;
  Map sample;

  String creation;
  String updated;

  String uploader;

  List<int> pools = [];
  List<int> children = [];

  bool isDeleted;
  bool isLoggedIn;
  bool isBlacklisted;

  ValueNotifier<Map> tags = ValueNotifier({});

  ValueNotifier<int> comments = ValueNotifier(null);
  ValueNotifier<int> parent = ValueNotifier(null);
  ValueNotifier<int> score = ValueNotifier(null);
  ValueNotifier<int> favorites = ValueNotifier(null);

  ValueNotifier<String> rating = ValueNotifier(null);
  ValueNotifier<String> description = ValueNotifier(null);

  ValueNotifier<List<String>> sources = ValueNotifier([]);

  ValueNotifier<bool> isFavorite = ValueNotifier(null);
  ValueNotifier<bool> isEditing = ValueNotifier(false);
  ValueNotifier<bool> showUnsafe = ValueNotifier(false);

  ValueNotifier<VoteStatus> voteStatus = ValueNotifier(VoteStatus.unknown);

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
    rating.value = (raw['rating'] as String).toUpperCase();
    comments.value = (raw['comment_count'] as int);

    // somehow, there are sometimes duplicates in there
    // not my fault, the json just is like that
    // we remove them with this convenient LinkedHashSet
    pools.addAll(LinkedHashSet<int>.from(raw['pools'].cast<int>()).toList());

    sources.value.addAll(raw['sources'].cast<String>());

    (raw['tags'] as Map).forEach((k, v) {
      tags.value[k] = List.from(v);
    });

    score = ValueNotifier(raw['score']['total'] as int);
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

  PostPreview(
    this.post, {
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget imagePreviewWidget() {
      if (post.file['url'] != null) {
        return Hero(
          tag: 'image_${post.id}',
          child: CachedNetworkImage(
            imageUrl: post.sample['url'],
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Center(
          child: Text('deleted'),
        );
      }
    }

    Widget imageContainer() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: imagePreviewWidget(),
          ),
          // postInfoWidget(),
        ],
      );
    }

    Widget playOverlay() {
      if (post.file['ext'] == 'gif' || post.file['ext'] == 'webm') {
        return Positioned(
            top: 0,
            right: 0,
            child: Container(
              color: Colors.black12,
              child: Icon(Icons.play_arrow),
            ));
      } else {
        return Container();
      }
    }

    return Card(
      child: InkWell(
          onTap: onPressed,
          child: () {
            return Stack(
              children: <Widget>[
                imageContainer(),
                playOverlay(),
              ],
            );
          }()),
    );
  }
}

// this thing allows swiping through posts
class PostSwipe extends StatelessWidget {
  final PostProvider provider;
  final int startingIndex;

  PostSwipe(this.provider, {this.startingIndex = 0});

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: startingIndex);

    Widget _pageBuilder(BuildContext context, int index) {
      if (index == provider.posts.length - 1) {
        provider.loadNextPage();
      }
      return index < provider.posts.length
          ? PostWidget(
              provider.posts[index],
              provider: provider,
              controller: controller,
            )
          : null;
    }

    return ValueListenableBuilder(
      valueListenable: provider.pages,
      builder: (BuildContext context, value, Widget child) {
        return PageView.builder(
          controller: controller,
          itemBuilder: _pageBuilder,
          onPageChanged: (index) {
            if (provider.posts.length != 0) {
              if (provider.posts[index].isEditing.value) {
                resetPost(provider.posts[index]);
              }
            }
          },
        );
      },
    );
  }
}

class PostWidget extends StatefulWidget {
  final Post post;
  final PostProvider provider;
  final PageController controller;

  PostWidget(this.post, {this.provider, this.controller});

  @override
  State<StatefulWidget> createState() {
    return _PostWidgetState();
  }
}

class _PostWidgetState extends State<PostWidget> {
  TextEditingController _textController = TextEditingController();
  ValueNotifier<Future<bool> Function()> doEdit = ValueNotifier(null);
  PersistentBottomSheetController _bottomSheetController;

  bool isVisible() {
    return (widget.post.isFavorite.value ||
        widget.post.showUnsafe.value ||
        !widget.post.isBlacklisted);
  }

  @override
  Widget build(BuildContext context) {
    widget.post.isEditing.addListener(() {
      if (!widget.post.isEditing.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _bottomSheetController?.close();
          } on NoSuchMethodError {
            // this error is thrown when hot reloading in debug mode
          }
        });
      }
    });

    widget.provider?.pages?.addListener(() {
      if (!widget.provider.posts.contains(widget.post)) {
        Navigator.of(context).pop();
      }
    });

    Widget postContentsWidget() {
      Widget overlayImageWidget() {
        Widget imageWidget() {
          return ValueListenableBuilder(
              valueListenable: widget.post.showUnsafe,
              builder: (context, value, child) {
                return Stack(
                  children: <Widget>[
                    Container(
                        child: Center(
                          child: () {
                            if (widget.post.isDeleted) {
                              return const Text(
                                'Post was deleted',
                                textAlign: TextAlign.center,
                              );
                            }
                            if (!isVisible()) {
                              return Text(
                                'Post is blacklisted',
                                textAlign: TextAlign.center,
                              );
                            }
                            if (widget.post.file['url'] == null) {
                              return Column(
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
                                ],
                              );
                            }
                            if (widget.post.file['ext'] == 'swf' ||
                                widget.post.file['ext'] == 'webm') {
                              return Column(
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
                                            padding: EdgeInsets.all(8),
                                            child: Text('Browse'))),
                                    onTap: () async => url.launch(widget.post
                                        .url(await db.host.value)
                                        .toString()),
                                  )
                                ],
                              );
                            }
                            return Hero(
                              tag: 'image_${widget.post.id}',
                              child: CachedNetworkImage(
                                imageUrl: widget.post.sample['url'],
                                placeholder: (context, url) => Center(
                                    child: Container(
                                  height: 26,
                                  width: 26,
                                  child: const CircularProgressIndicator(),
                                )),
                                errorWidget: (context, url, error) =>
                                    Center(child: Icon(Icons.error_outline)),
                              ),
                            );
                          }(),
                        ),
                        constraints: BoxConstraints(
                          minHeight: (MediaQuery.of(context).size.height /
                              2), // maybe set this to around 50% of screen DPS
                        )),
                    () {
                      if (!widget.post.isDeleted &&
                          (widget.post.file['url'] == null ||
                              !isVisible() ||
                              widget.post.showUnsafe.value)) {
                        return Positioned(
                          child: FlatButton(
                            color: value ? Colors.black12 : null,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 16,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 5, left: 5),
                                  child: value ? Text('hide') : Text('show'),
                                )
                              ],
                            ),
                            onPressed: () async {
                              bool consent = await getConsent(context);
                              if (consent) {
                                widget.post.showUnsafe.value =
                                    !widget.post.showUnsafe.value;
                                Post urls = await client.post(widget.post.id,
                                    unsafe: true);
                                setState(() {
                                  if (widget.post.file['url'] == null) {
                                    widget.post.file['url'] = urls.file['url'];
                                    widget.post.sample['url'] =
                                        urls.sample['url'];
                                    widget.post.preview['url'] =
                                        urls.preview['url'];
                                  } else if (!widget.post.isBlacklisted) {
                                    widget.post.file['url'] = null;
                                    widget.post.sample['url'] = null;
                                    widget.post.preview['url'] = null;
                                  }
                                });
                              }
                            },
                          ),
                          bottom: 0,
                          right: 5,
                        );
                      } else {
                        return Container();
                      }
                    }()
                  ],
                );
              });
        }

        return Stack(
          children: <Widget>[
            Center(child: imageWidget()),
            postAppBar(context, widget.post),
          ],
        );
      }

      return ValueListenableBuilder(
        valueListenable: widget.post.showUnsafe,
        builder: (context, value, child) {
          return InkWell(
            onTap: () {
              if (widget.post.file['ext'] != 'webm' &&
                  widget.post.file['url'] != null &&
                  isVisible()) {
                List<Post> posts = widget.provider?.posts ?? [widget.post];
                _onTapImage(context, posts, posts.indexOf(widget.post));
              }
            },
            child: overlayImageWidget(),
          );
        },
      );
    }

    Widget postMetadataWidget() {
      Widget artistDisplay() {
        return Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.account_circle),
                    ),
                    () {
                      if (widget.post.tags.value['artist'].length != 0) {
                        return RichText(
                          text: TextSpan(children: () {
                            List<TextSpan> spans = [];
                            int count = 0;
                            for (String artist
                                in widget.post.tags.value['artist']) {
                              switch (artist) {
                                case 'conditional_dnp':
                                case 'sound_warning':
                                case 'epilepsy_warning':
                                case 'avoid_posting':
                                  break;
                                default:
                                  count++;
                                  spans.add(TextSpan(
                                    text: count > 1 ? ', ' + artist : artist,
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute<Null>(
                                                builder: (context) {
                                          return SearchPage(
                                              tags: Tagset.parse(artist));
                                        }));
                                      },
                                  ));
                                  break;
                              }
                            }
                            return spans;
                          }()),
                        );
                      } else {
                        return Text('no artist',
                            style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.subtitle2.color,
                                fontStyle: FontStyle.italic));
                      }
                    }(),
                  ],
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
                              content: Text(
                                  'Copied post ID #${widget.post.id.toString()}'),
                            ));
                          },
                        );
                      },
                    ),
                    InkWell(
                      child: Row(children: [
                        Icon(Icons.person, size: 14.0),
                        Text(' ${widget.post.uploader}'),
                      ]),
                      onTap: () async {
                        String uploader = (await client
                            .user(widget.post.uploader.toString()))['name'];
                        Navigator.of(context)
                            .push(MaterialPageRoute<Null>(builder: (context) {
                          return SearchPage(
                              tags: Tagset.parse('user:$uploader'));
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
            if (value != '' || widget.post.isEditing.value) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  widget.post.isEditing.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Description',
                              style: TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                String desc = await Navigator.of(context).push(
                                    MaterialPageRoute<String>(
                                        builder: (context) {
                                  return TextEditor(
                                      title: '#${widget.post.id} description',
                                      content: value);
                                }));
                                if (desc != null) {
                                  widget.post.description.value = desc;
                                }
                              },
                            ),
                          ],
                        )
                      : Container(),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: dTextField(context, value),
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
                            if (widget.post.isLoggedIn &&
                                !widget.post.isDeleted) {
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
                          return Text(value.toString());
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
                                  if (widget.post.isLoggedIn &&
                                      !widget.post.isDeleted) {
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
                        return Text(value.toString());
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
                    Navigator.of(context)
                        .push(MaterialPageRoute<Null>(builder: (context) {
                      return PoolPage(p);
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
                        controller: _textController,
                        autofocus: true,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Parent ID',
                            border: UnderlineInputBorder()),
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
                children: () {
                  List<Widget> items = [];
                  if (value != null || widget.post.isEditing.value) {
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
                                      _textController.text =
                                          value?.toString() ?? '';
                                      setFocusToEnd(_textController);
                                      _bottomSheetController =
                                          Scaffold.of(context).showBottomSheet(
                                        (context) {
                                          return parentInput();
                                        },
                                      );
                                      doEdit.value = () async {
                                        isLoading.value = true;
                                        if (_textController.text
                                            .trim()
                                            .isEmpty) {
                                          isLoading.value = false;
                                          return Future.value(true);
                                        }
                                        if (int.tryParse(
                                                _textController.text) !=
                                            null) {
                                          Post parent = await client.post(
                                              int.tryParse(
                                                  _textController.text));
                                          if (parent != null) {
                                            widget.post.parent.value =
                                                parent.id;
                                            return true;
                                          }
                                        }
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          duration: Duration(seconds: 1),
                                          content: Text('Invalid parent post'),
                                          behavior: SnackBarBehavior.floating,
                                        ));
                                        isLoading.value = false;
                                        return false;
                                      };
                                      _bottomSheetController.closed.then((_) {
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
                                return PostWidget(post);
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
                    ]);
                  }
                  if (widget.post.children.length != 0 &&
                      !widget.post.isEditing.value) {
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
                                MaterialPageRoute<Null>(builder: (context) {
                              return PostWidget(post);
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
                  }
                  if (items.length == 0) {
                    items.add(Container());
                  }
                  return items;
                }());
          },
        );
      }

      Widget tagDisplay() {
        Widget tagCard(String tag, String tagSet) {
          return InkWell(
              onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute<Null>(builder: (context) {
                    return SearchPage(tags: Tagset.parse(tag));
                  })),
              onLongPress: () => wikiDialog(context, tag, actions: true),
              child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 24,
                        color: () {
                          switch (tagSet) {
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
                        }(),
                        child: () {
                          if (widget.post.isEditing.value) {
                            return InkWell(
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
                            );
                          } else {
                            return Container(
                              width: 5,
                            );
                          }
                        }(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 4, bottom: 4, right: 8, left: 6),
                        child: Text(tag.replaceAll('_', ' ')),
                      ),
                    ],
                  )));
        }

        Widget tagCreator(String tagSet) {
          Map group = {
            'general': 0,
            'species': 5,
            'character': 4,
            'copyright': 3,
            'artist': 1,
            'invalid': 6,
            'lore': 8,
            'meta': 7,
          };
          ValueNotifier isLoading = ValueNotifier(false);
          return Builder(
            builder: (BuildContext context) {
              return InkWell(
                child: Card(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 4),
                    child: Icon(Icons.add, size: 16),
                  ),
                ),
                onTap: () async {
                  _textController.text = '';
                  _bottomSheetController = Scaffold.of(context).showBottomSheet(
                    (context) {
                      return Padding(
                          padding: EdgeInsets.only(
                              left: 10.0, right: 10.0, bottom: 10),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
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
                                  child: TypeAheadField(
                                    direction: AxisDirection.up,
                                    hideOnLoading: true,
                                    hideOnEmpty: true,
                                    hideOnError: true,
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                      controller: _textController,
                                      autofocus: true,
                                      maxLines: 1,
                                      inputFormatters: [
                                        LowercaseTextInputFormatter()
                                      ],
                                      decoration: InputDecoration(
                                          labelText: tagSet,
                                          border: UnderlineInputBorder()),
                                    ),
                                    onSuggestionSelected: (suggestion) {
                                      List<String> tags =
                                          _textController.text.split(' ');
                                      List<String> before = [];
                                      for (String tag in tags) {
                                        before.add(tag);
                                        if (before.join(' ').length >=
                                            _textController
                                                .selection.extent.offset) {
                                          tags[tags.indexOf(tag)] = suggestion;
                                          break;
                                        }
                                      }
                                      _textController.text =
                                          tags.join(' ') + ' ';
                                    },
                                    itemBuilder:
                                        (BuildContext context, itemData) {
                                      return ListTile(
                                        title: Text(itemData),
                                      );
                                    },
                                    suggestionsCallback:
                                        (String pattern) async {
                                      List<String> tags =
                                          _textController.text.split(' ');
                                      List<String> before = [];
                                      int selection = 0;
                                      for (String tag in tags) {
                                        before.add(tag);
                                        if (before.join(' ').length >=
                                            _textController
                                                .selection.extent.offset) {
                                          selection = tags.indexOf(tag);
                                          break;
                                        }
                                      }
                                      if (tags[selection].trim().isNotEmpty) {
                                        return (await client.tags(
                                                tags[selection],
                                                category: group[tagSet]))
                                            .map((t) => t['name'])
                                            .toList();
                                      } else {
                                        return [];
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          ]));
                    },
                  );
                  doEdit.value = () async {
                    isLoading.value = true;
                    if (_textController.text.trim() == '') {
                      isLoading.value = false;
                      return Future.value(true);
                    }
                    List<String> tags = _textController.text.trim().split(' ');
                    widget.post.tags.value[tagSet].addAll(tags);
                    widget.post.tags.value[tagSet].sort();
                    widget.post.tags.value = Map.from(widget.post.tags.value);
                    () async {
                      if (tagSet != 'general') {
                        for (String tag in tags) {
                          List validator = (await client.tags(tag));
                          String category;
                          if (validator.length == 0) {
                            category = 'general';
                          }
                          if (group[tagSet] != validator[0]['category']) {
                            category = group.keys.firstWhere(
                                (k) => group[k] == validator[0]['category']);
                          }
                          if (category != null) {
                            widget.post.tags.value[tagSet].remove(tag);
                            widget.post.tags.value[category].add(tag);
                            widget.post.tags.value[category].sort();
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
                      }
                    }();
                    return Future.value(true);
                  };
                  _bottomSheetController.closed.then((_) {
                    doEdit.value = null;
                    isLoading.value = false;
                  });
                },
              );
            },
          );
        }

        return ValueListenableBuilder(
          valueListenable: widget.post.tags,
          builder: (context, value, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: () {
                List<Widget> columns = [];
                List<String> tagSets = [
                  'general',
                  'species',
                  'character',
                  'copyright',
                  'meta',
                  'lore',
                  'artist',
                  'invalid',
                ];
                for (String tagSet in tagSets) {
                  if (value[tagSet].length != 0 ||
                      (widget.post.isEditing.value && tagSet != 'invalid')) {
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
                                  for (String tag in value[tagSet]) {
                                    tags.add(
                                      tagCard(tag, tagSet),
                                    );
                                  }
                                  if (widget.post.isEditing.value) {
                                    tags.add(
                                      tagCreator(tagSet),
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
          },
        );
      }

      Widget commentDisplay() {
        return ValueListenableBuilder(
          valueListenable: widget.post.comments,
          builder: (BuildContext context, value, Widget child) {
            if (value > 0) {
              return Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlineButton(
                          child: Text('COMMENTS ($value)'),
                          onPressed: () {
                            Navigator.of(context).push(
                                MaterialPageRoute<Null>(builder: (context) {
                              return CommentsWidget(widget.post);
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
          },
        );
      }

      Widget ratingDisplay() {
        IconData getIcon(String rating) {
          switch (rating.toUpperCase()) {
            case 'S':
              return Icons.check_circle_outline;
            case 'Q':
              return Icons.help_outline;
            case 'E':
              return Icons.warning;
            default:
              return Icons.error_outline;
          }
        }

        return ValueListenableBuilder(
          valueListenable: widget.post.rating,
          builder: (context, value, child) {
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
                ListTile(
                  title: Text(ratings[value]),
                  leading: Icon(getIcon(value)),
                  onTap: () => showDialog(
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
                                  widget.post.rating.value = k.toUpperCase();
                                  Navigator.of(context).pop();
                                },
                              ));
                            });
                            return choices;
                          }(),
                        ),
                      )),
                ),
                Divider(),
              ],
            );
          },
        );
      }

      Widget fileInfoDisplay() {
        DateFormat dateFormat = DateFormat('dd.MM.yy HH:mm');
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
                  Text(ratings[widget.post.rating.value.toUpperCase()]),
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
                  Text(dateFormat
                      .format(DateTime.parse(widget.post.creation).toLocal())),
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
                      ? Text(dateFormat.format(
                          DateTime.parse(widget.post.updated).toLocal()))
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
        return ValueListenableBuilder(
          valueListenable: widget.post.sources,
          builder: (BuildContext context, value, Widget child) {
            if (value.length != 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      widget.post.isEditing.value
                          ? IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                String sources = await Navigator.of(context)
                                    .push(MaterialPageRoute<String>(
                                        builder: (context) {
                                  return TextEditor(
                                      title: '#${widget.post.id} sources',
                                      content: value.join('\n'),
                                      richEditor: false);
                                }));
                                if (sources != null) {
                                  widget.post.sources.value =
                                      sources.split('\n');
                                }
                              },
                            )
                          : Container(),
                    ],
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
                      for (String source in value) {
                        msg = '$msg$source\n';
                      }
                      return msg;
                    }()),
                  ),
                  Divider(),
                ],
              );
            } else {
              return Container();
            }
          },
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: () {
            if (!widget.post.isEditing.value) {
              return [
                artistDisplay(),
                descriptionDisplay(),
                likeDisplay(),
                commentDisplay(),
                parentDisplay(),
                poolDisplay(),
                tagDisplay(),
                fileInfoDisplay(),
                sourceDisplay(),
              ];
            } else {
              return [
                artistDisplay(),
                descriptionDisplay(),
                parentDisplay(),
                tagDisplay(),
                ratingDisplay(),
                sourceDisplay(),
              ];
            }
          }(),
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
                      controller: _textController,
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
        // TODO: fix the duplicate post widget issue and add float tag
        heroTag: null,
        backgroundColor: Theme.of(context).cardColor,
        child: fabIcon(),
        onPressed: () async {
          if (widget.post.isEditing.value) {
            if (doEdit.value != null) {
              if (await doEdit.value()) {
                _bottomSheetController.close();
              }
            } else {
              _textController.text = '';
              _bottomSheetController = Scaffold.of(context).showBottomSheet(
                (context) {
                  return reasonEditor();
                },
              );
              _bottomSheetController.closed.then((_) {
                doEdit.value = null;
                isLoading.value = false;
              });
              doEdit.value = () async {
                isLoading.value = true;
                Map response = await client.updatePost(
                    widget.post, Post.fromRaw(widget.post.raw),
                    editReason: _textController.text);
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
                return Future.value(true);
              };
            }
          }
        },
      );
    }

    return ValueListenableBuilder(
      valueListenable: widget.post.isEditing,
      builder: (context, value, child) {
        if (!value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              _bottomSheetController?.close();
            } on NoSuchMethodError {
              // just ignore this crap.
            }
          });
        }
        return WillPopScope(
          onWillPop: () {
            if (doEdit.value != null) {
              return Future.value(true);
            }
            if (value) {
              resetPost(widget.post);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            body: ListView(
              children: <Widget>[
                postContentsWidget(),
                postMetadataWidget(),
              ],
              physics: BouncingScrollPhysics(),
            ),
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

  Future<void> _onTapImage(
      BuildContext context, List<Post> posts, int index) async {
    Widget fullScreenGallery(BuildContext context) {
      int current = index;
      return PhotoViewGallery.builder(
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
        builder: (BuildContext context, int index) {
          current = index;
          return PhotoViewGalleryPageOptions(
            heroAttributes: PhotoViewHeroAttributes(
              tag: 'image_${posts[index].id}',
            ),
            imageProvider: CachedNetworkImageProvider(posts[index].file['url']),
            initialScale: PhotoViewComputedScale.contained * 0.8,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.contained * 6,
            onTapUp: (buildContext, tapDownDetails, photoViewControllerValue) =>
                Navigator.of(context).pop(),
          );
        },
        itemCount: posts.length,
        loadingBuilder: (buildContext, imageChunkEvent) => GestureDetector(
          child: Container(
            child: Stack(alignment: Alignment.center, children: [
              Hero(
                tag: 'image_${posts[current].id}',
                child: CachedNetworkImage(
                  imageUrl: posts[current].sample['url'],
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error_outline),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: LinearProgressIndicator(),
              ),
            ]),
            color: Theme.of(context).canvasColor,
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
        pageController: PageController(
          initialPage: index,
        ),
        onPageChanged: (index) {
          if (widget.controller != null) {
            widget.controller.jumpToPage(index);
          }
        },
      );
    }

    Widget fullScreenImage(BuildContext context) {
      return PhotoView(
        heroAttributes:
            PhotoViewHeroAttributes(tag: 'image_${posts[index].id}'),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
        imageProvider: CachedNetworkImageProvider(posts[index].file['url']),
        loadingBuilder: (buildContext, imageChunkEvent) =>
            Stack(alignment: Alignment.center, children: [
          CachedNetworkImage(
            imageUrl: posts[index].sample['url'],
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error_outline),
          ),
          Container(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(),
          ),
        ]),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 6,
        onTapUp: (buildContext, tapDownDetails, photoViewControllerValue) =>
            Navigator.of(context).pop(),
      );
    }

    if (widget.post.file['ext'] == 'webm' || widget.post.file['ext'] == 'swf') {
      url.launch(widget.post.file['url']);
    } else {
      SystemChrome.setEnabledSystemUIOverlays([]);
      await Navigator.of(context).push(MaterialPageRoute<Null>(
        builder:
            posts[index].isEditing.value ? fullScreenImage : fullScreenGallery,
      ));
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
  }
}

Widget postAppBar(BuildContext context, Post post) {
  Widget popMenuListTile(String title, IconData icon) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
          child: Text(title),
        ),
      ],
    );
  }

  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: IconShadowWidget(
        Icon(
          post.isEditing.value ? Icons.clear : Icons.arrow_back,
          color: Theme.of(context).iconTheme.color,
        ),
        shadowColor: Colors.black,
      ),
      onPressed: () =>
          post.isEditing.value ? resetPost(post) : Navigator.of(context).pop(),
    ),
    actions: post.isEditing.value
        ? null
        : <Widget>[
            ValueListenableBuilder(
              valueListenable: post.comments,
              builder: (BuildContext context, value, Widget child) {
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
                    post.file['url'] != null && (Platform.isAndroid)
                        ? PopupMenuItem(
                            value: 'download',
                            child: popMenuListTile(
                                'Download', Icons.file_download),
                          )
                        : null,
                    PopupMenuItem(
                      value: 'browse',
                      child: popMenuListTile('Browse', Icons.open_in_browser),
                    ),
                    post.isLoggedIn && value == 0 && false
                        ? PopupMenuItem(
                            value: 'comment',
                            child: popMenuListTile('Comment', Icons.comment),
                          )
                        : null,
                    // removed until working
                    post.isLoggedIn
                        ? PopupMenuItem(
                            value: 'edit',
                            child: popMenuListTile('Edit', Icons.edit),
                          )
                        : null,
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'share':
                        Share.share(post.url(await db.host.value).toString());
                        break;
                      case 'download':
                        downloadDialog(context, post);
                        break;
                      case 'browse':
                        url.launch(post.url(await db.host.value).toString());
                        break;
                      case 'comment':
                        // TODO: implement this
                        String desc = await Navigator.of(context)
                            .push(MaterialPageRoute<String>(builder: (context) {
                          return TextEditor(
                              title: '#${post.id} comment', content: value);
                        }));
                        if (desc.trim().isNotEmpty) {
                          client.postComment(desc, post);
                        }
                        break;
                      case 'edit':
                        post.isEditing.value = true;
                        break;
                    }
                  },
                );
              },
            ),
          ],
  );
}

Future<File> download(Post post) async {
  String downloadFolder =
      '${Platform.environment['EXTERNAL_STORAGE']}/Pictures/$appName';
  Directory(downloadFolder).createSync();

  String filename =
      '${post.tags.value['artist'].join(', ')} - ${post.id}.${post.file['ext']}';
  String filepath = '$downloadFolder/$filename';

  File file = File(filepath);
  if (file.existsSync()) {
    return file;
  }

  DefaultCacheManager cacheManager = DefaultCacheManager();
  return (await cacheManager.getSingleFile(post.file['url']))
      .copySync(filepath);
}

void downloadDialog(BuildContext context, Post post) async {
  Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);

  if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
                'You need to grant write permission in order to download files.'),
            actions: [
              RaisedButton(
                child: Text('TRY AGAIN'),
                onPressed: () {
                  Navigator.of(context).pop();
                  downloadDialog(context, post); // recursively re-execute
                },
              ),
            ],
          );
        });
    return;
  }

  showDialog(
    context: context,
    builder: (context) {
      return FutureBuilder(
        future: download(post),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(snapshot.error.toString()),
              actions: [
                FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          }

          bool done = snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData;

          return AlertDialog(
            title: Text('Download'),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${post.tags.value['artist'].join(', ')} - ${post.id}',
                    softWrap: true),
                Padding(
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
              FlatButton(
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

Widget loadingListTile(
    {Widget leading, Widget title, Widget trailing, Function onTap}) {
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  return ValueListenableBuilder(
    valueListenable: isLoading,
    builder: (BuildContext context, value, Widget child) {
      return ListTile(
        leading: leading,
        title: title,
        trailing: isLoading.value
            ? Container(
                child: CircularProgressIndicator(),
                height: 16,
                width: 16,
              )
            : trailing ?? Icon(Icons.arrow_right),
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
  'S': 'Safe',
  'Q': 'Questionable',
  'E': 'Explicit',
};

Future<void> tryRemoveFav(BuildContext context, Post post) async {
  if (await client.removeFavorite(post.id)) {
    post.isFavorite.value = false;
    post.favorites.value -= 1;
  } else {
    post.isFavorite.value = true;
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text('Failed to remove Post #${post.id} from favorites'),
    ));
  }
}

Future<void> tryAddFav(BuildContext context, Post post) async {
  if (await client.addFavorite(post.id)) {
    post.isFavorite.value = true;
    post.favorites.value += 1;
  } else {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text('Failed to add Post #${post.id} to favorites'),
    ));
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

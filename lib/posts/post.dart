import 'dart:async' show Future;
import 'dart:collection';
import 'dart:core';
import 'dart:io' show Directory, File, Platform;
import 'dart:math';

import 'package:e1547/about/app_info.dart';
import 'package:e1547/comments/comment.dart';
import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/interface/pop_menu_tile.dart';
import 'package:e1547/services/client.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    show DefaultCacheManager;
import 'package:icon_shadow/icon_shadow.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart' as url;
import 'package:video_player/video_player.dart';

class ImageFile {
  Map file;
  Map preview;
  Map sample;

  ImageFile.fromRaw(Map raw) {
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

  bool isDeleted;
  bool isLoggedIn;
  bool isBlacklisted;

  ValueNotifier<ImageFile> image = ValueNotifier(null);

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

  VideoPlayerController controller;

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

    image.value = ImageFile.fromRaw(raw);
    if (image.value.file['ext'] == 'webm') {
      controller = VideoPlayerController.network(image.value.file['url']);
      controller.setLooping(true);
    }
  }

  // build post URL
  Uri url(String host) =>
      new Uri(scheme: 'https', host: host, path: '/posts/$id');
}

enum ImageSize {
  screen,
  sample,
  full,
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
                          child: PopMenuTile(title: 'Share', icon: Icons.share),
                        ),
                        post.image.value.file['url'] != null &&
                                (Platform.isAndroid)
                            ? PopupMenuItem(
                                value: 'download',
                                child: PopMenuTile(
                                    title: 'Download',
                                    icon: Icons.file_download),
                              )
                            : null,
                        PopupMenuItem(
                          value: 'browse',
                          child: PopMenuTile(
                              title: 'Browse', icon: Icons.open_in_browser),
                        ),
                        post.isLoggedIn && canEdit
                            ? PopupMenuItem(
                                value: 'edit',
                                child: PopMenuTile(
                                    title: 'Edit', icon: Icons.edit),
                              )
                            : null,
                        post.isLoggedIn && value == 0
                            ? PopupMenuItem(
                                value: 'comment',
                                child: PopMenuTile(
                                    title: 'Comment', icon: Icons.comment),
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
                              message =
                                  'Saved to ${post.id}.${post.image.value.file['ext']}';
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

Future<File> download(Post post) async {
  String downloadFolder =
      '${Platform.environment['EXTERNAL_STORAGE']}/Pictures/$appName';
  Directory(downloadFolder).createSync();

  String filename = '${post.tags.value['artist'].where((tag) => ![
        'conditional_dnp',
        'sound_warning',
        'epilepsy_warning',
        'avoid_posting',
      ].contains(tag)).join(', ')} - ${post.id}.${post.image.value.file['ext']}';
  String filepath = '$downloadFolder/$filename';

  File file = File(filepath);
  if (file.existsSync()) {
    return file;
  }

  DefaultCacheManager cacheManager = DefaultCacheManager();
  return (await cacheManager.getSingleFile(post.image.value.file['url']))
      .copySync(filepath);
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

  await download(post)
      .then((value) => success = true, onError: (error) => success = false);
  return success;
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
        trailing: CrossFade(
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

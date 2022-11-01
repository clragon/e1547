import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talker/talker.dart';

Future<void> postDownloadingNotification(
  BuildContext context,
  Set<Post> items,
) async {
  Talker? talker = context.read<Talker?>();
  return loadingNotification<Post>(
    context: context,
    icon: const Icon(Icons.download),
    timeout: const Duration(milliseconds: 100),
    process: (item) async {
      try {
        await item.download(context.read<AppInfo>());
        return true;
      } catch (exception, stacktrace) {
        if (kDebugMode) {
          rethrow;
        }
        talker?.handle(exception, stacktrace);
        return false;
      }
    },
    items: items,
    onDone: (items) => items.length == 1
        ? 'Downloaded post #${items.first.id}'
        : 'Downloaded ${items.length} posts',
    onProgress: (items, index) => items.length == 1
        ? 'Downloading post #${items.first.id}'
        : 'Downloading post #${items.elementAt(index).id} (${index + 1}/${items.length})',
    onFailure: (items, index) =>
        'Failed to download post #${items.elementAt(index).id}',
    onCancel: (items, index) => 'Cancelled download',
  );
}

Future<void> postFavoritingNotification(
  BuildContext context,
  Set<Post> items,
  PostsController controller,
  bool isLiked,
) {
  Client client = context.read<Client>();
  DenylistService denylist = context.read<DenylistService>();
  bool upvote = context.read<Settings>().upvoteFavs.value;
  return loadingNotification<Post>(
    context: context,
    icon: const Icon(Icons.favorite),
    items: items,
    timeout: const Duration(milliseconds: 300),
    process: (post) async {
      PostController postController = PostController(
        client: client,
        denylist: denylist,
        id: post.id,
        parent: controller,
      );
      if (isLiked) {
        if (post.isFavorited) {
          return postController.unfav();
        } else {
          return true;
        }
      } else {
        if (!post.isFavorited) {
          return Future(() async {
            bool result = await postController.fav();
            if (result && upvote) {
              result = await postController.vote(upvote: true, replace: true);
            }
            return result;
          });
        } else {
          return true;
        }
      }
    },
    onDone: isLiked
        ? (items) => items.length == 1
            ? 'Unfavorited post #${items.first.id}'
            : 'Unfavorited ${items.length} posts'
        : (items) => items.length == 1
            ? 'Favorited post #${items.first.id}'
            : 'Favorited ${items.length} posts',
    onProgress: isLiked
        ? (items, index) => items.length == 1
            ? 'Unfavoriting post #${items.first.id}'
            : 'Unfavoriting post #${items.elementAt(index).id} (${index + 1}/${items.length})'
        : (items, index) => items.length == 1
            ? 'Favoriting post #${items.first.id}'
            : 'Favoriting post #${items.elementAt(index).id} (${index + 1}/${items.length})',
    onFailure: isLiked
        ? (items, index) =>
            'Failed to unfavorite post #${items.elementAt(index).id}'
        : (items, index) =>
            'Failed to favorite post #${items.elementAt(index).id}',
    onCancel: isLiked
        ? (items, index) => 'Cancelled unfavoriting'
        : (items, index) => 'Cancelled favoriting',
  );
}

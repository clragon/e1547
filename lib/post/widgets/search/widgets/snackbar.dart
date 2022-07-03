import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> postDownloadingNotification(
  BuildContext context,
  Set<Post> items,
) async {
  return loadingNotification<Post>(
    context: context,
    icon: const Icon(Icons.download),
    timeout: const Duration(milliseconds: 100),
    process: (item) async {
      try {
        item.download();
        return true;
      } catch (exception, stacktrace) {
        if (kDebugMode) {
          rethrow;
        }
        Logger.maybeOf(context)?.handle(exception, stacktrace);
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
  return loadingNotification<Post>(
    context: context,
    icon: const Icon(Icons.favorite),
    items: items,
    timeout: const Duration(milliseconds: 300),
    process: (post) async {
      PostController postController =
          PostController(id: post.id, parent: controller);
      if (isLiked) {
        if (post.isFavorited) {
          return postController.unfav();
        } else {
          return true;
        }
      } else {
        if (!post.isFavorited) {
          return postController.fav();
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

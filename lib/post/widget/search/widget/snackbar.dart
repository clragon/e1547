import 'package:e1547/domain/domain.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

Future<void> postDownloadingNotification(
  BuildContext context,
  Set<Post> items,
) async {
  Settings settings = context.read<Settings>();
  BaseCacheManager cache = context.read<BaseCacheManager>();
  final logger = Logger('Post Downloader');
  return loadingNotification<Post>(
    context: context,
    icon: const Icon(Icons.download),
    timeout: const Duration(milliseconds: 100),
    process: (item) async {
      try {
        await item.download(
          path: settings.downloadPath.value,
          onPathChanged: (path) => settings.downloadPath.value = path,
          folder: AppInfo.instance.appName,
          cache: cache,
        );
        return true;
      } on FileDownloadException catch (exception, stacktrace) {
        logger.severe('Failed to download post', exception, stacktrace);
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
  bool isLiked,
) {
  Domain domain = context.read<Domain>();
  bool upvote = context.read<Settings>().upvoteFavs.value;
  return loadingNotification<Post>(
    context: context,
    icon: const Icon(Icons.favorite),
    items: items,
    timeout: const Duration(milliseconds: 300),
    process: (post) async {
      try {
        await domain.favorites.setFavorite(id: post.id, favorite: !isLiked);
        if (!isLiked && upvote) {
          await domain.posts.vote(id: post.id, upvote: true, replace: true);
        }
        return true;
      } on Exception {
        return false;
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

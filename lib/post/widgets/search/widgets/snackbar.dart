import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

Future<void> postDownloadingNotification(
  BuildContext context,
  Set<Post> items,
) async {
  return loadingNotification<Post>(
    context: context,
    icon: Icon(Icons.download),
    timeout: Duration(milliseconds: 100),
    process: (Post item) => item.download(),
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
) =>
    loadingNotification<Post>(
      context: context,
      icon: Icon(Icons.favorite),
      items: items,
      timeout: Duration(milliseconds: 300),
      process: isLiked
          ? (post) async {
              if (post.isFavorited) {
                return post.tryRemoveFav(context);
              } else {
                return true;
              }
            }
          : (post) async {
              if (!post.isFavorited) {
                return post.tryAddFav(context);
              } else {
                return true;
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

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class FavoritePostsController extends PostsController {
  FavoritePostsController({required super.client, required super.denylist})
      : super(
          search: client.credentials != null
              ? 'fav:${client.credentials!.username}'
              : null,
        );

  @override
  @protected
  List<Post>? filter(List<Post>? items) {
    List<Post>? result =
        super.filter(items?.where((p) => !p.isFavorited).toList());
    return items
        ?.where((p) => (result?.contains(p) ?? false) || p.isFavorited)
        .toList();
  }

  @override
  @protected
  Future<List<Post>> fetch(int page, bool force) async {
    if (!client.hasLogin) throw NoUserLoginException();
    List<Post> posts = await client.posts(
      page,
      search: search,
      orderFavoritesByAdded: orderFavorites,
      force: force,
      cancelToken: cancelToken,
    );
    posts.removeWhere((e) => e.file.url == null && !e.flags.deleted);
    return posts;
  }

  @override
  @protected
  Future<PageResponse<int, Post>> withError(
      Future<PageResponse<int, Post>> Function() call) async {
    try {
      return await super.withError(call);
    } on NoUserLoginException catch (e) {
      return PageResponse.error(error: e);
    }
  }

  @override
  Future<void> getNextPage({
    bool force = false,
    bool reset = false,
    bool background = false,
  }) {
    if (error is NoUserLoginException) {
      Credentials? credentials = client.credentials;
      if (credentials != null) {
        search = 'fav:${client.credentials?.username}';
      }
    }
    return super.getNextPage(
      force: force,
      reset: reset,
      background: background,
    );
  }
}

class NoUserLoginException implements Exception {
  NoUserLoginException();

  @override
  String toString() => 'NoUserLoginException';
}

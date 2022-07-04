import 'package:e1547/client/client.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class FavoritePostsController extends PostsController {
  final ValueNotifier<bool> orderFavorites = ValueNotifier(false);

  FavoritePostsController()
      : super(
          search: client.credentials != null
              ? 'fav:${client.credentials!.username}'
              : null,
        );

  bool get isFavoriteSearch {
    Credentials? credentials = client.credentials;
    if (credentials != null) {
      return favRegex(client.credentials!.username).hasMatch(search.value);
    }
    return false;
  }

  @override
  @protected
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(orderFavorites);

  @override
  @protected
  List<Post> filter(List<Post> items) {
    List<Post> result =
        super.filter(items.where((p) => !p.isFavorited).toList());
    return items.where((p) => result.contains(p) || p.isFavorited).toList();
  }

  @override
  Future<List<Post>> provide(int page, bool force) async {
    if (!client.hasLogin) {
      throw NoUserLoginException('Cannot browse favorites without login');
    }
    return client.posts(
      page,
      search: search.value,
      orderFavorites: orderFavorites.value,
      force: force,
    );
  }

  @override
  Future<void> refresh({bool background = false, bool force = false}) async {
    if (error is NoUserLoginException) {
      Credentials? credentials = client.credentials;
      if (credentials != null) {
        search.value = 'fav:${client.credentials?.username}';
      }
    }
    return super.refresh(background: background, force: force);
  }
}

class NoUserLoginException implements Exception {
  final String? message;

  NoUserLoginException([this.message]);

  @override
  String toString() {
    return 'NoUserLoginException($message)';
  }
}

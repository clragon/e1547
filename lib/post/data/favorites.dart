import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class FavoritePostsController extends PostsController {
  FavoritePostsController({required super.client, required super.denylist})
      : super(
          search: client.credentials != null
              ? 'fav:${client.credentials!.username}'
              : null,
        );

  final ValueNotifier<bool> orderFavorites = ValueNotifier(false);

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
  Future<List<Post>> fetch(int page, bool force) async {
    if (!client.hasLogin) {
      throw NoUserLoginException('Cannot browse favorites without login');
    }
    return client.posts(
      page,
      search: search.value,
      orderFavorites: orderFavorites.value,
      force: force,
      cancelToken: cancelToken,
    );
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
  Future<void> refresh({bool background = false, bool force = false}) async {
    if (error is NoUserLoginException) {
      Credentials? credentials = client.credentials;
      if (credentials != null) {
        search.value = 'fav:${client.credentials?.username}';
      }
    }
    return super.refresh(background: background);
  }
}

class NoUserLoginException implements Exception {
  NoUserLoginException([this.message]);

  final String? message;

  @override
  String toString() {
    return 'NoUserLoginException($message)';
  }
}

class FavoritePostsProvider extends SubChangeNotifierProvider2<Client,
    DenylistService, FavoritePostsController> {
  FavoritePostsProvider({
    super.child,
    super.builder,
  }) : super(
          create: (context, client, denylist) => FavoritePostsController(
            client: client,
            denylist: denylist,
          ),
        );
}

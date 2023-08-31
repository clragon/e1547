import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class FavoritePostsController extends PostsController {
  FavoritePostsController({
    required super.client,
    required super.denylist,
  });

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
    return client.favorites(
      page,
      query: query,
      orderByAdded: orderFavorites,
      force: force,
      cancelToken: cancelToken,
    );
  }

  @override
  @protected
  Future<PageResponse<int, Post>> withError(
    Future<PageResponse<int, Post>> Function() call,
  ) async {
    try {
      return await super.withError(call);
    } on NoUserLoginException catch (e) {
      return PageResponse.error(error: e);
    }
  }
}

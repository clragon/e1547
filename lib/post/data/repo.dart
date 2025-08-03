import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:e1547/favorite/favorite.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:e1547/tag/tag.dart';

class PostRepo {
  PostRepo({
    required this.persona,
    required this.client,
    required FavoriteClient favorites,
    required PoolClient pools,
  }) : _pools = pools,
       _favorites = favorites;

  final Persona persona;
  final PostClient client;
  final FavoriteClient _favorites;
  final PoolClient _pools;

  Future<Post> get({required int id, bool? force, CancelToken? cancelToken}) =>
      client.get(id: id, force: force, cancelToken: cancelToken);

  Future<List<Post>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    Future<List<Post>> result;

    if (_shouldUseFavorites(query)) {
      result = _favorites.page(
        page: page,
        limit: limit,
        query: query,
        force: force,
        cancelToken: cancelToken,
      );
    } else {
      result = client.page(
        page: page,
        limit: limit,
        query: query,
        force: force,
        cancelToken: cancelToken,
      );
    }

    return result.map(_filter);
  }

  /// Determines if the request should use the favorites API instead of the regular posts API.
  bool _shouldUseFavorites(QueryMap? query) {
    final username = persona.identity.username;
    final tags = TagMap(query?['tags']).tags;
    if (username == null || tags.isEmpty || tags.length > 1) return false;
    return tags.first == 'fav:$username';
  }

  /// Filters out "broken" posts.
  /// Flash posts are considered to be broken by default, since we will not be able to display them.
  /// Censored posts, which have contentious tags and are unavailable to anonymous users, are also considered broken.
  /// Posts which are not deleted but have no file are censored.
  List<Post> _filter(List<Post> posts) => posts
      .whereNot((post) => !post.isDeleted && post.file == null)
      .whereNot((post) => post.ext == 'swf')
      .toList();

  Future<List<Post>> byIds({
    required List<int> ids,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    limit = max(0, min(limit ?? 75, 100));

    List<List<int>> chunks = [];
    for (int i = 0; i < ids.length; i += limit) {
      chunks.add(ids.sublist(i, min(i + limit, ids.length)));
    }

    List<Post> result = [];
    for (final chunk in chunks) {
      if (chunk.isEmpty) continue;
      String filter = 'id:${chunk.join(',')}';
      List<Post> part = await page(
        query: {'tags': filter},
        limit: limit,
        force: force,
        cancelToken: cancelToken,
      );
      Map<int, Post> table = {for (Post e in part) e.id: e};
      part =
          (chunk.map((e) => table[e]).toList()..removeWhere((e) => e == null))
              .cast<Post>();
      result.addAll(part);
    }
    return result;
  }

  Future<List<Post>> byPool({
    required int id,
    int? page,
    bool orderByOldest = true,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    page ??= 1;
    int perPage = persona.traits.value.perPage ?? 75;
    Pool pool = await _pools.get(
      id: id,
      force: force,
      cancelToken: cancelToken,
    );
    List<int> ids = pool.postIds;
    if (!orderByOldest) ids = ids.reversed.toList();
    int lower = (page - 1) * perPage;
    if (lower > ids.length) return [];
    ids = ids.sublist(lower).take(perPage).toList();
    return byIds(
      ids: ids,
      limit: perPage,
      force: force,
      cancelToken: cancelToken,
    );
  }
}

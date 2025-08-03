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
  }) =>
      (_getRedirectPage(
                page: page,
                limit: limit,
                query: query,
                force: force,
                cancelToken: cancelToken,
              ) ??
              client.page(
                page: page,
                limit: limit,
                query: query,
                force: force,
                cancelToken: cancelToken,
              ))
          .map(_filter);

  Future<List<Post>>? _getRedirectPage({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    final tags = TagMap(query?['tags']);
    final order = tags['order'] ?? '';
    final single = tags.length == 1 || (tags.length == 2 && order.isNotEmpty);

    if (!single) return null;

    // Checks for fictional order keys that indicate redirect behavior.
    bool specialOrder(String value) => order.isEmpty || order == value;

    if (tags['fav'] == persona.identity.username && specialOrder('fav')) {
      return _favorites.page(
        page: page,
        limit: limit,
        query: query,
        force: force,
        cancelToken: cancelToken,
      );
    }

    final poolId = int.tryParse(tags['pool'] ?? '');

    if (poolId != null) {
      return byPool(
        id: poolId,
        page: page,
        orderByOldest: specialOrder('pool'),
        force: force,
        cancelToken: cancelToken,
      );
    }

    return null;
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

  Future<void> vote({
    required int id,
    required bool upvote,
    required bool replace,
  }) => client.vote(id: id, upvote: upvote, replace: replace);
}

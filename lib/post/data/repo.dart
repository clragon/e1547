import 'dart:math';

import 'package:cached_query/cached_query.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';

class PostRepo {
  PostRepo({required this.persona, required this.client, required this.cache});

  final Persona persona;
  final PostClient client;
  final CachedQuery cache;

  final String queryKey = 'posts';

  late final _postCache = CacheSync<Post, int>(
    cache: cache,
    baseKey: queryKey,
    getId: (post) => post.id,
    getItem: (id) => get(id: id),
  );

  Future<Post> get({required int id, bool? force, CancelToken? cancelToken}) =>
      client.get(id: id, force: force, cancelToken: cancelToken);

  Query<Post> useGet(int id) => Query(
    cache: cache,
    key: [queryKey, id],
    queryFn: () => get(id: id),
  );

  Future<List<Post>> page({
    int? page,
    int? limit = 5,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => client
      .page(
        page: page,
        limit: limit,
        query: query,
        force: force,
        cancelToken: cancelToken,
      )
      .map(_filter);

  /// Filters out "broken" posts.
  /// Flash posts are considered to be broken by default, since we will not be able to display them.
  /// Censored posts, which have contentious tags and are unavailable to anonymous users, are also considered broken.
  /// Posts which are not deleted but have no file are censored.
  List<Post> _filter(List<Post> posts) => posts
      .whereNot((post) => !post.isDeleted && post.file == null)
      .whereNot((post) => post.ext == 'swf')
      .toList();

  InfiniteQuery<List<int>, int> usePage() => InfiniteQuery<List<int>, int>(
    cache: cache,
    key: [queryKey],
    getNextArg: (state) => (state?.pageParams.lastOrNull ?? 0) + 1,
    queryFn: (page) async {
      final posts = await this.page(page: page);
      return _postCache.populateFromPage(posts);
    },
  );

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

  Future<void> setFavorite({required int id, required bool favorite}) =>
      client.setFavorite(id: id, favorite: favorite);

  Mutation<void, bool> useSetFavorite({required int id}) => Mutation(
    queryFn: (isFavorite) => setFavorite(id: id, favorite: isFavorite),
    onSuccess: (_, favorite) => useGet(id).update(
      (post) => post!.copyWith(
        isFavorited: favorite,
        favCount: favorite ? post.favCount + 1 : post.favCount - 1,
      ),
    ),
  );
}

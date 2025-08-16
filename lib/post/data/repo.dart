import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';

class PostRepo {
  PostRepo({required this.persona, required this.client});

  final Persona persona;
  final PostClient client;

  Future<Post> get({required int id, bool? force, CancelToken? cancelToken}) =>
      client.get(id: id, force: force, cancelToken: cancelToken);

  Future<List<Post>> page({
    int? page,
    int? limit,
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
}

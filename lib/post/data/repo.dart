import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:e1547/favorite/favorite.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:e1547/tag/tag.dart';

class PostRepo {
  PostRepo({
    required this.client,
    required this.favorites,
    required this.persona,
  });

  final PostClient client;
  final FavoriteClient favorites;
  final Persona persona;

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
      result = favorites.page(
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
}

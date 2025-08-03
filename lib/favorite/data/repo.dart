import 'package:dio/dio.dart';
import 'package:e1547/favorite/favorite.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';

class FavoriteRepo {
  FavoriteRepo({required this.client, required this.persona});

  final FavoriteClient client;
  final Persona persona;

  Future<List<Post>> favorites({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => client.page(
    page: page,
    limit: limit,
    query: query,
    force: force,
    cancelToken: cancelToken,
  );

  Future<void> add(int postId) => client.add(postId);

  Future<void> remove(int postId) => client.remove(postId);
}

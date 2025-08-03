import 'package:dio/dio.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';

class FavoriteClient {
  FavoriteClient({required this.dio, required this.postCache});

  final Dio dio;
  final PagedValueCache<QueryKey, int, Post> postCache;

  Future<List<Post>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/favorites.json',
        queryParameters: {
          'page': page,
          'limit': limit,
          // may not contain tags, or we get redirected to a html page
          ...?(query?..remove('tags')),
        },
        cancelToken: cancelToken,
      )
      .then(unwrapResponse('posts'))
      .then(
        (response) => (response.data as List<dynamic>)
            .map<Post>(E621Post.fromJson)
            .where((post) => !post.isDeleted && post.file != null)
            .toList(),
      );

  Future<void> add(int postId) => postCache.items.optimistic(
    postId,
    (post) => post.copyWith(isFavorited: true),
    () => dio.post('/favorites.json', queryParameters: {'post_id': postId}),
  );

  Future<void> remove(int postId) => postCache.items.optimistic(
    postId,
    (post) => post.copyWith(isFavorited: false),
    () => dio.delete('/favorites/$postId.json'),
  );
}

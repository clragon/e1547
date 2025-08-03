import 'package:dio/dio.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/stream/stream.dart';

class PostClient {
  PostClient({required this.dio, required this.cache});

  final Dio dio;
  final PagedValueCache<QueryKey, int, Post> cache;

  Future<Post> get({required int id, bool? force, CancelToken? cancelToken}) =>
      cache.items
          .stream(
            id,
            fetch: () => dio
                .get('/posts/$id.json', cancelToken: cancelToken)
                .then(_unwrapPostsResponse)
                .then((response) => E621Post.fromJson(response.data)),
          )
          .future;

  Future<List<Post>> page({int? page, int? limit, CancelToken? cancelToken}) =>
      cache
          .stream(
            QueryKey([
              {'page': page, 'limit': limit},
            ]),
            fetch: () => dio
                .get(
                  '/posts.json',
                  queryParameters: {'page': page, 'limit': limit},
                  cancelToken: cancelToken,
                )
                .then(_unwrapPostsResponse)
                .then(
                  (response) =>
                      response.data.map<Post>(E621Post.fromJson).toList(),
                ),
          )
          .future;

  Future<void> addFavorite(int postId) => cache.items.optimistic(
    postId,
    (post) => post.copyWith(isFavorited: true),
    () => dio.post('/favorites.json', queryParameters: {'post_id': postId}),
  );

  Future<void> removeFavorite(int postId) => cache.items.optimistic(
    postId,
    (post) => post.copyWith(isFavorited: false),
    () => dio.delete('/favorites/$postId.json'),
  );

  /// Unfucks the e621 API JSON response for Posts.
  /// For reasons incomprehensible to mere mortals, this singular endpoint
  /// will always wrap the response in an object containing nothing but a single key.
  /// Either `posts` or `post` depending on the endpoint used.
  /// This is completely useless behaviour, and we don't want to deal with it later down the line.
  ///
  /// This code is intentionally crude, as we don't want to waste performance on this.
  Response _unwrapPostsResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      final inner = response.data['posts'] ?? response.data['post'];
      if (inner != null) {
        response.data = inner;
      }
    }
    return response;
  }
}

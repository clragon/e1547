import 'package:dio/dio.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
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
                .then(unwrapResponse('post'))
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
                .then(unwrapResponse('posts'))
                .then(
                  (response) =>
                      response.data.map<Post>(E621Post.fromJson).toList(),
                ),
          )
          .future;
}

import 'package:dio/dio.dart';
import 'package:e1547/post/data/post.dart';

class PostClient {
  PostClient({
    required this.dio,
  }) {
    if (!dio.interceptors.any(
      (interceptor) => interceptor is _PostsJsonUnwrapperInterceptor,
    )) {
      dio.interceptors.add(_PostsJsonUnwrapperInterceptor());
    }
  }

  final Dio dio;

  String get host => dio.options.baseUrl;
  String get key => 'posts';

  Future<Post> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/posts/$id.json',
            cancelToken: cancelToken,
          )
          .then(
            (response) => E621Post.fromJson(response.data),
          );

  List<Object> getKey(int id) => [host, key, id];

  Future<List<Post>> page({
    int? page,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    return dio
        .get(
          '/posts.json',
          queryParameters: {
            'page': page,
            'limit': limit,
          },
          cancelToken: cancelToken,
        )
        .then(
          (response) => response.data.map<Post>(E621Post.fromJson).toList(),
        );
  }

  List<Object> pageKey({
    int? page,
    int? limit,
  }) =>
      [
        host,
        key,
        {
          'page': page,
          'limit': limit,
        }
      ];
}

/// Unfucks the e621 API JSON response for Posts.
/// For reasons incomprehensible to mere mortals, this singular endpoint
/// will always wrap the response in an object containing nothing but a single key.
/// Either `posts` or `post` depending on the endpoint used.
/// This is completely useless behaviour, and we don't want to deal with it later down the line.
///
/// This code is intentionally crude, as we don't want to waste performance on this.
class _PostsJsonUnwrapperInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.path.contains('/posts') &&
        response.data is Map<String, dynamic>) {
      final inner = response.data['posts'] ?? response.data['post'];
      if (inner != null) {
        response.data = inner;
      }
    }
    super.onResponse(response, handler);
  }
}

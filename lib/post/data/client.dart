import 'package:dio/dio.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';

class PostClient {
  PostClient({required this.dio});

  final Dio dio;

  Future<Post> get({required int id, CancelToken? cancelToken}) {
    print('Fetching post $id');
    return dio
        .get('/posts/$id.json', cancelToken: cancelToken)
        .then(unwrapResponse('post'))
        .then((response) => E621Post.fromJson(response.data));
  }

  Future<List<Post>> page({
    int? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) {
    print('Fetching posts page $page');
    return dio
        .get(
          '/posts.json',
          queryParameters: {'page': page, 'limit': limit, ...?query}.toQuery(),
          cancelToken: cancelToken,
        )
        .then(unwrapResponse('posts'))
        .then(
          (response) => response.data.map<Post>(E621Post.fromJson).toList(),
        );
  }

  Future<void> setFavorite({required int id, required bool favorite}) {
    print('Setting favorite for post $id: $favorite');
    if (favorite) {
      return dio.post('/favorites.json', queryParameters: {'post_id': id});
    } else {
      return dio.delete('/favorites/$id.json');
    }
  }
}

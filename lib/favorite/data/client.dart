import 'package:dio/dio.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';

class FavoriteClient {
  FavoriteClient({required this.dio});

  final Dio dio;

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

  Future<void> add(int postId) =>
      dio.post('/favorites.json', queryParameters: {'post_id': postId});

  Future<void> remove(int postId) => dio.delete('/favorites/$postId.json');
}

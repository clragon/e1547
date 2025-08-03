import 'package:dio/dio.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';

class PostRepo {
  PostRepo({required this.client, required this.persona});

  final PostClient client;
  final Persona persona;

  Future<Post> get({required int id, bool? force, CancelToken? cancelToken}) =>
      client.get(id: id, force: force, cancelToken: cancelToken);

  Future<List<Post>> page({int? page, int? limit, CancelToken? cancelToken}) =>
      client.page(page: page, limit: limit, cancelToken: cancelToken);
}

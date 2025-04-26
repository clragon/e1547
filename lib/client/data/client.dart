import 'package:dio/dio.dart';
import 'package:e1547/post/post.dart';

class Client {
  Client({
    required this.dio,
  }) : posts = PostClient(dio: dio);

  final Dio dio;

  final PostClient posts;
}

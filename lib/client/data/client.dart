import 'package:dio/dio.dart';
import 'package:e1547/post/post.dart';

class Client {
  Client({
    required this.dio,
  }) : posts = PostClient(dio: dio);

  final Dio dio;

  final PostClient posts;

  void dispose() {
    dio.close();
    for (final client in [posts]) {
      try {
        (client as dynamic).dispose();
        // ignore: avoid_catching_errors
      } on NoSuchMethodError {
        // skip
      }
    }
  }
}

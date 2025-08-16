import 'package:cached_query/cached_query.dart';
import 'package:dio/dio.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';

class Domain {
  Domain({required this.persona, required this.dio, required this.cache});

  final Persona persona;
  final Dio dio;
  final CachedQuery cache;

  static const Duration defaultMaxAge = Duration(minutes: 5);

  late final PostClient _postsClient = PostClient(dio: dio);
  late final PostRepo posts = PostRepo(
    persona: persona,
    client: _postsClient,
    cache: cache,
  );

  void dispose() {
    dio.close();
    for (final client in [_postsClient]) {
      tryDispose(client);
    }
  }
}

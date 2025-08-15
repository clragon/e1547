import 'package:dio/dio.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';

class Domain {
  Domain({required this.dio, required this.persona}) : cache = _createCache();

  final Dio dio;
  final Persona persona;
  final ClientCache cache;

  //
  // ---
  //

  static const Duration defaultMaxAge = Duration(minutes: 5);

  static ClientCache _createCache() => ClientCache({
    Post: PagedValueCache<QueryKey, int, Post>(
      toId: (post) => post.id,
      size: null,
      maxAge: defaultMaxAge,
    ),
  });

  //
  // ---
  //

  late final PostClient _postsClient = PostClient(
    dio: dio,
    cache: cache.paged(),
  );

  //
  // ---
  //

  late final PostRepo posts = PostRepo(persona: persona, client: _postsClient);

  //
  // ---
  //

  void dispose() {
    dio.close();
    for (final client in [_postsClient]) {
      tryDispose(client);
    }
    cache.dispose();
  }
}

import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:e1547/wiki/wiki.dart';

class WikiClient {
  WikiClient({required this.dio, required this.cache});

  final Dio dio;
  final PagedValueCache<QueryKey, int, Wiki> cache;

  Future<Wiki> get({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  }) => cache.items
      .stream(
        int.tryParse(id) ?? id.hashCode,
        fetch: () => dio
            .get('/wiki_pages/$id.json', cancelToken: cancelToken)
            .then((response) => E621Wiki.fromJson(response.data)),
      )
      .future;

  Future<List<Wiki>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    final queryMap = {'page': page, 'limit': limit, ...?query};

    return cache
        .stream(
          QueryKey([queryMap]),
          fetch: () => dio
              .get(
                '/wiki_pages.json',
                queryParameters: queryMap,
                cancelToken: cancelToken,
              )
              .then((response) {
                return pick(response.data).asListOrThrow(
                  (p0) => E621Wiki.fromJson(p0.asMapOrThrow<String, dynamic>()),
                );
              }),
        )
        .future;
  }
}

extension E621Wiki on Wiki {
  static Wiki fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Wiki(
      id: pick('id').asIntOrThrow(),
      title: pick('title').asStringOrThrow(),
      body: pick('body').asStringOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      updatedAt: pick('updated_at').asDateTimeOrNull(),
      otherNames: pick('other_names').asListOrNull((e) => e.asStringOrThrow()),
      isLocked: pick('is_locked').asBoolOrNull(),
    ),
  );
}

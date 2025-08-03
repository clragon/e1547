import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:e1547/tag/tag.dart';

class TagClient {
  TagClient({required this.dio});

  final Dio dio;
  final PagedValueCache<QueryKey, int, Tag> cache = PagedValueCache(
    toId: (tag) => tag.id,
    size: null,
    maxAge: const Duration(minutes: 5),
  );

  Future<List<Tag>> page({
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
                '/tags.json',
                queryParameters: queryMap,
                cancelToken: cancelToken,
              )
              .then((response) {
                if (response.data is List<dynamic>) {
                  return response.data.map<Tag>(E621Tag.fromJson).toList();
                }
                return <Tag>[];
              }),
        )
        .future;
  }

  Future<List<Tag>> autocomplete({
    String? search,
    int? limit,
    int? category,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    search ??= '';
    if (search.contains(':')) return [];

    if (category == null) {
      if (search.length < 3) return [];

      final queryMap = {'search[name_matches]': search, 'limit': 3};

      return cache
          .stream(
            QueryKey([queryMap]),
            fetch: () => dio
                .get(
                  '/tags/autocomplete.json',
                  queryParameters: queryMap,
                  cancelToken: cancelToken,
                )
                .then((response) {
                  if (response.data is List<dynamic>) {
                    return response.data
                        .map<Tag>(E621Tag.fromJson)
                        .take(3)
                        .toList();
                  }
                  return <Tag>[];
                }),
          )
          .future;
    } else {
      return page(
        limit: limit,
        query: {
          'search[name_matches]': '$search*',
          'search[category]': category.toString(),
          'search[order]': 'count',
        },
        force: force,
        cancelToken: cancelToken,
      );
    }
  }

  Future<String?> aliases({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/tag_aliases.json',
        queryParameters: {'page': page, 'limit': limit, ...?query},
        cancelToken: cancelToken,
      )
      .then((response) {
        return pick(response.data)
            .asListOrEmpty((p0) => p0.asMapOrThrow())
            .where((e) => e['status'] != 'deleted')
            .map((e) => e['consequent_name'])
            .firstOrNull;
      });

  void dispose() {
    cache.dispose();
  }
}

extension E621Tag on Tag {
  static Tag fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Tag(
      id: pick('id').asIntOrThrow(),
      name: pick('name').asStringOrThrow(),
      count: pick('post_count').asIntOrThrow(),
      category: pick('category').asIntOrThrow(),
    ),
  );
}

import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';

class TagService {
  TagService({required this.dio});

  final Dio dio;

  // Technically missing get()
  Future<List<Tag>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await dio
        .get(
          '/tags.json',
          queryParameters: {'page': page, 'limit': limit, ...?query},
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Tag> tags = [];
    if (body is List<dynamic>) {
      for (final tag in body) {
        tags.add(E621Tag.fromJson(tag));
      }
    }
    return tags;
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
      List<Tag> tags = [];
      if (search.length < 3) return [];
      Object body = await dio
          .get(
            '/tags/autocomplete.json',
            queryParameters: {'search[name_matches]': search},
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then((response) => response.data);

      if (body is List<dynamic>) {
        for (final tag in body) {
          tags.add(E621Tag.fromJson(tag));
        }
      }

      return tags.take(3).toList();
    } else {
      return page(
        limit: limit,
        query:
            {
              'search[name_matches]': '$search*',
              'search[category]': category,
              'search[order]': 'count',
            }.toQuery(),
        force: force,
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
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
      .then((response) {
        return pick(response.data)
            .asListOrEmpty((p0) => p0.asMapOrThrow())
            .where((e) => e['status'] != 'deleted')
            .map((e) => e['consequent_name'])
            .firstOrNull;
      });
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

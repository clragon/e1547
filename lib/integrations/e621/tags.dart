import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';

class E621TagsClient extends TagsClient {
  E621TagsClient({required this.dio});

  final Dio dio;

  @override
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
          queryParameters: {
            'page': page,
            'limit': limit,
            ...?query,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Tag> tags = [];
    if (body is List<dynamic>) {
      for (final tag in body) {
        tags.add(Tag.fromJson(tag));
      }
    }
    return tags;
  }

  @override
  Future<List<Tag>> autocomplete({
    required String search,
    int? category,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    if (search.contains(':')) return [];
    List<Tag> tags = [];
    if (category == null) {
      if (search.length < 3) return [];
      Object body = await dio
          .get(
            '/tags/autocomplete.json',
            queryParameters: {
              'search[name_matches]': search,
            },
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then((response) => response.data);

      if (body is List<dynamic>) {
        for (final tag in body) {
          tags.add(Tag.fromJson(tag));
        }
      }
      return tags;
    } else {
      for (final tag in await page(
        limit: 3,
        query: {
          'search[name_matches]': '$search*',
          'search[category]': category,
          'search[order]': 'count',
        }.toQuery(),
        force: force,
      )) {
        tags.add(
          Tag(
            id: tag.id,
            name: tag.name,
            postCount: tag.postCount,
            category: tag.category,
          ),
        );
      }
      return tags;
    }
  }

  @override
  Future<String?> aliases({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await dio
        .get(
          '/tag_aliases.json',
          queryParameters: {
            'page': page,
            'limit': limit,
            ...?query,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((value) => value.data);

    if (body is List<dynamic>) {
      body.removeWhere((e) => e['status'] == 'deleted');
      if (body.isEmpty) return null;
      return body.first['consequent_name'];
    }

    return null;
  }
}

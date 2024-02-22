import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';

class DanbooruTagsClient extends TagsClient {
  DanbooruTagsClient({required this.dio});

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
            'search[hide_empty]': 'yes',
            ...?query,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Tag> tags = [];
    if (body is List<dynamic>) {
      for (final tag in body) {
        tags.add(DanbooruTag.fromJson(tag));
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
    for (final tag in await page(
      limit: 3,
      query: {
        'search[fuzzy_name_matches]': search,
        'search[category]': category,
        'search[order]': 'similarity',
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

  @override
  Future<String?> aliases({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    // TODO: implement aliases
    throw UnimplementedError();
  }
}

extension DanbooruTag on Tag {
  static Tag fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Tag(
          id: pick('id').asIntOrThrow(),
          name: pick('name').asStringOrThrow(),
          postCount: pick('post_count').asIntOrThrow(),
          category: pick('category').asIntOrThrow(),
        ),
      );
}

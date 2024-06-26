import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';

class DanbooruTagService extends TagService {
  DanbooruTagService({required this.dio});

  final Dio dio;

  @override
  Set<TagFeature> get features => {
        TagFeature.aliases,
      };

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
    String? search,
    int? limit,
    int? category,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    search ??= '';
    if (search.contains(':')) return [];
    return page(
      limit: limit,
      query: {
        'search[fuzzy_name_matches]': search,
        'search[category]': category,
        'search[order]': 'count',
      }.toQuery(),
      force: force,
    );
  }

  @override
  Future<String?> aliases({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
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
          .then(
            (value) => pick(value.data)
                .asListOrNull(
                  (p0) => pick(p0.asMapOrNull()).letOrNull(
                    (pick) => pick('consequent_name').asStringOrThrow(),
                  ),
                )
                ?.firstOrNull,
          );
}

extension DanbooruTag on Tag {
  static Tag fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Tag(
          id: pick('id').asIntOrThrow(),
          name: pick('name').asStringOrThrow(),
          count: pick('post_count').asIntOrThrow(),
          category: pick('category').asIntOrThrow(),
        ),
      );
}

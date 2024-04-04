import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';

class GelbooruTagService extends TagService {
  GelbooruTagService({required this.dio});

  final Dio dio;

  @override
  Set<TagFeature> get features => {};

  @override
  Future<List<Tag>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/index.php',
            queryParameters: {
              'page': 'dapi',
              's': 'tag',
              'q': 'index',
              'json': '1',
              'limit': limit,
              ...?query,
            },
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) =>
                (response.data['tag'] as List<dynamic>?)
                    ?.map(GelbooruTag.fromJson)
                    .toList() ??
                [],
          );

  @override
  Future<List<Tag>> autocomplete({
    String? search,
    int? limit,
    int? category,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      page(
        limit: limit,
        query: {'name_pattern': '${search ?? ''}%'},
        force: force,
        cancelToken: cancelToken,
      );
}

extension GelbooruTag on Tag {
  static Tag fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Tag(
          id: pick('id').asIntOrThrow(),
          name: pick('name').asStringOrThrow(),
          count: pick('count').asIntOrThrow(),
          category: pick('type').asIntOrThrow(),
        ),
      );
}

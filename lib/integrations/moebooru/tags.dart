import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';

class MoebooruTagService extends TagService {
  MoebooruTagService({
    required this.dio,
  });

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
            '/tag.json',
            queryParameters: {
              'page': page,
              'limit': limit,
              ...?query,
            },
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) =>
                response.data.map(MoebooruTag.fromJson).cast<Tag>().toList(),
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
        query: {'name': '${search ?? ''}*'},
        force: force,
        cancelToken: cancelToken,
      );
}

extension MoebooruTag on Tag {
  static Tag fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Tag(
          id: pick('id').asIntOrThrow(),
          name: pick('name').asStringOrThrow(),
          count: pick('count').asIntOrThrow(),
          category: pick('type').asIntOrThrow(),
        ),
      );
}

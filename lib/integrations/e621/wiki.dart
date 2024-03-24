import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/wiki/wiki.dart';

class E621WikiService extends WikiService {
  E621WikiService({required this.dio});

  final Dio dio;

  @override
  Future<Wiki> get({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/wiki_pages/$id.json',
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) => E621Wiki.fromJson(response.data),
          );

  @override
  Future<List<Wiki>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/wiki_pages.json',
            queryParameters: {
              'page': page,
              'limit': limit,
              ...?query,
            },
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) => pick(response.data).asListOrThrow(
              (p0) => E621Wiki.fromJson(p0.asMapOrThrow<String, dynamic>()),
            ),
          );
}

extension E621Wiki on Wiki {
  static Wiki fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Wiki(
          id: pick('id').asIntOrThrow(),
          title: pick('title').asStringOrThrow(),
          body: pick('body').asStringOrThrow(),
          createdAt: pick('created_at').asDateTimeOrThrow(),
          updatedAt: pick('updated_at').asDateTimeOrNull(),
          otherNames:
              pick('other_names').asListOrNull((e) => e.asStringOrThrow()),
          isLocked: pick('is_locked').asBoolOrNull(),
        ),
      );
}

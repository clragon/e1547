import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/wiki/wiki.dart';

class DanbooruWikisClient extends WikisClient {
  DanbooruWikisClient({required this.dio});

  final Dio dio;

  @override
  Future<Wiki> get({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await dio
        .get(
          '/wiki_pages/$id.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return DanbooruWiki.fromJson(body);
  }

  @override
  Future<List<Wiki>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    List<dynamic> body = await dio
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
        .then((response) => response.data);

    return body.map((entry) => DanbooruWiki.fromJson(entry)).toList();
  }
}

extension DanbooruWiki on Wiki {
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

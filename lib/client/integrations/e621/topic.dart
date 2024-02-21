import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/topic/topic.dart';

class E621TopicsClient extends TopicsClient {
  E621TopicsClient({required this.dio});

  final Dio dio;

  @override
  Future<List<Topic>> topics({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/forum_topics.json',
            queryParameters: {
              'page': page,
              'limit': limit,
              ...?query,
            },
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) => pick(response.data).asListOrEmpty(
              (p0) => E621Topic.fromJson(p0.asMapOrThrow()),
            ),
          );

  @override
  Future<Topic> topic({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async =>
      dio
          .get(
            '/forum_topics/$id.json',
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then((response) => E621Topic.fromJson(response.data));
}

extension E621Topic on Topic {
  static Topic fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Topic(
          id: pick('id').asIntOrThrow(),
          creatorId: pick('creator_id').asIntOrThrow(),
          title: pick('title').asStringOrThrow(),
          responseCount: pick('response_count').asIntOrThrow(),
          createdAt: pick('created_at').asDateTimeOrThrow(),
          updatedAt: pick('updated_at').asDateTimeOrThrow(),
          isLocked: pick('is_locked').asBoolOrThrow(),
          categoryId: pick('category_id').asIntOrThrow(),
        ),
      );
}

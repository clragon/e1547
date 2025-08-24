import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/topic/topic.dart';

class TopicClient {
  TopicClient({required this.dio});

  final Dio dio;

  Future<Topic> get({required int id, CancelToken? cancelToken}) => dio
      .get(
        '/forum_topics/$id.json',
        options: forceOptions(true),
        cancelToken: cancelToken,
      )
      .then((response) => E621Topic.fromJson(response.data));

  Future<List<Topic>> page({
    int? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/forum_topics.json',
        queryParameters: {'page': page, 'limit': limit, ...?query}.toQuery(),
        options: forceOptions(true),
        cancelToken: cancelToken,
      )
      .then(
        (response) => pick(
          response.data,
        ).asListOrEmpty((p0) => E621Topic.fromJson(p0.asMapOrThrow())),
      );
}

extension E621Topic on Topic {
  static Topic fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Topic(
      id: pick('id').asIntOrThrow(),
      creatorId: pick('creator_id').asIntOrThrow(),
      creator: pick('creator_name').asStringOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      updaterId: pick('updater_id').asIntOrThrow(),
      updater: pick('updater_name').asStringOrThrow(),
      updatedAt: pick('updated_at').asDateTimeOrThrow(),
      title: pick('title').asStringOrThrow(),
      responseCount: pick('response_count').asIntOrThrow(),
      sticky: pick('is_sticky').asBoolOrThrow(),
      locked: pick('is_locked').asBoolOrThrow(),
      hidden: pick('is_hidden').asBoolOrThrow(),
      categoryId: pick('category_id').asIntOrThrow(),
    ),
  );
}

import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:e1547/topic/topic.dart';

class TopicClient {
  TopicClient({required this.dio, required this.cache});

  final Dio dio;
  final PagedValueCache<QueryKey, int, Topic> cache;

  Future<Topic> get({required int id, bool? force, CancelToken? cancelToken}) =>
      cache.items
          .stream(
            id,
            fetch: () => dio
                .get('/forum_topics/$id.json', cancelToken: cancelToken)
                .then((response) => E621Topic.fromJson(response.data)),
          )
          .future;

  Future<List<Topic>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    final queryMap = {'page': page, 'limit': limit, ...?query};

    return cache
        .stream(
          QueryKey([queryMap]),
          fetch: () => dio
              .get(
                '/forum_topics.json',
                queryParameters: queryMap,
                cancelToken: cancelToken,
              )
              .then((response) {
                return pick(
                  response.data,
                ).asListOrEmpty((p0) => E621Topic.fromJson(p0.asMapOrThrow()));
              }),
        )
        .future;
  }
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

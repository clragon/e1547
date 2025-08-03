import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';

class ReplyClient {
  ReplyClient({required this.dio});

  final Dio dio;
  final PagedValueCache<QueryKey, int, Reply> cache = PagedValueCache(
    toId: (reply) => reply.id,
    size: null,
    maxAge: const Duration(minutes: 5),
  );

  Future<Reply> get({required int id, bool? force, CancelToken? cancelToken}) =>
      cache.items
          .stream(
            id,
            fetch: () => dio
                .get('/forum_posts/$id.json', cancelToken: cancelToken)
                .then((response) => E621Reply.fromJson(response.data)),
          )
          .future;

  Future<List<Reply>> page({
    required int id,
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
                '/forum_posts.json',
                queryParameters: queryMap,
                cancelToken: cancelToken,
              )
              .then((response) {
                return pick(
                  response.data,
                ).asListOrEmpty((p0) => E621Reply.fromJson(p0.asMapOrThrow()));
              }),
        )
        .future;
  }

  Future<List<Reply>> byTopic({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  }) => this.page(
    id: id,
    page: page,
    limit: limit,
    query: {
      'search[topic_id]': id.toString(),
      'search[order]': ascending ?? false ? 'id_asc' : 'id_desc',
    },
    force: force,
    cancelToken: cancelToken,
  );

  void dispose() {
    cache.dispose();
  }
}

extension E621Reply on Reply {
  static Reply fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Reply(
      id: pick('id').asIntOrThrow(),
      creatorId: pick('creator_id').asIntOrThrow(),
      creator: pick('creator_name').asStringOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      updaterId: pick('updater_id').asIntOrNull(),
      updater: pick('updater_name').asStringOrNull(),
      updatedAt: pick('updated_at').asDateTimeOrThrow(),
      body: pick('body').asStringOrThrow(),
      topicId: pick('topic_id').asIntOrThrow(),
      warning: pick(
        'warning_type',
      ).letOrNull((pick) => WarningType.values.asNameMap()[pick.asString()]!),
      hidden: pick('is_hidden').asBoolOrThrow(),
    ),
  );
}

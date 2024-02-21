import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';

class E621RepliesClient extends RepliesClient {
  E621RepliesClient({required this.dio});

  final Dio dio;

  @override
  Future<Reply> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async =>
      dio
          .get(
            '/forum_posts/$id.json',
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) => E621Reply.fromJson(response.data),
          );

  @override
  Future<List<Reply>> page({
    required int id,
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async =>
      dio
          .get(
            '/forum_posts.json',
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
              (p0) => E621Reply.fromJson(p0.asMapOrThrow()),
            ),
          );

  @override
  Future<List<Reply>> byTopic({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  }) async =>
      this.page(
        id: id,
        page: page,
        limit: limit,
        query: {
          'search[topic_id]': id,
          'search[order]': ascending ?? false ? 'id_asc' : 'id_desc',
        }.toQuery(),
        force: force,
        cancelToken: cancelToken,
      );
}

extension E621Reply on Reply {
  static Reply fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Reply(
          id: pick('id').asIntOrThrow(),
          createdAt: pick('created_at').asDateTimeOrThrow(),
          updatedAt: pick('updated_at').asDateTimeOrThrow(),
          body: pick('body').asStringOrThrow(),
          creatorId: pick('creator_id').asIntOrThrow(),
          topicId: pick('topic_id').asIntOrThrow(),
          warning: ReplyWarning(
            type: pick('warning_type').letOrNull(
                (pick) => WarningType.values.asNameMap()[pick.asString()]!),
          ),
        ),
      );
}

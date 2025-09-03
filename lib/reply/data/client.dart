import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';

class ReplyClient {
  ReplyClient({required this.dio});

  final Dio dio;

  Future<Reply> get({required int id, CancelToken? cancelToken}) => dio
      .get(
        '/forum_posts/$id.json',
        options: forceOptions(true),
        cancelToken: cancelToken,
      )
      .then((response) => E621Reply.fromJson(response.data));

  Future<List<Reply>> page({
    int? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/forum_posts.json',
        queryParameters: {'page': page, 'limit': limit, ...?query}.toQuery(),
        options: forceOptions(true),
        cancelToken: cancelToken,
      )
      .then(
        (response) => pick(
          response.data,
        ).asListOrEmpty((p0) => E621Reply.fromJson(p0.asMapOrThrow())),
      );
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

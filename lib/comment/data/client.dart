import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/shared/shared.dart';

class CommentClient {
  CommentClient({required this.dio});

  final Dio dio;

  Future<Comment> get({required int id, CancelToken? cancelToken}) => dio
      .get(
        '/comments/$id.json',
        options: forceOptions(true),
        cancelToken: cancelToken,
      )
      .then((response) => E621Comment.fromJson(response.data));

  Future<List<Comment>> page({
    int? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/comments.json',
        queryParameters: {'page': page, 'limit': limit, ...?query}.toQuery(),
        options: forceOptions(true),
        cancelToken: cancelToken,
      )
      .then((response) {
        if (response.data is List<dynamic>) {
          return response.data.map<Comment>(E621Comment.fromJson).toList();
        }
        return [];
      });

  Future<void> create({required int postId, required String content}) =>
      dio.post(
        '/comments.json',
        data: FormData.fromMap({
          'comment[body]': content,
          'comment[post_id]': postId,
        }),
      );

  Future<void> update({
    required int id,
    required int postId,
    required String content,
  }) => dio.patch(
    '/comments/$id.json',
    data: FormData.fromMap({'comment[body]': content}),
  );

  Future<VoteResult> vote({
    required int id,
    required bool upvote,
    required bool replace,
  }) => dio
      .post(
        '/comments/$id/votes.json',
        queryParameters: {'score': upvote ? 1 : -1, 'no_unvote': replace},
      )
      .then((response) => VoteResult.fromJson(response.data));
}

extension E621Comment on Comment {
  static Comment fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Comment(
      id: pick('id').asIntOrThrow(),
      postId: pick('post_id').asIntOrThrow(),
      body: pick('body').asStringOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      updatedAt: pick('updated_at').asDateTimeOrThrow(),
      creatorId: pick('creator_id').asIntOrThrow(),
      creatorName: pick('creator_name').asStringOrThrow(),
      vote: pick(
        'score',
      ).letOrNull((pick) => VoteInfo(score: pick.asIntOrThrow())),
      warning: pick(
        'warning_type',
      ).letOrNull((pick) => WarningType.values.asNameMap()[pick.asString()]!),
      hidden: pick('is_hidden').asBoolOrThrow(),
    ),
  );
}

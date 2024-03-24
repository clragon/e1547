import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';

class DanbooruCommentsClient extends CommentsClient {
  DanbooruCommentsClient({required this.dio});

  final Dio dio;

  @override
  Set<CommentFeature> get features => {};

  @override
  Future<Comment> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/comments.json/$id.json',
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then((response) => DanbooruComment.fromJson(response.data));

  @override
  Future<List<Comment>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/comments.json',
            queryParameters: {
              'page': page,
              'limit': limit,
              ...?query,
            },
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then((response) => pick(response.data).asListOrEmpty(
              (p0) => DanbooruComment.fromJson(p0.asMapOrThrow())));

  @override
  Future<List<Comment>> byPost({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      this.page(
        page: page,
        limit: limit,
        query: {
          'group_by': 'comment',
          'search[post_id]': id,
          'search[order]': ascending ?? false ? 'id_asc' : 'id_desc',
        }.toQuery(),
        force: force,
        cancelToken: cancelToken,
      );
}

extension DanbooruComment on Comment {
  static Comment fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Comment(
          id: pick('id').asIntOrThrow(),
          postId: pick('post_id').asIntOrThrow(),
          body: pick('body').asStringOrThrow(),
          createdAt: pick('created_at').asDateTimeOrThrow(),
          updatedAt: pick('updated_at').asDateTimeOrThrow(),
          creatorId: pick('creator_id').asIntOrThrow(),
          creatorName: null,
          vote: VoteInfo(
            score: pick('score').asIntOrThrow(),
          ),
          warning: null,
        ),
      );
}

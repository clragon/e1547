import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';

class CommentService {
  CommentService({required this.dio});

  final Dio dio;

  Future<Comment> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await dio
        .get(
          '/comments.json/$id.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return E621Comment.fromJson(body);
  }

  Future<List<Comment>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await dio
        .get(
          '/comments.json',
          queryParameters: {'page': page, 'limit': limit, ...?query},
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Comment> comments = [];
    if (body is List<dynamic>) {
      for (Map<String, dynamic> rawComment in body) {
        comments.add(E621Comment.fromJson(rawComment));
      }
    }

    return comments;
  }

  Future<List<Comment>> byPost({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  }) => this.page(
    page: page,
    limit: limit,
    query:
        {
          'group_by': 'comment',
          'search[post_id]': id,
          'search[order]': ascending ?? false ? 'id_asc' : 'id_desc',
        }.toQuery(),
    force: force,
    cancelToken: cancelToken,
  );

  Future<void> create({required int postId, required String content}) async {
    await dio.cache?.deleteFromPath(
      RegExp(RegExp.escape('/comments.json')),
      queryParams: {'search[post_id]': postId.toString()},
    );
    Map<String, dynamic> body = {
      'comment[body]': content,
      'comment[post_id]': postId,
      'commit': 'Submit',
    };

    await dio.post('/comments.json', data: FormData.fromMap(body));
  }

  Future<void> update({
    required int id,
    required int postId,
    required String content,
  }) async {
    await dio.cache?.deleteFromPath(
      RegExp(RegExp.escape('/comments.json')),
      queryParams: {'search[post_id]': postId.toString()},
    );
    await dio.cache?.deleteFromPath(
      RegExp(RegExp.escape('/comments/$id.json')),
    );
    Map<String, dynamic> body = {'comment[body]': content, 'commit': 'Submit'};

    await dio.patch('/comments/$id.json', data: FormData.fromMap(body));
  }

  Future<void> vote({
    required int id,
    required bool upvote,
    required bool replace,
  }) async {
    await dio.post(
      '/comments/$id/votes.json',
      queryParameters: {'score': upvote ? 1 : -1, 'no_unvote': replace},
    );
  }
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
      vote: VoteInfo(score: pick('score').asIntOrThrow()),
      warning: pick(
        'warning_type',
      ).letOrNull((pick) => WarningType.values.asNameMap()[pick.asString()]!),
      hidden: pick('is_hidden').asBoolOrThrow(),
    ),
  );
}

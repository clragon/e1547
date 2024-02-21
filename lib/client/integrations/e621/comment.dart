import 'package:dio/dio.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';

class E621CommentsClient extends CommentsClient {
  E621CommentsClient({required this.dio});

  final Dio dio;

  @override
  Set<CommentFeature> get features => {
        CommentFeature.post,
        CommentFeature.update,
        CommentFeature.vote,
        CommentFeature.report,
      };

  @override
  Future<Comment> comment({
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

  @override
  Future<List<Comment>> comments({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await dio
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
        .then((response) => response.data);

    List<Comment> comments = [];
    if (body is List<dynamic>) {
      for (Map<String, dynamic> rawComment in body) {
        comments.add(E621Comment.fromJson(rawComment));
      }
    }

    return comments;
  }

  @override
  Future<List<Comment>> commentsByPost({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    return comments(
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

  @override
  Future<void> postComment({
    required int postId,
    required String content,
  }) async {
    // TODO: implement
    /*
    await cache?.deleteFromPath(
      RegExp(RegExp.escape('/comments.json')),
      queryParams: {'search[post_id]': postId.toString()},
    );
     */

    Map<String, dynamic> body = {
      'comment[body]': content,
      'comment[post_id]': postId,
      'commit': 'Submit',
    };

    await dio.post('/comments.json', data: FormData.fromMap(body));
  }

  @override
  Future<void> updateComment({
    required int id,
    required int postId,
    required String content,
  }) async {
    // TODO: implement
    /*
    await cache?.deleteFromPath(
      RegExp(RegExp.escape('/comments.json')),
      queryParams: {'search[post_id]': postId.toString()},
    );

    await cache?.deleteFromPath(
      RegExp(RegExp.escape('/comments/$id.json')),
    );
     */

    Map<String, dynamic> body = {
      'comment[body]': content,
      'commit': 'Submit',
    };

    await dio.patch('/comments/$id.json', data: FormData.fromMap(body));
  }

  @override
  Future<void> voteComment({
    required int id,
    required bool upvote,
    required bool replace,
  }) async {
    await dio.post(
      '/comments/$id/votes.json',
      queryParameters: {
        'score': upvote ? 1 : -1,
        'no_unvote': replace,
      },
    );
  }

  @override
  Future<void> reportComment({
    required int id,
    required String reason,
  }) async {
    await dio.post(
      '/tickets',
      queryParameters: {
        'ticket[reason]': reason,
        'ticket[disp_id]': id,
        'ticket[qtype]': 'comment',
      },
      options: Options(
        validateStatus: (status) => status == 302,
      ),
    );
  }
}

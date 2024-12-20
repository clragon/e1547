import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';

abstract class CommentService {
  Future<Comment> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Comment>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Comment>> byPost({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<void> create({
    required int postId,
    required String content,
  });

  Future<void> update({
    required int id,
    required int postId,
    required String content,
  });

  Future<void> vote({
    required int id,
    required bool upvote,
    required bool replace,
  });

  Future<void> report({
    required int id,
    required String reason,
  });
}

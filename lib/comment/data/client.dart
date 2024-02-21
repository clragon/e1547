import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';

enum CommentsFeature {
  post,
  update,
  vote,
  report,
}

// TODO: rename all the methods to be type agnostic
abstract class CommentsClient with FeatureFlagging<CommentsFeature> {
  Future<Comment> comment({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Comment>> comments({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Comment>> commentsByPost({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<void> postComment({
    required int postId,
    required String content,
  }) =>
      throwUnsupported(CommentsFeature.post);

  Future<void> updateComment({
    required int id,
    required int postId,
    required String content,
  }) =>
      throwUnsupported(CommentsFeature.update);

  Future<void> voteComment({
    required int id,
    required bool upvote,
    required bool replace,
  }) =>
      throwUnsupported(CommentsFeature.vote);

  Future<void> reportComment({
    required int id,
    required String reason,
  }) =>
      throwUnsupported(CommentsFeature.report);
}

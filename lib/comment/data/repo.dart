import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/shared/shared.dart';

class CommentRepo {
  CommentRepo({required this.persona, required this.client});

  final Persona persona;
  final CommentClient client;

  Future<Comment> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) => client.get(id: id, force: force, cancelToken: cancelToken);

  Future<List<Comment>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => client.page(
    page: page,
    limit: limit,
    query: query,
    force: force,
    cancelToken: cancelToken,
  );

  Future<List<Comment>> byPost({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  }) => client.byPost(
    id: id,
    page: page,
    limit: limit,
    ascending: ascending,
    force: force,
    cancelToken: cancelToken,
  );

  Future<void> create({required int postId, required String content}) =>
      client.create(postId: postId, content: content);

  Future<void> update({
    required int id,
    required int postId,
    required String content,
  }) => client.update(id: id, postId: postId, content: content);

  Future<void> vote({
    required int id,
    required bool upvote,
    required bool replace,
  }) => client.vote(id: id, upvote: upvote, replace: replace);
}

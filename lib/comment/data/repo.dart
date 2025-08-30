import 'dart:async';

import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';

class CommentRepo {
  CommentRepo({
    required this.persona,
    required this.client,
    required this.cache,
  });

  final Persona persona;
  final CommentClient client;
  final CachedQuery cache;

  final String queryKey = 'comments';

  late final _commentCache = cache.bridge<Comment, int>(
    queryKey,
    fetch: (id) => get(id: id),
  );

  Future<Comment> get({required int id, CancelToken? cancelToken}) =>
      client.get(id: id, cancelToken: cancelToken);

  Query<Comment> useGet({required int id, bool? vendored}) => Query(
    cache: cache,
    key: [queryKey, id],
    queryFn: () => get(id: id),
    config: _commentCache.getConfig(vendored: vendored),
  );

  Future<List<Comment>> page({
    int? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) => client.page(
    page: page,
    limit: limit,
    query: query,
    cancelToken: cancelToken,
  );

  InfiniteQuery<List<int>, int> usePage({required QueryMap? query}) =>
      InfiniteQuery<List<int>, int>(
        cache: cache,
        key: [queryKey, query],
        getNextArg: (state) => state.nextPage,
        queryFn: (key) =>
            page(page: key, query: query).then(_commentCache.savePage),
      );

  Future<void> create({required int postId, required String content}) =>
      client.create(postId: postId, content: content);

  Mutation<void, String> useCreate({required int postId}) => Mutation(
    queryFn: (content) => create(postId: postId, content: content),
    onSuccess: (data, content) {
      // TODO: this needs to invalidate all queries with post_id
    },
  );

  Future<void> update({
    required int id,
    required int postId,
    required String content,
  }) => client.update(id: id, postId: postId, content: content);

  Mutation<void, String> useUpdate({required int id, required int postId}) =>
      Mutation(
        queryFn: (content) => _commentCache.optimistic(
          id,
          (comment) =>
              comment.copyWith(body: content, updatedAt: DateTime.now()),
          () => update(id: id, postId: postId, content: content),
        ),
      );

  Future<VoteResult> vote({
    required int id,
    required bool upvote,
    required bool replace,
  }) => client.vote(id: id, upvote: upvote, replace: replace);

  Mutation<VoteResult, VoteRequest> useVote({required int id}) => Mutation(
    queryFn: (p) {
      final (:upvote, :replace) = p;
      return _commentCache.optimistic(
        id,
        (comment) =>
            comment.copyWith(vote: comment.vote?.withVote(upvote, replace)),
        () => vote(id: id, upvote: upvote, replace: replace),
      );
    },
    onSuccess: (data, _) => _commentCache.update(
      id,
      (comment) => comment.copyWith(vote: data.info),
    ),
  );
}

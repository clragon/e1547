import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';

class CommentClient {
  CommentClient({required this.dio, required this.cache});

  final Dio dio;
  final PagedValueCache<QueryKey, int, Comment> cache;

  Future<Comment> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) => cache.items
      .stream(
        id,
        fetch: () => dio
            .get('/comments/$id.json', cancelToken: cancelToken)
            .then((response) => E621Comment.fromJson(response.data)),
        force: force,
      )
      .future;

  Future<List<Comment>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    final queryMap = {'page': page, 'limit': limit, ...?query};

    return cache
        .stream(
          QueryKey(queryMap),
          fetch: () => dio
              .get(
                '/comments.json',
                queryParameters: queryMap,
                cancelToken: cancelToken,
              )
              .then((response) {
                if (response.data is List<dynamic>) {
                  return response.data
                      .map<Comment>(E621Comment.fromJson)
                      .toList();
                }
                return <Comment>[];
              }),
          force: force,
        )
        .future;
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
    query: {
      'group_by': 'comment',
      'search[post_id]': id.toString(),
      'search[order]': ascending ?? false ? 'id_asc' : 'id_desc',
    },
    force: force,
    cancelToken: cancelToken,
  );

  Future<void> create({required int postId, required String content}) => dio
      .post(
        '/comments.json',
        data: FormData.fromMap({
          'comment[body]': content,
          'comment[post_id]': postId,
          'commit': 'Submit',
        }),
      )
      .then(
        (_) => cache.keys
            .where((key) => key.find('search[post_id]', postId))
            .forEach(cache.invalidate),
      );

  Future<void> update({
    required int id,
    required int postId,
    required String content,
  }) => cache.items.optimistic(
    id,
    (comment) => comment.copyWith(
      postId: postId,
      body: content,
      updatedAt: DateTime.now(),
    ),
    () => dio.patch(
      '/comments/$id.json',
      data: FormData.fromMap({'comment[body]': content, 'commit': 'Submit'}),
    ),
  );

  Future<void> vote({
    required int id,
    required bool upvote,
    required bool replace,
  }) => cache.items.optimistic(
    id,
    (comment) {
      final currentScore = comment.vote?.score ?? 0;
      final newScore = upvote ? currentScore + 1 : currentScore - 1;
      return comment.copyWith(vote: VoteInfo(score: newScore));
    },
    () => dio.post(
      '/comments/$id/votes.json',
      queryParameters: {'score': upvote ? 1 : -1, 'no_unvote': replace},
    ),
  );
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

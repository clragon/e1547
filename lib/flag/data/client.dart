import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/flag/flag.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';

class FlagClient {
  FlagClient({required this.dio});

  final Dio dio;
  final PagedValueCache<QueryKey, int, PostFlag> cache = PagedValueCache(
    toId: (flag) => flag.id,
    size: null,
    maxAge: const Duration(minutes: 5),
  );

  Future<List<PostFlag>> list({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    final queryMap = {'page': page, 'limit': limit, ...?query};

    return cache
        .stream(
          QueryKey([queryMap]),
          fetch: () => dio
              .get(
                '/post_flags.json',
                queryParameters: queryMap,
                cancelToken: cancelToken,
              )
              .then((response) {
                return pick(response.data).asListOrThrow(
                  (p0) => E621PostFlag.fromJson(p0.asMapOrThrow()),
                );
              }),
        )
        .future;
  }

  Future<void> create(int postId, String flag, {int? parent}) => dio.post(
    '/post_flags.json',
    queryParameters: {
      'post_flag[post_id]': postId,
      'post_flag[reason_name]': flag,
      if (flag == 'inferior' && parent != null) 'post_flag[parent_id]': parent,
    },
  );

  void dispose() {
    cache.dispose();
  }
}

extension E621PostFlag on PostFlag {
  static PostFlag fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => PostFlag(
      id: pick('id').asIntOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      postId: pick('post_id').asIntOrThrow(),
      reason: pick('reason').asStringOrThrow(),
      creatorId: pick('creator_id').asIntOrThrow(),
      isResolved: pick('is_resolved').asBoolOrThrow(),
      updatedAt: pick('updated_at').asDateTimeOrThrow(),
      isDeletion: pick('is_deletion').asBoolOrThrow(),
      type: pick('category').asStringOrThrow() == 'deletion'
          ? PostFlagType.deletion
          : PostFlagType.flag,
    ),
  );
}

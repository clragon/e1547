import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/user/user.dart';

class E621PoolsClient extends PoolsClient {
  E621PoolsClient({
    required this.dio,
    required this.postsClient,
    this.accountsClient,
  });

  final Dio dio;
  final PostsClient postsClient;
  final AccountsClient? accountsClient;

  @override
  Future<Pool> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/pools/$id.json',
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) => E621Pool.fromJson(response.data),
          );

  @override
  Future<List<Pool>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/pools.json',
            queryParameters: {
              'page': page,
              'limit': limit,
              ...?query,
            },
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) => pick(response.data).asListOrThrow(
              (e) => E621Pool.fromJson(e.asMapOrThrow()),
            ),
          );

  @override
  Future<List<Post>> byPool({
    required int id,
    int? page,
    int? limit,
    bool orderByOldest = true,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    page ??= 1;
    int limit = 75;
    // store per page count in Traits
    limit = await accountsClient?.get().then((e) => e?.perPage) ?? limit;
    Pool pool = await get(id: id, force: force, cancelToken: cancelToken);
    List<int> ids = pool.postIds;
    if (!orderByOldest) ids = ids.reversed.toList();
    int lower = (page - 1) * limit;
    if (lower > ids.length) return [];
    ids = ids.sublist(lower).take(limit).toList();
    return postsClient.byIds(
      ids: ids,
      limit: limit,
      force: force,
      cancelToken: cancelToken,
    );
  }
}

extension E621Pool on Pool {
  static Pool fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Pool(
          id: pick('id').asIntOrThrow(),
          name: pick('name').asStringOrThrow(),
          createdAt: pick('created_at').asDateTimeOrThrow(),
          updatedAt: pick('updated_at').asDateTimeOrThrow(),
          description: pick('description').asStringOrThrow(),
          postIds:
              pick('post_ids').asListOrThrow((pick) => pick.asIntOrThrow()),
          postCount: pick('post_count').asIntOrThrow(),
          activity: PoolActivity(
            isActive: pick('is_active').asBoolOrThrow(),
          ),
        ),
      );
}

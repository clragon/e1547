import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';

class E621PoolsClient extends PoolsClient {
  E621PoolsClient({
    required this.dio,
    required this.postsClient,
  });

  final Dio dio;
  final PostsClient postsClient;

  @override
  Future<Pool> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await dio
        .get(
          '/pools/$id.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return E621Pool.fromJson(body);
  }

  @override
  Future<List<Pool>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    List<dynamic> body = await dio
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
        .then((response) => response.data);

    List<Pool> pools = [];
    for (Map<String, dynamic> raw in body) {
      Pool pool = E621Pool.fromJson(raw);
      pools.add(pool);
    }

    return pools;
  }

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
    /*
    Account? user = await account(cancelToken: cancelToken);
    int limit = user?.perPage ?? 75;
     */
    int limit = 75; // store per page count in Traits
    Pool pool = await this.get(id: id, force: force, cancelToken: cancelToken);
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

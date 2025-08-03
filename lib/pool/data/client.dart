import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';

class PoolClient {
  PoolClient({required this.dio});

  final Dio dio;
  final ValueCache<QueryKey, Pool> cache = ValueCache(
    size: null,
    maxAge: const Duration(minutes: 5),
  );

  Future<Pool> get({required int id, bool? force, CancelToken? cancelToken}) =>
      cache
          .stream(
            QueryKey([id]),
            fetch: () => dio
                .get('/pools/$id.json', cancelToken: cancelToken)
                .then((response) => E621Pool.fromJson(response.data)),
          )
          .future;

  Future<List<Pool>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/pools.json',
        queryParameters: {'page': page, 'limit': limit, ...?query},
        cancelToken: cancelToken,
      )
      .then(
        (response) => pick(
          response.data,
        ).asListOrThrow((e) => E621Pool.fromJson(e)).toList(),
      );

  void dispose() {
    cache.dispose();
  }
}

extension E621Pool on Pool {
  static Pool fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Pool(
      id: pick('id').asIntOrThrow(),
      name: pick('name').asStringOrThrow(),
      description: pick('description').asStringOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      updatedAt: pick('updated_at').asDateTimeOrThrow(),
      postIds: pick('post_ids').asListOrThrow((e) => e.asIntOrThrow()).toList(),
      postCount: pick('post_count').asIntOrThrow(),
      active: pick('is_active').asBoolOrThrow(),
    ),
  );
}

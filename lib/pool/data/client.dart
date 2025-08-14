import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/shared/shared.dart';

class PoolClient {
  PoolClient({required this.dio});

  final Dio dio;

  Future<Pool> get({required int id, bool? force, CancelToken? cancelToken}) =>
      dio
          .get(
            '/pools/$id.json',
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then((response) => E621Pool.fromJson(response.data));

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
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
      .then(
        (response) => pick(
          response.data,
        ).asListOrThrow((e) => E621Pool.fromJson(e.asMapOrThrow())),
      );
}

extension E621Pool on Pool {
  static Pool fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Pool(
      id: pick('id').asIntOrThrow(),
      name: pick('name').asStringOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      updatedAt: pick('updated_at').asDateTimeOrThrow(),
      description: pick('description').asStringOrThrow(),
      postIds: pick('post_ids').asListOrThrow((pick) => pick.asIntOrThrow()),
      postCount: pick('post_count').asIntOrThrow(),
      active: pick('is_active').asBoolOrThrow(),
    ),
  );
}

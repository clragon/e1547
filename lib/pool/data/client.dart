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
      .then(unwrapRailsArray)
      .then(
        (response) => (response.data as List)
            .map<Pool>((e) => E621Pool.fromJson(e))
            .toList(),
      );
}

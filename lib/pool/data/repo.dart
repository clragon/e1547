import 'dart:async';

import 'package:e1547/domain/domain.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';

class PoolRepo {
  PoolRepo({required this.persona, required this.client, required this.cache});

  final Persona persona;
  final PoolClient client;
  final CachedQuery cache;

  final String queryKey = 'pools';

  late final _poolCache = QueryBridge<Pool, int>(
    cache: cache,
    baseKey: queryKey,
    getId: (pool) => pool.id,
    fetch: (id) => get(id: id),
  );

  Future<Pool> get({required int id, CancelToken? cancelToken}) =>
      client.get(id: id, force: true, cancelToken: cancelToken);

  Query<Pool> useGet({required int id, bool? vendored}) => Query(
    cache: cache,
    key: [queryKey, id],
    queryFn: () => get(id: id),
    config: _poolCache.getConfig(vendored: vendored),
  );

  Future<List<Pool>> page({
    int? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) => client.page(
    page: page,
    limit: limit,
    query: query,
    force: true,
    cancelToken: cancelToken,
  );

  InfiniteQuery<List<int>, int> usePage({required QueryMap? query}) =>
      InfiniteQuery<List<int>, int>(
        cache: cache,
        key: [queryKey, query],
        getNextArg: (state) => state.nextPage,
        queryFn: (key) =>
            page(page: key, query: query).then(_poolCache.savePage),
      );
}

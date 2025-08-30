import 'dart:async';

import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/topic/topic.dart';

class TopicRepo {
  TopicRepo({required this.persona, required this.client, required this.cache});

  final Persona persona;
  final TopicClient client;
  final CachedQuery cache;

  final String queryKey = 'topics';

  late final _topicCache = cache.bridge<Topic, int>(
    queryKey,
    fetch: (id) => get(id: id),
  );

  Future<Topic> get({required int id, CancelToken? cancelToken}) =>
      client.get(id: id, cancelToken: cancelToken);

  Query<Topic> useGet({required int id, bool? vendored}) => Query(
    cache: cache,
    key: [queryKey, id],
    queryFn: () => get(id: id),
    config: _topicCache.getConfig(vendored: vendored),
  );

  Future<List<Topic>> page({
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
            page(page: key, query: query).then(_topicCache.savePage),
      );
}

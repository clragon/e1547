import 'dart:async';

import 'package:e1547/domain/domain.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';

class FollowRepo with Disposable {
  FollowRepo({
    required this.persona,
    required this.client,
    required this.cache,
  });

  final Persona persona;
  final FollowClient client;
  final CachedQuery cache;

  final String queryKey = 'follows';

  late final _followCache = cache.bridge<Follow, int>(
    queryKey,
    fetch: (id) => get(id: id),
  );

  Future<Follow> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) => client.get(id);

  Query<Follow> useGet({required int id, bool? vendored}) => Query(
    cache: cache,
    key: [queryKey, id],
    queryFn: () => get(id: id),
    config: _followCache.getConfig(vendored: vendored),
  );

  Future<Follow?> getByTags({
    required String tags,
    bool? force,
    CancelToken? cancelToken,
  }) => client.getByTags(tags, persona.identity.id);

  Query<Follow?> useGetByTags({required String tags}) => Query(
    cache: cache,
    key: [queryKey, 'by_tags', tags],
    queryFn: () => getByTags(tags: tags),
  );

  Future<List<Follow>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    return client.page(
      identity: persona.identity.id,
      page: page,
      limit: limit,
      query: query,
    );
  }

  InfiniteQuery<List<int>, int> usePage({required QueryMap? query}) =>
      InfiniteQuery<List<int>, int>(
        cache: cache,
        key: [queryKey, query],
        getNextArg: (state) => state.nextPage,
        queryFn: (key) =>
            page(page: key, query: query).then(_followCache.savePage),
      );

  Future<List<Follow>> all({
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    return client.all(identity: persona.identity.id, query: query);
  }

  Future<void> create({
    required String tags,
    required FollowType type,
    String? title,
    String? alias,
  }) => client.add(
    FollowRequest(tags: tags, type: type, title: title, alias: alias),
    persona.identity.id,
  );

  Mutation<void, FollowRequest> useCreate() => Mutation(
    mutationFn: (request) => client.add(request, persona.identity.id),
    onSuccess: (_, __) => cache.invalidateCache(
      filterFn: (key, _) => key is List && key.first == queryKey,
    ),
  );

  Future<void> update(FollowUpdate followUpdate) =>
      client.updateFollow(followUpdate);

  Mutation<void, FollowUpdate> useUpdate() => Mutation(
    mutationFn: (followUpdate) => update(followUpdate),
    onSuccess: (_, __) => cache.invalidateCache(
      filterFn: (key, _) => key is List && key.first == queryKey,
    ),
  );

  Future<void> markSeen(List<int>? ids) =>
      client.markAllSeen(ids: ids, identity: persona.identity.id);

  Mutation<void, List<int>?> useMarkSeen() => Mutation(
    mutationFn: (ids) => markSeen(ids),
    onSuccess: (_, __) => cache.invalidateCache(
      filterFn: (key, _) => key is List && key.first == queryKey,
    ),
  );

  Future<void> delete(int id) => client.remove(id);

  Mutation<void, int> useDelete() => Mutation(
    mutationFn: (id) => delete(id),
    onSuccess: (_, __) => cache.invalidateCache(
      filterFn: (key, _) => key is List && key.first == queryKey,
    ),
  );

  Future<int> count() => client.length(identity: persona.identity.id);

  Query<int> useCount() =>
      Query(cache: cache, key: [queryKey, 'count'], queryFn: () => count());
}

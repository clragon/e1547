import 'dart:async';

import 'package:cached_query_flutter/cached_query_flutter.dart';
export 'package:cached_query_flutter/cached_query_flutter.dart';

/// Cache normalisation intermediary
class QueryBridge<T, K> {
  QueryBridge({
    required this.cache,
    required this.baseKey,
    required this.getId,
    required this.fetch,
  });

  final CachedQuery cache;
  final String baseKey;
  final K Function(T) getId;

  final Future<T> Function(K) fetch;

  Query<T>? _getQuery(K id) => cache.getQuery<Query<T>>([baseKey, id]);

  // TODO: delete this once https://github.com/D-James-GH/cached_query/issues/75 is resolved
  Query<T> _createQuery(K id) => Query<T>(
    cache: cache,
    key: [baseKey, id],
    queryFn: () => fetch(id),
    config: getConfig(vendored: true),
  );

  static ShouldFetch<T> vendorFetch<T>(bool? vendored) =>
      (key, data, createdAt) => !(vendored ?? false);

  QueryConfig<T> getConfig({bool? vendored}) =>
      QueryConfig(shouldFetch: vendorFetch<T>(vendored));

  T? get(K id) {
    final itemQuery = _getQuery(id);
    return itemQuery?.state.data;
  }

  void update(K id, T Function(T) updateFn) {
    final itemQuery = _getQuery(id);
    if (itemQuery != null) {
      final current = itemQuery.state.data;
      if (current != null) {
        final updated = updateFn(current);
        if (updated != current) {
          itemQuery.setData(updated);
        }
      }
    }
  }

  void set(T item) => update(getId(item), (current) => item);

  List<K> savePage(List<T> items) {
    for (final item in items) {
      final itemQuery = _getQuery(getId(item)) ?? _createQuery(getId(item));
      itemQuery.setData(item);
    }
    return items.map(getId).toList();
  }

  Future<R> optimistic<R>(
    K id,
    T Function(T) updateFn,
    Future<R> Function() callback,
  ) async {
    final itemQuery = _getQuery(id);
    if (itemQuery == null) return callback();

    final current = itemQuery.state.data;
    if (current == null) return callback();

    T previous = current;
    try {
      final updated = updateFn(current);
      if (updated != current) {
        itemQuery.setData(updated);
      }
      final result = await callback();
      return result;
    } on Object {
      itemQuery.setData(previous);
      rethrow;
    }
  }

  void invalidate(K id) {
    final itemQuery = _getQuery(id);
    itemQuery?.invalidate();
  }
}

extension QueryCacheBridging on CachedQuery {
  static K _dynamicGetId<T, K>(T item) {
    try {
      return (item as dynamic).id as K;
      // ignore: avoid_catching_errors
    } on NoSuchMethodError {
      throw ArgumentError(
        'Item does not have an id property. '
        'Either add an id property to the item or provide a custom getId function.',
      );
    }
  }

  QueryBridge<T, K> bridge<T, K>(
    String key, {
    K Function(T)? getId,
    required Future<T> Function(K) fetch,
  }) => QueryBridge(
    cache: this,
    baseKey: key,
    getId: getId ?? _dynamicGetId,
    fetch: fetch,
  );
}

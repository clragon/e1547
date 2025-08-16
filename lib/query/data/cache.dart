import 'package:cached_query/cached_query.dart';

typedef InfiniteListQuery<T> = InfiniteQuery<List<T>, int>;

class CacheSync<T, K> {
  CacheSync({
    required this.cache,
    required this.baseKey,
    required this.getId,
    required this.getItem,
  });

  final CachedQuery cache;
  final String baseKey;
  final K Function(T) getId;
  final Future<T> Function(K) getItem;

  List<K> populateFromPage(List<T> items) {
    for (final item in items) {
      final queryKey = [baseKey, getId(item)];
      var itemQuery = cache.getQuery<Query<T>>(queryKey);
      itemQuery ??= Query<T>(
        cache: cache,
        key: queryKey,
        initialData: item,
        queryFn: () => getItem(getId(item)),
      );
      itemQuery.setData(item);
    }
    return items.map(getId).toList();
  }

  void updateItem(K id, T Function(T) updateFn) {
    final itemQuery = cache.getQuery<Query<T>>([baseKey, id]);
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

  void setItem(T item) => updateItem(getId(item), (current) => item);
}

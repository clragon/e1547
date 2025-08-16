import 'package:cached_query/cached_query.dart';

typedef InfiniteListQuery<T> = InfiniteQuery<List<T>, int>;

class CacheSync<T, K> {
  CacheSync({required this.baseKey, required this.getId});

  static int _r = 0;

  final String baseKey;
  final K Function(T) getId;

  void updateItem(K id, T Function(T) updateFn) {
    _r++;
    print('re-entrant update: $_r');

    final singleQuery = CachedQuery.instance.getQuery<Query<T>>([baseKey, id]);

    if (singleQuery != null) {
      final current = singleQuery.state.data;
      if (current != null) {
        final updated = updateFn(current);
        if (updated != current) {
          singleQuery.setData(updated);
        }
      }
    }

    _updateInfiniteQueries(id, updateFn);
  }

  void setItem(T item) => updateItem(getId(item), (current) => item);

  void setItems(List<T> items) {
    for (final item in items) {
      setItem(item);
    }
  }

  void _updateInfiniteQueries(K id, T Function(T) updateFn) {
    final infiniteQueries = CachedQuery.instance
        .whereQuery(
          (query) => switch (query) {
            InfiniteListQuery<T> q =>
              (q.state.data?.pages.isNotEmpty ?? false) &&
                  switch (q.unencodedKey) {
                    List e => e.firstOrNull == baseKey,
                    _ => false,
                  },
            _ => false,
          },
        )
        ?.cast<InfiniteListQuery<T>>();

    infiniteQueries?.forEach((query) {
      final currentData = query.state.data!;
      bool changed = false;
      final updatedPages = currentData.pages.map((page) {
        return page.map((item) {
          if (getId(item) == id) {
            final updated = updateFn(item);
            if (updated != item) {
              if (updated.toString() == item.toString()) {
                print('something went wrong.');
                return item;
              }
              changed = true;
            }
            return updated;
          }
          return item;
        }).toList();
      }).toList();

      print(
        'Updating infinite query: ${query.unencodedKey}, changed: $changed',
      );

      if (!changed) return;

      query.setData(
        InfiniteQueryData(
          pages: updatedPages,
          pageParams: currentData.pageParams,
        ),
      );
    });
  }
}

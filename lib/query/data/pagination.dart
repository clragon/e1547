import 'package:e1547/query/query.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

extension PagingStateQuery<PageKeyType, ItemType>
    on UseInfiniteQueryResult<List<ItemType>, dynamic, PageKeyType> {
  PagingState<PageKeyType, ItemType> get paging =>
      PagingState<PageKeyType, ItemType>(
        keys: data?.pageParams,
        pages: data?.pages,
        error: error,
        hasNextPage: hasNextPage,
        isLoading: isLoading,
      );
}

extension FilterPagingStateExtension<PageKeyType, ItemType>
    on PagingState<PageKeyType, ItemType> {
  PagingState<PageKeyType, ItemType> filter(BuildContext context) {
    // TODO: apply blacklist here?
    return copyWith(
      pages: pages?.deduplicate(),
    );
  }
}

int? getNextIntPageParam(
  List<Object> data,
  List<List<Object>> pages,
  int pageParam,
  List<int> pageParams,
) {
  if (pages.isEmpty) return null;
  return pageParam + 1;
}

extension DeepListDeduplicationExtension<T> on List<List<T>> {
  List<List<T>> deduplicate({Object? Function(T item)? getKey}) {
    getKey ??= _getKey<T>;

    final seenKeys = <Object?>{};
    final result = <List<T>>[];

    // We want to keep the latest item, therefore we reverse the list.
    for (final page in reversed) {
      final newPage = <T>[];

      for (final item in page) {
        final key = getKey(item);
        if (!seenKeys.contains(key)) {
          newPage.add(item);
          seenKeys.add(key);
        }
      }

      result.insert(0, newPage);
    }

    return result;
  }

  static Object? _getKey<E>(E item) {
    try {
      return (item as dynamic).id;
      // ignore: avoid_catching_errors
    } on NoSuchMethodError {
      return item;
    }
  }
}

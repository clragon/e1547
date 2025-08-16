import 'package:cached_query/cached_query.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

extension QueryPagingState<T, Arg> on InfiniteQueryStatus<List<T>, Arg> {
  PagingState<Arg, T> get paging {
    return PagingState(
      pages: data?.pages,
      keys: data?.pageParams,
      error: error,
      isLoading: isLoading,
      hasNextPage: data?.lastPage?.isNotEmpty ?? true, // grrrrr
    );
  }
}

extension QueryStatusErroring<T> on QueryStatus<T> {
  Object? get error {
    return switch (this) {
      QueryError e => e.error,
      _ => null,
    };
  }
}

extension InfiniteQueryStatusErroring<T, Arg>
    on InfiniteQueryStatus<List<T>, Arg> {
  Object? get error {
    return switch (this) {
      InfiniteQueryError e => e.error,
      _ => null,
    };
  }
}

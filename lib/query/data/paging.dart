import 'package:e1547/query/query.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

extension QueryDataPagingState<T, Arg> on InfiniteQueryData<List<T>, Arg>? {
  bool get hasNextPage => this?.lastPage?.isNotEmpty ?? true;
}

extension QueryPagingState<T, Arg> on InfiniteQueryStatus<List<T>, Arg> {
  bool get hasNextPage => data.hasNextPage;

  PagingState<Arg, T> get paging {
    return PagingState(
      pages: data?.pages,
      keys: data?.args,
      error: error,
      isLoading: isLoading,
      hasNextPage: hasNextPage,
    );
  }
}

extension QueryDataIntPagingState<T> on InfiniteQueryData<List<T>, int>? {
  int? get nextPage => hasNextPage ? (this?.args.lastOrNull ?? 0) + 1 : null;
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

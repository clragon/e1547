import 'dart:async';

import 'package:e1547/query/query.dart';
import 'package:flutter/material.dart';

typedef GetItemQuery<T> = Query<T> Function(int id);

typedef PageQueryBuilderCallback<T, Arg> =
    Widget Function(
      BuildContext context,
      InfiniteQueryStatus<List<T>, Arg> state,
      InfiniteQuery<List<Arg>, Arg> query,
    );

class PagedQueryBuilder<T, Arg> extends StatefulWidget {
  const PagedQueryBuilder({
    super.key,
    required this.query,
    required this.getItem,
    required this.builder,
  });

  final InfiniteQuery<List<int>, Arg> query;
  final GetItemQuery<T> getItem;
  final QueryBuilderCallback<InfiniteQueryStatus<List<T>, Arg>> builder;

  @override
  State<PagedQueryBuilder<T, Arg>> createState() =>
      _PagedQueryBuilderState<T, Arg>();
}

class _PagedQueryBuilderState<T, Arg> extends State<PagedQueryBuilder<T, Arg>> {
  final Map<int, StreamSubscription<QueryState<T>>> subscriptions = {};
  final Map<int, T?> items = {};

  InfiniteQueryStatus<List<int>, Arg>? lastState;
  InfiniteQueryStatus<List<T>, Arg>? cachedState;

  @override
  void dispose() {
    for (final subscription in subscriptions.values) {
      subscription.cancel();
    }
    subscriptions.clear();
    items.clear();
    super.dispose();
  }

  void subscribeToItem(int id) {
    if (subscriptions.containsKey(id)) return;

    final itemQuery = widget.getItem(id);
    subscriptions[id] = itemQuery.stream.listen((state) {
      setState(() {
        items[id] = state.data;
        cachedState = null;
      });
    });

    items[id] = itemQuery.state.data;
  }

  void unsubscribeFromItem(int id) {
    subscriptions[id]?.cancel();
    subscriptions.remove(id);
    items.remove(id);
  }

  InfiniteQueryStatus<List<T>, Arg> resolveState(
    InfiniteQueryStatus<List<int>, Arg> state,
  ) {
    if (cachedState != null && lastState == state) {
      return cachedState!;
    }

    final pages = state.data?.pages ?? <List<int>>[];

    final allIds = pages.expand((page) => page).toSet();

    for (final id in allIds) {
      subscribeToItem(id);
    }

    final idsToRemove = subscriptions.keys
        .where((id) => !allIds.contains(id))
        .toList();

    for (final id in idsToRemove) {
      unsubscribeFromItem(id);
    }

    final resolvedPages = <List<T>>[];

    for (final page in pages) {
      final resolvedPage = <T>[];
      for (final id in page) {
        final item = items[id];
        if (item != null) {
          resolvedPage.add(item);
        }
      }
      resolvedPages.add(resolvedPage);
    }

    final data = resolvedPages.isNotEmpty
        ? InfiniteQueryData<List<T>, Arg>(
            pages: resolvedPages,
            pageParams: state.data?.pageParams ?? <Arg>[],
          )
        : null;

    final resolved = switch (state) {
      InfiniteQueryInitial() => InfiniteQueryStatus<List<T>, Arg>.initial(
        timeCreated: state.timeCreated,
        data: data,
      ),
      InfiniteQueryLoading() => InfiniteQueryStatus<List<T>, Arg>.loading(
        timeCreated: state.timeCreated,
        data: data,
        isRefetching: state.isRefetching,
        isFetchingNextPage: state.isFetchingNextPage,
        isInitialFetch: state.isInitialFetch,
      ),
      InfiniteQuerySuccess() => InfiniteQueryStatus<List<T>, Arg>.success(
        timeCreated: state.timeCreated,
        data: data!,
      ),
      InfiniteQueryError() => InfiniteQueryStatus<List<T>, Arg>.error(
        timeCreated: state.timeCreated,
        data: data,
        error: state.error,
        stackTrace: state.stackTrace,
      ),
    };

    lastState = state;
    cachedState = resolved;

    return resolved;
  }

  @override
  Widget build(BuildContext context) => QueryBuilder(
    query: widget.query,
    builder: (context, state) {
      final resolved = resolveState(state);
      return widget.builder(context, resolved);
    },
  );
}

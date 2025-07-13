import 'dart:async';

import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// A [PagingController] that supports [StreamFuture].
/// For implementation details and reasoning, directly refer to [PagingController].
class StreamPagingController<PageKeyType, ItemType>
    extends PagingController<PageKeyType, ItemType> {
  StreamPagingController({
    super.value,
    required super.getNextPageKey,
    required super.fetchPage,
  })  : _getNextPageKey = getNextPageKey,
        _fetchPage = fetchPage;

  final NextPageKeyCallback<PageKeyType, ItemType> _getNextPageKey;
  final FetchPageCallback<PageKeyType, ItemType> _fetchPage;

  final Map<PageKeyType, Stream<List<ItemType>>> _streams = {};
  final Map<PageKeyType, StreamSubscription<List<ItemType>>> _subscriptions =
      {};

  @override
  @protected
  @visibleForTesting
  Object? operation;

  @override
  set value(PagingState<PageKeyType, ItemType> newValue) {
    assert(
      newValue.pages == null || newValue.pages!.length == _streams.length,
      'StreamPagingController: Mismatch between pages (${newValue.pages?.length}) '
      'and active streams (${_streams.length}). This likely indicates improper manual state manipulation. '
      'Avoid setting the value directly; Trigger cache updates through mutation methods instead.',
    );
    super.value = newValue;
  }

  @override
  void fetchNextPage() async {
    if (this.operation != null) return;

    final operation = this.operation = Object();

    value = value.copyWith(
      isLoading: true,
      error: null,
    );

    PagingState<PageKeyType, ItemType> state = value;

    try {
      if (!state.hasNextPage) return;

      final nextPageKey = _getNextPageKey(state);

      if (nextPageKey == null) {
        state = state.copyWith(hasNextPage: false);
        return;
      }

      final fetchResult = _fetchPage(nextPageKey);
      final stream = StreamFuture.from(fetchResult).stream;
      final keepAlive = stream.listen((_) {});

      List<ItemType> newItems;

      if (fetchResult is Future<List<ItemType>>) {
        if (stream is ValueStream<List<ItemType>> && stream.hasValue) {
          newItems = stream.value;
        } else {
          newItems = await fetchResult;
        }
      } else {
        newItems = fetchResult;
      }

      state = value;

      state = state.copyWith(
        pages: [...?state.pages, newItems],
        keys: [...?state.keys, nextPageKey],
      );

      _streams[nextPageKey] = stream;
      _subscriptions[nextPageKey] = _streams[nextPageKey]!.listen(
        (items) {
          final index = value.keys?.indexOf(nextPageKey);
          if (index == null || index < 0) return;

          final updatedPages = [...?value.pages];
          updatedPages[index] = items;
          value = value.copyWith(
            pages: updatedPages,
            keys: [...?value.keys],
            isLoading: false,
          );
        },
      );
      keepAlive.cancel();
    } finally {
      if (operation == this.operation) {
        value = state.copyWith(isLoading: false);
        this.operation = null;
      }
    }
  }

  void _disposeStreams() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    _streams.clear();
  }

  @override
  void refresh() {
    _disposeStreams();
    operation = null;
    value = value.reset();
  }

  @override
  void dispose() {
    _disposeStreams();
    super.dispose();
  }
}

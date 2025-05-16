import 'dart:async';

import 'package:deep_pick/deep_pick.dart';
import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

abstract class ClientDataController<KeyType, ItemType>
    extends DataController<KeyType, ItemType> {
  ClientDataController({required super.firstPageKey});

  Client get client;

  CancelToken _cancelToken = CancelToken();
  CancelToken get cancelToken => _cancelToken;

  final Logger _logger = Logger('ClientController');

  @protected
  Future<List<ItemType>> fetch(KeyType page, bool force);

  @protected
  Future<void> evictCache() => fetch(firstPageKey, true);

  @override
  Future<void> getNextPage({
    bool force = false,
    bool reset = false,
    bool background = false,
  }) {
    if (reset) {
      _cancelToken.cancel('$runtimeType is refreshing');
      _cancelToken = CancelToken();
    }
    return super.getNextPage(
      force: force,
      reset: reset,
      background: background,
    );
  }

  @protected
  Future<PageResponse<KeyType, ItemType>> withError(
    Future<PageResponse<KeyType, ItemType>> Function() call,
  ) async {
    try {
      // this must be awaited for the catch to work.
      return await call();
    } on ClientException catch (e) {
      return PageResponse.error(error: e);
    } on PickException catch (e, s) {
      _logger.severe(e.message, e, s);
      return PageResponse.error(error: e);
    } on DriftWrappedException catch (e, s) {
      _logger.severe(e.message, e, s);
      return PageResponse.error(error: e);
    } on DriftRemoteException catch (e) {
      _logger.severe(e, e.remoteCause, e.remoteStackTrace);
      return PageResponse.error(error: e);
    }
  }

  @override
  void dispose() {
    _cancelToken.cancel('$runtimeType was disposed');
    super.dispose();
  }
}

abstract class PageClientDataController<T> extends ClientDataController<int, T>
    with StreamableClientDataController {
  /// A [DataController] that uses positive integers as page keys.
  PageClientDataController({super.firstPageKey = 1});

  @override
  Future<PageResponse<int, T>> performRequest(int page, bool force) async =>
      withError(() async {
        List<T> items = await withStream(fetch(page, force));
        if (items.isEmpty) {
          return PageResponse.last(items: items);
        } else {
          return PageResponse(items: items, nextPageKey: page + 1);
        }
      });
}

mixin StreamableClientDataController<KeyType, ItemType>
    on ClientDataController<KeyType, ItemType> {
  final List<Stream<List<ItemType>>> _streams = [];
  StreamSubscription<List<ItemType>>? _subscription;

  @protected
  Object getId(ItemType item) {
    try {
      return (item as dynamic)?.id;
    }
    // ignore: avoid_catching_errors
    on NoSuchMethodError {
      throw UnsupportedError(
        'getId must be implemented if the item type does not have an id field.',
      );
    }
  }

  /// Called when a stream emits a new list of items.
  ///
  /// This method will update the items in the controller's list.
  void _onItemUpdate(List<ItemType> items) {
    if (rawItems == null) return;
    rawItems = items;
  }

  @protected
  Future<List<ItemType>> withStream(Future<List<ItemType>> result) async {
    if (result is! StreamFuture<List<ItemType>>) return result;

    _streams.add(result.stream);

    _subscription?.cancel();
    _subscription = CombineLatestStream<List<ItemType>, List<ItemType>>(
      _streams,
      (items) => items.expand((e) => e).toList(),
    ).listen(
      _onItemUpdate,
      onError: (e) => error = e,
      onDone: () => _subscription?.cancel(),
    );

    return result;
  }

  @override
  void onPreRequest(bool force, bool reset, bool background) {
    if (reset) {
      _streams.clear();
      _subscription?.cancel();
    }
    super.onPreRequest(force, reset, background);
  }

  @override
  void dispose() {
    _streams.clear();
    _subscription?.cancel();
    super.dispose();
  }
}

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/foundation.dart';

abstract class ClientDataController<KeyType, ItemType>
    extends DataController<KeyType, ItemType> {
  ClientDataController({required super.firstPageKey});

  Client get client;

  CancelToken _cancelToken = CancelToken();
  CancelToken get cancelToken => _cancelToken;

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
      Future<PageResponse<KeyType, ItemType>> Function() call) async {
    try {
      // this must be awaited for the catch to work.
      return await call();
    } on ClientException catch (e) {
      return PageResponse.error(error: e);
    }
  }

  @override
  void dispose() {
    _cancelToken.cancel('$runtimeType was disposed');
    super.dispose();
  }
}

abstract class PageClientDataController<T>
    extends ClientDataController<int, T> {
  /// A [DataController] that uses positive integers as page keys.
  PageClientDataController({super.firstPageKey = 1});

  @override
  Future<PageResponse<int, T>> performRequest(
    int page,
    bool force,
  ) async =>
      withError(
        () async {
          List<T> items = await fetch(page, force);
          if (items.isEmpty) {
            return PageResponse.last(items: items);
          } else {
            return PageResponse(items: items, nextPageKey: page + 1);
          }
        },
      );
}

import 'dart:math';

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
  Future<void> getNextPage({bool reset = false, bool background = false}) {
    if (reset) {
      _cancelToken.cancel('$runtimeType is refreshing');
      _cancelToken = CancelToken();
    }
    return super.getNextPage(reset: reset, background: background);
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

abstract class CursorClientDataController<T>
    extends ClientDataController<String, T> {
  CursorClientDataController({
    bool? orderByOldest,
  })  : _orderByOldest = orderByOldest ?? true,
        super(firstPageKey: _defaultPage);

  static const String _defaultPage = 'default';
  static const String _cursorFirstPage = 'a0';
  static const String _indexFirstPage = '1';

  bool _orderByOldest;
  bool get orderByOldest => _orderByOldest;
  set orderByOldest(bool value) {
    if (_orderByOldest == value) return;
    _orderByOldest = value;
    notifyListeners();
    refresh();
  }

  @protected
  int getId(T item);

  @override
  Future<PageResponse<String, T>> performRequest(
    String page,
    bool force,
  ) async =>
      withError(
        () async {
          if (page == _defaultPage) {
            page = orderByOldest ? _cursorFirstPage : _indexFirstPage;
          }
          List<T> items = await fetch(page, force);
          if (orderByOldest) {
            items.sort((a, b) => getId(a).compareTo(getId(b)));
          }
          if (items.isEmpty) {
            return PageResponse.last(items: items);
          } else {
            return PageResponse(
              items: items,
              nextPageKey: _getNextpageKey(page, items),
            );
          }
        },
      );

  String _getNextpageKey(String current, List<T> items) {
    if (orderByOldest) {
      if (items.isEmpty) return _cursorFirstPage;
      return 'a${items.map((e) => getId(e)).reduce(max)}';
    } else {
      return (int.parse(current) + 1).toString();
    }
  }
}

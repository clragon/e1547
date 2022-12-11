import 'dart:math';

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/foundation.dart';

mixin ClientDataController<KeyType, ItemType>
    on DataController<KeyType, ItemType> {
  Client get client;

  @protected
  Future<List<ItemType>> fetch(KeyType page, bool force);

  // TODO: actually only erase cache and do not refetch data
  @protected
  Future<void> evictCache() => fetch(firstPageKey, true);

  final CancelToken _cancelToken = CancelToken();

  CancelToken get cancelToken => ReadOnlyCancelToken(_cancelToken);

  @override
  void dispose() {
    _cancelToken.cancel('$runtimeType was disposed');
    super.dispose();
  }

  @protected
  Future<PageResponse<KeyType, ItemType>> withError(
      Future<PageResponse<KeyType, ItemType>> Function() call) async {
    try {
      // this must be awaited for the catch to work.
      return await call();
    } on DioError catch (e) {
      return PageResponse.error(error: e);
    }
  }
}

abstract class PageClientDataController<T> extends DataController<int, T>
    with ClientDataController<int, T> {
  /// A [DataController] that uses positive integers as page keys.
  PageClientDataController({super.firstPageKey = 1});

  @override
  Future<PageResponse<int, T>> requestPage(int page, bool force) async =>
      withError(
        () async {
          List<T> items = await fetch(page, force);
          if (items.isEmpty) {
            return PageResponse.last(itemList: items);
          } else {
            return PageResponse(itemList: items, nextPageKey: page + 1);
          }
        },
      );
}

abstract class CursorClientDataController<T> extends DataController<String, T>
    with ClientDataController<String, T> {
  CursorClientDataController() : super(firstPageKey: _cursorFirstPage);

  ValueNotifier<bool> orderByOldest = ValueNotifier(true);

  static const String _cursorFirstPage = 'a0';
  static const String _indexFirstPage = '1';

  @override
  String get firstPageKey =>
      orderByOldest.value ? _cursorFirstPage : _indexFirstPage;

  @protected
  int getId(T item);

  @override
  Future<PageResponse<String, T>> requestPage(String page, bool force) async =>
      withError(
        () async {
          List<T> items = await fetch(page, force);
          if (items.isEmpty) {
            return PageResponse.last(itemList: items);
          } else {
            return PageResponse(
              itemList: items,
              nextPageKey: _getNextpageKey(page, items),
            );
          }
        },
      );

  String _getNextpageKey(String current, List<T> items) {
    if (orderByOldest.value) {
      if (items.isEmpty) return _cursorFirstPage;
      return 'a${items.map((e) => getId(e)).reduce(max).toString()}';
    } else {
      return (int.parse(current) + 1).toString();
    }
  }

  @override
  @protected
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(orderByOldest);

  @override
  set value(PagingState<String, T> state) {
    List<T>? newItems = state.itemList;
    if (newItems != null && orderByOldest.value) {
      newItems.sort((a, b) => getId(a).compareTo(getId(b)));
    }
    super.value = PagingState(
      nextPageKey: state.nextPageKey,
      itemList: newItems,
      error: state.error,
    );
  }
}

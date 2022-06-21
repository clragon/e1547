import 'dart:async';
import 'dart:math';

import 'package:e1547/client/client.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mutex/mutex.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class RawDataController<KeyType, ItemType>
    extends PagingController<KeyType, ItemType> {
  final Mutex _requestLock = Mutex();
  bool _isRefreshing = false;
  bool _isForceRefreshing = false;
  bool _disposed = false;

  late final List<Listenable> _refreshListeners = getRefreshListeners();

  RawDataController({required super.firstPageKey}) {
    super.addPageRequestListener(loadPage);
    _refreshListeners.forEach((element) => element.addListener(refresh));
  }

  @override
  void dispose() {
    super.removePageRequestListener(loadPage);
    _refreshListeners.forEach((element) => element.removeListener(refresh));
    _disposed = true;
    super.dispose();
  }

  @mustCallSuper
  @protected
  void failure(Exception error) {
    this.error = error;
  }

  @mustCallSuper
  @protected
  void success() {}

  @mustCallSuper
  @protected
  List<Listenable> getRefreshListeners() => [];

  @protected
  Future<List<ItemType>> provide(KeyType page, bool force);

  @protected
  KeyType provideNextPageKey(KeyType current, List<ItemType> items);

  @protected
  List<ItemType> sort(List<ItemType> items) => items;

  @mustCallSuper
  @protected
  void assertHasItems() {
    if (itemList == null) {
      throw StateError(
          'Controller cannot modify item when the itemList is empty');
    }
  }

  @mustCallSuper
  void updateItem(int index, ItemType item, {bool force = false}) {
    assertHasItems();
    List<ItemType> updated = List.from(itemList!);
    updated[index] = item;
    value = PagingState(
      nextPageKey: nextPageKey,
      itemList: updated,
      error: error,
    );
    // this renews the cache
    if (force) {
      provide(firstPageKey, force);
    }
  }

  @nonVirtual
  @protected
  Future<bool> canRefresh() async {
    if (_requestLock.isLocked) {
      if (_isRefreshing) {
        return false;
      }
      _isRefreshing = true;
      // waits for the current request to be done
      await _requestLock.acquire();
      _requestLock.release();
      _isRefreshing = false;
      return true;
    } else {
      return true;
    }
  }

  @override
  Future<void> refresh({bool background = false, bool force = false}) async {
    if (!await canRefresh()) {
      return;
    }
    _isForceRefreshing = force;
    if (background) {
      loadPage(firstPageKey, reset: true);
    } else {
      super.refresh();
    }
  }

  @protected
  Future<void> loadPage(KeyType page, {bool reset = false}) async {
    try {
      await _requestLock.acquire();
      List<ItemType> items = sort(await provide(page, _isForceRefreshing));
      if (_disposed) {
        return;
      }
      if (reset) {
        value = PagingState(
          nextPageKey: provideNextPageKey(page, items),
          itemList: items,
        );
      } else {
        if (items.isEmpty) {
          appendLastPage(items);
        } else {
          appendPage(items, provideNextPageKey(page, items));
        }
      }
      success();
    } on Exception catch (error) {
      failure(error);
    } finally {
      _isForceRefreshing = false;
      _requestLock.release();
    }
  }
}

abstract class DataController<T> extends RawDataController<int, T> {
  DataController({super.firstPageKey = 1});

  @override
  @protected
  int provideNextPageKey(int current, List<T> items) => current + 1;
}

abstract class CursorDataController<T> extends RawDataController<String, T> {
  ValueNotifier<bool> orderByOldest = ValueNotifier(true);

  static const String _cursorFirstPage = 'a0';
  static const String _indexFirstPage = '1';

  CursorDataController() : super(firstPageKey: _cursorFirstPage);

  @override
  String get firstPageKey =>
      orderByOldest.value ? _cursorFirstPage : _indexFirstPage;

  @protected
  int getId(T item);

  @override
  @protected
  String provideNextPageKey(String current, List<T> items) {
    if (orderByOldest.value) {
      if (items.isEmpty) {
        return firstPageKey;
      } else {
        return 'a${items.map((e) => getId(e)).reduce(max).toString()}';
      }
    } else {
      int next;
      try {
        next = int.parse(current);
        next++;
      } on FormatException {
        next = 1;
      }
      return next.toString();
    }
  }

  @override
  @protected
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(orderByOldest);

  @override
  @protected
  List<T> sort(List<T> items) {
    if (orderByOldest.value) {
      items.sort((a, b) => getId(a).compareTo(getId(b)));
    }
    return items;
  }
}

mixin SearchableController<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  ValueNotifier<String> get search => ValueNotifier('');

  @override
  @protected
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(search);

  @override
  void dispose() {
    super.dispose();
    search.dispose();
  }
}

mixin HostableController<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  @override
  @protected
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(client);
}

mixin RefreshableController<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  RefreshController refreshController = RefreshController();

  @override
  @protected
  void failure(Exception error) {
    super.failure(error);
    refreshController.refreshFailed();
  }

  @override
  @protected
  void success() {
    super.success();
    refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    super.dispose();
    refreshController.dispose();
  }
}

extension Loading on RawDataController {
  Future<void> loadFirstPage() async {
    Future<void> loaded = waitForFirstPage();
    notifyPageRequestListeners(nextPageKey!);
    return loaded;
  }

  Future<void> waitForFirstPage() {
    Completer completer = Completer();

    void onUpdate() {
      switch (value.status) {
        case PagingStatus.loadingFirstPage:
          // ignored
          break;
        case PagingStatus.ongoing:
        case PagingStatus.noItemsFound:
        case PagingStatus.completed:
          removeListener(onUpdate);
          completer.complete();
          break;
        case PagingStatus.firstPageError:
        case PagingStatus.subsequentPageError:
          removeListener(onUpdate);
          completer.completeError(error);
          break;
      }
    }

    addListener(onUpdate);
    onUpdate();
    return completer.future;
  }
}

import 'dart:async';
import 'dart:math';

import 'package:e1547/client/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mutex/mutex.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class RawDataController<KeyType, ItemType>
    extends PagingController<KeyType, ItemType> {
  Mutex _requestLock = Mutex();
  bool _isRefreshing = false;
  bool _isForceRefreshing = false;

  List<String> log = [];

  late List<Listenable> _refreshListeners = getRefreshListeners();

  RawDataController({
    required KeyType firstPageKey,
  }) : super(firstPageKey: firstPageKey) {
    super.addPageRequestListener(loadPage);
    _refreshListeners.forEach((element) => element.addListener(refresh));
  }

  @override
  void dispose() {
    super.removePageRequestListener(loadPage);
    _refreshListeners.forEach((element) => element.removeListener(refresh));
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
    String key = UniqueKey().toString();
    if (_requestLock.isLocked) {
      log.add('$key mutex is locked');
      if (_isRefreshing) {
        log.add('$key already refreshing, false!');
        return false;
      }
      log.add('$key not refreshing, waiting!');
      _isRefreshing = true;
      // waits for the current request to be done
      await _requestLock.acquire();
      _requestLock.release();
      log.add('$key done with lock, true!');
      _isRefreshing = false;
      return true;
    } else {
      log.add('$key mutex is not locked, true!');
      return true;
    }
  }

  @override
  Future<void> refresh({bool force = false}) async {
    String key = UniqueKey().toString();
    log.add('$key refresh called!');
    if (!await canRefresh()) {
      log.add('$key cannot refresh, false!');
      return;
    }
    log.add('$key can refresh, true!');
    _isForceRefreshing = force;
    super.refresh();
  }

  Future<void> backgroundRefresh({bool force = false}) async {
    String key = UniqueKey().toString();
    log.add('$key refresh called!');
    if (!await canRefresh()) {
      log.add('$key cannot refresh, false!');
      return;
    }
    log.add('$key can refresh, true!');
    _isForceRefreshing = force;
    loadPage(firstPageKey, reset: true);
  }

  @protected
  Future<void> loadPage(KeyType page, {bool reset = false}) async {
    String key = UniqueKey().toString();
    log.add('-------------------------------------------------');
    log.add(
        '$key ${StackTrace.current.toString().split('\n').take(9).join('\n')}');
    log.add('-------------------------------------------------');
    try {
      log.add('$key loadpage with $page');
      await _requestLock.acquire();
      log.add('$key acquired mutex on page $page');
      List<ItemType> items = sort(await provide(page, _isForceRefreshing));
      if (reset) {
        value = PagingState(
          nextPageKey: provideNextPageKey(page, items),
          itemList: items,
          error: null,
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
      log.add('$key failed to load page $page with $error');
      failure(error);
    } finally {
      log.add('$key done with loading page $page');
      _isForceRefreshing = false;
      _requestLock.release();
    }
  }
}

abstract class DataController<T> extends RawDataController<int, T> {
  DataController({
    int firstPageKey = 1,
  }) : super(firstPageKey: firstPageKey);

  @override
  int provideNextPageKey(int current, List<T> items) => current + 1;
}

abstract class CursorDataController<T> extends RawDataController<String, T> {
  ValueNotifier<bool> orderByOldest = ValueNotifier(true);

  CursorDataController() : super(firstPageKey: 'a0');

  @protected
  int getId(T item);

  @override
  @protected
  Future<void> loadPage(String page, {bool reset = false}) {
    // firstpagekey cannot be changed
    // this is a hack around that
    if (page == 'a0' && !orderByOldest.value) {
      page = '1';
    }
    return super.loadPage(page, reset: reset);
  }

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

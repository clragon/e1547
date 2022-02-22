import 'dart:async';
import 'dart:math';

import 'package:e1547/client/client.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class RawDataController<KeyType, ItemType>
    extends PagingController<KeyType, ItemType> {
  Completer _requestCompleter = Completer()..complete();
  bool _isRefreshing = false;
  bool _isForceRefreshing = false;

  late List<Listenable> _refreshListeners = getRefreshListeners();

  RawDataController({
    required KeyType firstPageKey,
  }) : super(firstPageKey: firstPageKey) {
    super.addPageRequestListener(requestPage);
    _refreshListeners.forEach((element) => element.addListener(refresh));
  }

  @override
  void dispose() {
    super.removePageRequestListener(requestPage);
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
    if (!_requestCompleter.isCompleted) {
      if (_isRefreshing) {
        return false;
      }
      _isRefreshing = true;
      // waits for the current request to be done
      await _requestCompleter.future;
      _isRefreshing = false;
      return true;
    } else {
      return true;
    }
  }

  @override
  Future<void> refresh({bool force = false, bool background = false}) async {
    // ensures a singular refresh can be queued up
    if (!await canRefresh()) {
      return;
    }
    _isForceRefreshing = force;
    if (background) {
      await backgroundRefresh();
      await Future.delayed(Duration.zero);
    } else {
      super.refresh();
    }
  }

  @protected
  Future<void> loadPage(Future<void> Function() provider) async {
    if (!_requestCompleter.isCompleted) {
      await _requestCompleter.future;
    }
    _requestCompleter = Completer();
    try {
      await provider();
      success();
    } on Exception catch (error) {
      failure(error);
    } finally {
      _isForceRefreshing = false;
      _requestCompleter.complete();
    }
  }

  @protected
  Future<void> backgroundRefresh() async {
    return loadPage(
      () async {
        List<ItemType> items =
            sort(await provide(firstPageKey, _isForceRefreshing));
        value = PagingState(
          nextPageKey: provideNextPageKey(firstPageKey, items),
          itemList: items,
          error: null,
        );
      },
    );
  }

  @protected
  Future<void> requestPage(KeyType page) async {
    return loadPage(
      () async {
        List<ItemType> items = sort(await provide(page, _isForceRefreshing));
        if (items.isEmpty) {
          appendLastPage(items);
        } else {
          appendPage(items, provideNextPageKey(page, items));
        }
      },
    );
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
  Future<void> requestPage(String page) {
    // firstpagekey cannot be changed
    // this is a hack around that
    if (page == 'a0' && !orderByOldest.value) {
      page = '1';
    }
    return super.requestPage(page);
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

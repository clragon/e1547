import 'dart:math';

import 'package:e1547/client/client.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mutex/mutex.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class RawDataController<PageKeyType, ItemType>
    extends PagingController<PageKeyType, ItemType> {
  Mutex requestLock = Mutex();
  bool isRefreshing = false;

  RawDataController({
    required PageKeyType firstPageKey,
  }) : super(firstPageKey: firstPageKey) {
    super.addPageRequestListener(requestPage);
    getRefreshListeners().forEach((element) => element.addListener(refresh));
  }

  @override
  void dispose() {
    super.removePageRequestListener(requestPage);
    getRefreshListeners().forEach((element) => element.removeListener(refresh));
    if (itemList != null) {
      disposeItems(itemList!);
    }
    super.dispose();
  }

  @mustCallSuper
  void failure(Exception error) {
    this.error = error;
  }

  @mustCallSuper
  void success() {}

  Future<List<ItemType>?> catchError(
      Future<List<ItemType>> Function() provider) async {
    try {
      return await provider();
    } on DioError catch (error) {
      failure(error);
      return null;
    }
  }

  @mustCallSuper
  List<ValueNotifier> getRefreshListeners() => [];

  Future<List<ItemType>> provide(PageKeyType page);

  List<ItemType> sort(List<ItemType> items) => items;

  PageKeyType provideNextPageKey(PageKeyType current, List<ItemType> items);

  void disposeItems(List<ItemType> items) {}

  @nonVirtual
  Future<List<ItemType>?> loadPage(PageKeyType page) =>
      catchError(() async => sort(await provide(page)));

  @override
  Future<void> refresh({bool background = false}) async {
    // makes sure a singular refresh can be queued up
    if (requestLock.isLocked) {
      if (isRefreshing) {
        return;
      }
      isRefreshing = true;
      // waits for the current request to be done
      await requestLock.acquire();
      requestLock.release();
      isRefreshing = false;
    }
    List<ItemType> old = List<ItemType>.from(itemList ?? []);
    if (background) {
      List<ItemType>? items = await loadPage(firstPageKey);
      if (items != null) {
        value = PagingState(
          nextPageKey: provideNextPageKey(firstPageKey, items),
          itemList: items,
        );
        // disposing these breaks everything
        // TODO: figure out how to dispose items while replacing them
        // disposeItems(old);
      }
    } else {
      super.refresh();
      disposeItems(old);
    }
    success();
  }

  Future<void> requestPage(PageKeyType page) async {
    await requestLock.acquire();
    List<ItemType>? items = await loadPage(page);
    if (items != null) {
      if (items.isEmpty) {
        appendLastPage(items);
      } else {
        appendPage(items, provideNextPageKey(page, items));
      }
    }
    success();
    requestLock.release();
  }
}

abstract class CursorDataController<T> extends RawDataController<String, T> {
  ValueNotifier<bool> orderByOldest = ValueNotifier(true);

  CursorDataController() : super(firstPageKey: 'a0');

  int getId(T item);

  @override
  Future<void> requestPage(String page) {
    // firstpagekey cannot be changed
    // this is a hack around to that
    if (page == 'a0' && !orderByOldest.value) {
      page = '1';
    }
    return super.requestPage(page);
  }

  @override
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
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(orderByOldest);

  @override
  List<T> sort(List<T> items) {
    if (orderByOldest.value) {
      items.sort((a, b) => getId(a).compareTo(getId(b)));
    }
    return items;
  }
}

abstract class DataController<T> extends RawDataController<int, T> {
  DataController({
    int firstPageKey = 1,
  }) : super(firstPageKey: firstPageKey);

  @override
  int provideNextPageKey(int current, List<T> items) => current + 1;
}

mixin SearchableController<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  ValueNotifier<String> get search => ValueNotifier('');

  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(search);
}

mixin HostableController<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(settings.host);
}

mixin AccountableController<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(settings.credentials);
}

mixin RefreshableController<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  RefreshController refreshController = RefreshController();

  @override
  void failure(Exception error) {
    super.failure(error);
    refreshController.refreshFailed();
  }

  @override
  void success() {
    super.success();
    refreshController.refreshCompleted();
  }
}

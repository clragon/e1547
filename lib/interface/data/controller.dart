import 'dart:async';
import 'dart:math';

import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class RawDataController<KeyType, ItemType>
    extends PagingController<KeyType, ItemType> {
  Future<void>? request;
  bool isRequesting = false;
  bool isRefreshing = false;
  bool isForceRefreshing = false;

  late List<Listenable> refreshListeners = getRefreshListeners();

  RawDataController({
    required KeyType firstPageKey,
  }) : super(firstPageKey: firstPageKey) {
    super.addPageRequestListener(requestPage);
    refreshListeners.forEach((element) => element.addListener(refresh));
  }

  @override
  void dispose() {
    super.removePageRequestListener(requestPage);
    refreshListeners.forEach((element) => element.removeListener(refresh));
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

  @mustCallSuper
  List<Listenable> getRefreshListeners() => [];

  Future<List<ItemType>> provide(KeyType page, bool force);

  List<ItemType> sort(List<ItemType> items) => items;

  KeyType provideNextPageKey(KeyType current, List<ItemType> items);

  void disposeItems(List<ItemType> items) {}

  @nonVirtual
  Future<bool> canRefresh() async {
    if (isRequesting) {
      if (isRefreshing) {
        return false;
      }
      isRefreshing = true;
      // waits for the current request to be done
      await request;
      isRefreshing = false;
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
    isForceRefreshing = force;
    List<ItemType> old = List<ItemType>.from(itemList ?? []);
    if (background) {
      await backgroundRefresh();
      await Future.delayed(Duration.zero);
      disposeItems(old);
    } else {
      super.refresh();
      disposeItems(old);
    }
  }

  Future<void> loadPage(Future<void> Function() provider) async {
    if (isRequesting) {
      await request;
    }
    isRequesting = true;
    Completer completer = Completer();
    request = completer.future;
    try {
      await provider();
      success();
    } on Exception catch (error) {
      failure(error);
    } finally {
      isForceRefreshing = false;
      isRequesting = false;
      completer.complete();
    }
  }

  Future<void> backgroundRefresh() async {
    return loadPage(
      () async {
        List<ItemType> items =
            sort(await provide(firstPageKey, isForceRefreshing));
        value = PagingState(
          nextPageKey: provideNextPageKey(firstPageKey, items),
          itemList: items,
          error: null,
        );
      },
    );
  }

  Future<void> requestPage(KeyType page) async {
    return loadPage(
      () async {
        List<ItemType> items = sort(await provide(page, isForceRefreshing));
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

  int getId(T item);

  @override
  Future<void> requestPage(String page) {
    // firstpagekey cannot be changed
    // this is a hack around that
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
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(orderByOldest);

  @override
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
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(search);
}

mixin HostableController<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  @override
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(settings.host);
}

mixin AccountableController<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  @override
  List<Listenable> getRefreshListeners() =>
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

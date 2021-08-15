import 'package:e1547/client.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mutex/mutex.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class RawDataController<PageKeyType, ItemType>
    extends PagingController<PageKeyType, ItemType> {
  final PageKeyType firstPageKey;
  Mutex requestLock = Mutex();
  bool isRefreshing = false;

  RawDataController({
    required this.firstPageKey,
  }) : super(firstPageKey: firstPageKey) {
    super.addPageRequestListener(requestPage);
    getRefreshListeners().forEach((element) => element.addListener(refresh));
  }

  @override
  void dispose() {
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

  PageKeyType provideNextPageKey(PageKeyType current, List<ItemType> items);

  void disposeItems(List<ItemType> items) {}

  @nonVirtual
  Future<List<ItemType>?> loadPage(PageKeyType page) =>
      catchError(() => provide(page));

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
    try {
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
    } finally {
      success();
    }
  }

  Future<void> requestPage(PageKeyType page) async {
    await requestLock.acquire();
    try {
      List<ItemType>? items = await loadPage(page);
      if (items != null) {
        if (items.isEmpty) {
          appendLastPage(items);
        } else {
          appendPage(items, provideNextPageKey(page, items));
        }
      }
    } finally {
      success();
    }
    requestLock.release();
  }
}

abstract class DataController<T> extends RawDataController<int, T> {
  final int firstPageKey;

  DataController({
    this.firstPageKey = 1,
  }) : super(firstPageKey: firstPageKey);

  int provideNextPageKey(int current, List<T> items) => current + 1;
}

mixin SearchableDataMixin<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  ValueNotifier<String> search = ValueNotifier('');

  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(search);
}

mixin HostableDataMixin<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(settings.host);
}

mixin RefreshableDataMixin<PageKeyType, ItemType>
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

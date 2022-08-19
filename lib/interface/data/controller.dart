import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mutex/mutex.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingState;

abstract class RawDataController<KeyType, ItemType>
    extends PagingController<KeyType, ItemType> {
  /// A controller for a paged widget.
  RawDataController({required super.firstPageKey}) {
    super.addPageRequestListener(loadPage);
    _refreshListeners.forEach((e) => e.addListener(refresh));
    super.addListener(_maybeReset);
  }

  /// Ensures we do not request duplicate pages.
  final PageLock _pageLock = PageLock();

  /// Whether we are currently queuing a refresh.
  bool _isRefreshing = false;

  /// Used to prevent calling listeners after disposal.
  bool _disposed = false;

  /// List of [Listenable]s which will trigger a refresh on notification.
  late final List<Listenable> _refreshListeners = getRefreshListeners();

  @override
  void dispose() {
    super.removePageRequestListener(loadPage);
    _refreshListeners.forEach((e) => e.removeListener(refresh));
    super.removeListener(_maybeReset);
    _disposed = true;
    super.dispose();
  }

  /// Called when a request of this controller fails.
  @protected
  @mustCallSuper
  void failure(Exception error) => this.error = error;

  /// Called when a request of this controller succeeds.
  @protected
  @mustCallSuper
  void success() {}

  // TODO: find a replacement for this.
  /// Called when the [itemList] is changed entirely.
  ///
  /// Can be used to reset additional resources which depend on itemList.
  @protected
  @mustCallSuper
  void reset() {}

  /// Calls [reset] if the [itemList] has been set to null.
  void _maybeReset() {
    if (value.itemList == null) {
      reset();
    }
  }

  /// Allows adding listeners that trigger a refresh by overriding this function.
  ///
  /// Can be used in mixins which do not have a constructor.
  @protected
  @mustCallSuper
  List<Listenable> getRefreshListeners() => [];

  /// Called to get the next page of items for [page].
  ///
  /// If [force] is true, caching should be ignored.
  @protected
  Future<List<ItemType>> provide(KeyType page, bool force);

  /// Called to get the next page key, based on the current page key and the current list of items.
  @protected
  KeyType provideNextPageKey(KeyType current, List<ItemType> items);

  /// Ensures that the controller has a non-null [itemList].
  @protected
  void assertHasItems() {
    if (itemList == null) {
      throw StateError(
          'Controller cannot modify item when the itemList is empty');
    }
  }

  /// Ensures that the controller contains the [item] in its [itemList]
  @protected
  void assertOwnsItem(ItemType item) {
    assertHasItems();
    if (itemList == null || !itemList!.contains(item)) {
      throw StateError('Item isnt owned by this controller');
    }
  }

  /// Replaces the [item] at [index] in the [itemlist].
  ///
  /// If [force] is true, the cache is deleted.
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

  /// Checks if the controller can queue a refresh.
  /// If there is currently a refresh queued, this returns false.
  Future<bool> _canRefresh() async {
    if (_pageLock.isLocked) {
      if (_isRefreshing) return false;
      _isRefreshing = true;
      await _pageLock.wait();
      _isRefreshing = false;
      return true;
    } else {
      return true;
    }
  }

  @override
  Future<void> refresh({bool background = false, bool force = false}) async {
    if (!await _canRefresh()) return;
    return loadPage(
      firstPageKey,
      reset: true,
      background: background,
      force: force,
    );
  }

  /// Loads a page of items and adds them to the list.
  ///
  /// - If reset is true, the list will be emptied before adding the new items.
  /// - If background is true, the new items are loaded before the list is reset.
  /// - If force is true, the item cache is ignored.
  @protected
  Future<void> loadPage(
    KeyType page, {
    bool reset = false,
    bool background = false,
    bool force = false,
  }) async {
    try {
      await _pageLock.protect(page, reset: reset, () async {
        if (reset && !background) {
          value = PagingState<KeyType, ItemType>(
            nextPageKey: page,
          );
        }
        List<ItemType> items = await provide(page, force);
        if (_disposed) return;
        if (reset) {
          if (background) {
            this.reset();
          }
          value = PagingState(
            nextPageKey: provideNextPageKey(page, items),
            itemList: items,
          );
        } else {
          if (items.isNotEmpty) {
            appendPage(items, provideNextPageKey(page, items));
          } else {
            appendLastPage(items);
          }
        }
        success();
      });
    } on Exception catch (error) {
      failure(error);
    }
  }
}

abstract class DataController<T> extends RawDataController<int, T> {
  /// A [RawDataController] that uses positive integers as page keys.
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
  void appendPage(List<T> newItems, String? nextPageKey) {
    if (orderByOldest.value) {
      newItems.sort((a, b) => getId(a).compareTo(getId(b)));
    }
    super.appendPage(newItems, nextPageKey);
  }
}

class PageLock<KeyType> {
  /// Keeps track of what keys have been used to paginate.
  ///
  /// Using keys requires requesting and releasing a Mutex lock to ensure key exclusivity.
  PageLock();

  /// Protects operations on the list of used keys.
  final Mutex _mutex = Mutex();

  /// Whether the lock is currently locked.
  bool get isLocked => _mutex.isLocked;

  /// List of all used up keys.
  final List<KeyType> _used = [];

  /// The key which is currently used.
  KeyType? _currentKey;

  /// The key which is currently used.
  KeyType? get currentKey => _currentKey;

  /// Acquires the lock for a [key].
  ///
  /// If the [key] has already been used, the lock will not be acquired
  /// and a [KeyAlreadyUsedException] will be thrown.
  ///
  /// If [reset] is true, all used keys will be cleared before usage.
  Future<void> acquire(KeyType key, {bool reset = false}) async {
    await _mutex.acquire();
    if (reset) {
      _used.clear();
    }
    if (_used.contains(key)) {
      _mutex.release();
      throw KeyAlreadyUsedException(key);
    }
    _currentKey = key;
  }

  /// Releases the lock for a [key].
  ///
  /// If the [key] is null, it will count as unused.
  ///
  /// It is an error if the [key] to be released does not match the key that was acquired.
  ///
  /// If [reset] is true, all used keys will be cleared before usage.
  void release(KeyType? key) {
    try {
      if (key == null) {
        return;
      }
      if (key != _currentKey) {
        throw StateError(
            'Attempted to release $key, but current key was $_currentKey!');
      }
      _used.add(key);
      _currentKey = null;
    } finally {
      _mutex.release();
    }
  }

  /// This method guarantees a lock is always acquired before invoking the
  /// [criticalSection] function. It also guarantees the lock is always
  /// released.
  ///
  /// If the key was already used,
  /// the [criticalSection] function will not be called.
  ///
  /// If an exception occurs in the [criticalSection] function, the key will not be used.
  Future<T?> protect<T>(
    KeyType key,
    Future<T> Function() criticalSection, {
    bool reset = false,
  }) async {
    try {
      await acquire(key, reset: reset);
      T result = await criticalSection();
      release(key);
      return result;
    } on KeyAlreadyUsedException {
      return null;
    } catch (_) {
      release(null);
      rethrow;
    }
  }

  /// Waits for the current key operation to complete, if there is any.
  Future<void> wait() async => _mutex.protect(() async {});

  /// Clears all used keys.
  ///
  /// Does not interrupt key operations.
  Future<void> reset() async => _mutex.protect(() async => _used.clear());
}

class KeyAlreadyUsedException<KeyType> implements Exception {
  /// Exception thrown when a key was attempted to be used again in a [PageLock].
  const KeyAlreadyUsedException(this.key);

  /// The key that was attempted to be used.
  final KeyType key;

  @override
  String toString() => "$runtimeType: $key was already used!";
}

mixin FilterableController<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  /// List of actual items of this controller.
  List<ItemType>? _rawItemList;

  /// List of actual items of this controller.
  List<ItemType>? get rawItemList => _rawItemList.maybeUnmodifiable();

  /// List of actual items of this controller.
  set rawItemList(List<ItemType>? value) {
    _rawItemList = value;
    this.value = PagingState(
      nextPageKey: nextPageKey,
      itemList: _rawItemList != null ? filter(_rawItemList!) : null,
      error: error,
    );
  }

  /// Corresponding to ValueNotifier.value.
  ///
  /// Passing filtered items for [itemList] in [PagingState] is an error,
  /// because it will lead to those filtered items being excluded from the new [rawItemList]
  /// and effectively being lost.
  @override
  set value(PagingState<PageKeyType, ItemType> state) {
    const equality = DeepCollectionEquality();
    final bool rawItemsIsItems = equality.equals(_rawItemList, itemList);
    final bool itemsIsNotNewItems = !equality.equals(itemList, state.itemList);
    assert(
      rawItemsIsItems || itemsIsNotNewItems,
      'Filtering error in $runtimeType!\nDo not pass filtered items as [itemList] for [PagingState], '
      'because this will lead to the erasure of filtered items!\n',
    );
    _rawItemList = state.itemList;
    super.value = PagingState(
      nextPageKey: state.nextPageKey,
      itemList: _rawItemList != null ? filter(_rawItemList!) : null,
      error: state.error,
    );
  }

  @override
  void appendPage(List<ItemType> newItems, PageKeyType? nextPageKey) {
    value = PagingState(
      itemList: (_rawItemList ?? []) + newItems,
      nextPageKey: nextPageKey,
    );
  }

  @override
  void updateItem(int index, ItemType item, {bool force = false}) {
    assertHasItems();
    _rawItemList![_rawItemList!.indexOf(itemList![index])] = item;
    refilter();
    // this renews the cache
    if (force) {
      provide(firstPageKey, force);
    }
  }

  /// Filters items and returns the filtered list.
  @protected
  List<ItemType> filter(List<ItemType> items);

  /// Reapplies filtering after the filter variables have changed.
  @protected
  void refilter() {
    if (_rawItemList == null) return;
    value = PagingState(
      nextPageKey: nextPageKey,
      itemList: _rawItemList,
      error: error,
    );
  }
}

mixin SearchableController<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  /// The current search of this controller.
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

mixin RefreshableController<PageKeyType, ItemType>
    on RawDataController<PageKeyType, ItemType> {
  /// The [RefreshController] for this controller.
  ///
  /// Will automatically be set to the right states (success and failure).
  /// Note that it is not reusable.
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

extension Loading<T extends RawDataController> on T {
  /// Waits for the first Page of this controller to be loaded.
  ///
  /// If the controller has already loaded the page, will return immediately.
  /// Does not trigger a new page load on it's own.
  ///
  /// If the page load fails, a [ControllerLoadingException] will be thrown.
  Future<T> waitForFirstPage() async {
    await Future.delayed(Duration.zero);
    Completer<T> completer = Completer<T>();

    void onUpdate() {
      switch (value.status) {
        case PagingStatus.loadingFirstPage:
          // ignored
          break;
        case PagingStatus.ongoing:
        case PagingStatus.noItemsFound:
        case PagingStatus.completed:
          removeListener(onUpdate);
          completer.complete(this);
          break;
        case PagingStatus.firstPageError:
        case PagingStatus.subsequentPageError:
          removeListener(onUpdate);
          completer.completeError(ControllerLoadingException(error));
          break;
      }
    }

    addListener(onUpdate);
    onUpdate();
    return completer.future;
  }

  /// Requests and waits for the first Page of this controller to be loaded.
  ///
  /// Triggers a new page to be loaded.
  /// If the page load fails, a [ControllerLoadingException] will be thrown.
  Future<T> loadFirstPage() async {
    Future<void> loaded = waitForFirstPage();
    notifyPageRequestListeners(nextPageKey);
    await loaded;
    return this;
  }
}

class ControllerLoadingException implements Exception {
  /// This Exception is thrown when using [Loading.waitForFirstPage] or [Loading.loadFirstPage]
  /// and the loading of the page fails.
  ControllerLoadingException(this.inner);

  /// The exception that was thrown in the controller.
  final Exception inner;

  @override
  String toString() {
    return 'ControllerLoadingException($inner)';
  }
}

import 'dart:async';

import 'package:e1547/shared/shared.dart';
import 'package:flutter/foundation.dart';

export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

abstract class DataController<KeyType, ItemType> with ChangeNotifier {
  /// A controller for a paged widget.
  DataController({required this.firstPageKey}) : _nextPageKey = firstPageKey;

  /// The key for the first page to be fetched.
  final KeyType firstPageKey;

  /// List with all items loaded so far.
  List<ItemType>? _rawItems;

  /// List with all items loaded so far.
  List<ItemType>? get rawItems => _rawItems;

  set rawItems(List<ItemType>? value) {
    if (value == _rawItems) return;
    _rawItems = value;
    applyFilter();
  }

  /// Filtered list with all items loaded so far.
  List<ItemType>? _filteredItems;

  /// Filtered list with all items loaded so far.
  List<ItemType>? get items => _filteredItems;

  /// The key for the next page to be fetched.
  KeyType? _nextPageKey;

  /// The key for the next page to be fetched.
  KeyType? get nextPageKey => _nextPageKey;

  /// The current error, if any.
  Object? _error;

  /// The current error, if any.
  Object? get error => _error;

  set error(Object? value) {
    if (value == _error) return;
    _error = value;
    notifyListeners();
  }

  /// Whether the controller is currently fetching a page.
  bool _fetching = false;

  /// The identifier for the last scheduled reset.
  Object? _resetter;

  /// Whether this controller has been disposed.
  bool _disposed = false;

  /// Retrieves the next page of items.
  @protected
  Future<PageResponse<KeyType, ItemType>> performRequest(
    KeyType page,
    bool force,
  );

  /// Refreshes the items.
  ///
  /// If [background] is true, items will be deleted after the next page is loaded.
  @nonVirtual
  Future<void> refresh({bool force = false, bool background = false}) =>
      getNextPage(force: force, reset: true, background: background);

  /// Fetches the next page of items.
  ///
  /// If [reset] is true, all items are deleted and the first page is loaded.
  /// If [background] is additionally true, items will be replaced with the next page after it is loaded.
  ///
  /// If this is called during another page being loaded,
  /// this will complete after with no new request being made.
  @mustCallSuper
  Future<void> getNextPage({
    bool force = false,
    bool reset = false,
    bool background = false,
  }) async {
    ChangeNotifier.debugAssertNotDisposed(this);
    if (_fetching) {
      if (reset) return _scheduleReset(background);
      return _waitForFetch();
    }
    try {
      _fetching = true;
      _error = null;
      onPreRequest(force, reset, background);
      await Future.value();
      notifyListeners();
      KeyType? key = nextPageKey;
      if (reset) key = firstPageKey;
      if (key == null) return;
      PageResponse response = await performRequest(key, force);
      if (_disposed) return;
      if (response.error != null) {
        _error = response.error;
        return;
      }
      onPostRequest(force, reset, background);
      _nextPageKey = response.nextPageKey;
      rawItems = [if (rawItems != null) ...rawItems!, ...response.items!];
    } on Object catch (e, s) {
      Zone.current.handleUncaughtError(e, s);
      _error = e;
    } finally {
      _fetching = false;
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  /// Filters the items.
  @protected
  @mustCallSuper
  List<ItemType>? filter(List<ItemType>? items) => items?.toSet().toList();

  /// Applies the item filter.
  @nonVirtual
  void applyFilter() {
    _filteredItems = filter(_rawItems);
    notifyListeners();
  }

  /// Called before a request is made.
  ///
  /// Can be used to reset the controller state.
  @protected
  @mustCallSuper
  void onPreRequest(bool force, bool reset, bool background) {
    if (reset && !background) this.reset();
  }

  /// Called after a request is made.
  ///
  /// Can be used to reset the controller state.
  @protected
  @mustCallSuper
  void onPostRequest(bool force, bool reset, bool background) {
    if (reset && background) this.reset();
  }

  /// Resets the controller state.
  ///
  /// Do not call this method directly, use [refresh] instead.
  /// Override this method to reset custom state.
  @protected
  @mustCallSuper
  void reset() {
    _nextPageKey = firstPageKey;
    rawItems = null;
    error = null;
    notifyListeners();
  }

  /// Waits for the current call to [getNextPage] to complete.
  Future<void> _waitForFetch() async {
    Completer<void> completer = Completer<void>();

    void onUpdate() {
      if (!_fetching) {
        removeListener(onUpdate);
        completer.complete();
      }
    }

    addListener(onUpdate);
    return completer.future;
  }

  /// Waits for the next page to be loaded.
  ///
  /// Does not request a new page.
  Future<void> waitForNextPage() async {
    if (error != null) return;
    if (nextPageKey == null) return;
    if (items == null) return _waitForFetch();
  }

  /// Schedules a refresh.
  ///
  /// [background] is equivalent to the parameter of the same name in [getNextPage].
  ///
  /// If multiple refreshes are scheduled during the same [getNextPage] call,
  /// only the last one will be executed.
  Future<void> _scheduleReset(bool background) async {
    Object id = _resetter = Object();
    await _waitForFetch();
    if (id != _resetter) return;
    return getNextPage(reset: true, background: background);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class PageResponse<KeyType, ItemType> {
  /// The response for a page request.
  const PageResponse({
    required List<ItemType> this.items,
    required this.nextPageKey,
  }) : error = null;

  /// The response for a page request.
  ///
  /// Is treated as the last page to be added.
  const PageResponse.last({required List<ItemType> this.items})
    : nextPageKey = null,
      error = null;

  /// The response for a page request.
  ///
  /// Is treated as a failed page request.
  const PageResponse.error({required Object this.error})
    : items = null,
      nextPageKey = null;

  /// The key for the next page.
  ///
  /// If null, this is treated as the last page.
  final KeyType? nextPageKey;

  /// The list of items for this page.
  final List<ItemType>? items;

  /// The error that was thrown during loading this page.
  final Object? error;
}

extension DataControllerItemManipulation<KeyType, ItemType>
    on DataController<KeyType, ItemType> {
  /// Updates the item at [index] of [rawItems] with [item].
  ///
  /// Throws an Error if [index] is -1 or if the controller has no items.
  void updateItem(int index, ItemType item) {
    if (index == -1) {
      throw StateError('$runtimeType does not own this ${item.runtimeType}');
    }
    if (rawItems == null) {
      throw StateError('$runtimeType has no items');
    }
    rawItems = rawItems!.toList()..[index] = item;
  }

  @protected
  void assertOwnsItem(ItemType item) {
    if (rawItems == null || !rawItems!.contains(item)) {
      throw StateError('$runtimeType doesn\'t own this ${item.runtimeType}');
    }
  }
}

extension DataControllerPaging<KeyType, ItemType>
    on DataController<KeyType, ItemType> {
  PagingState<KeyType, ItemType> get state => PagingState(
    pages: items != null ? [items!] : null,
    keys: items != null ? [firstPageKey] : null,
    error: error,
    hasNextPage: nextPageKey != null,
    isLoading: _fetching,
  );
}

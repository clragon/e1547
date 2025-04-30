import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class ProxyPagingController<KeyType, ItemType>
    implements
        PagingController<KeyType, ItemType>,
        ValueNotifier<PagingState<KeyType, ItemType>> {
  ProxyPagingController(this._controller) : super();

  final DataController<KeyType, ItemType> _controller;

  @override
  PagingState<KeyType, ItemType> get value => PagingState(
        itemList: itemList,
        nextPageKey: nextPageKey,
        error: error,
      );

  @override
  set value(PagingState<KeyType, ItemType> value) =>
      throw UnsupportedError('Cannot set value on a $runtimeType');

  @override
  List<ItemType>? get itemList => _controller.items;

  @override
  set itemList(List<ItemType>? itemList) =>
      throw UnsupportedError('Cannot set itemList on a $runtimeType');

  @override
  KeyType? get nextPageKey => _controller.nextPageKey;

  @override
  set nextPageKey(KeyType? newNextPageKey) =>
      throw UnsupportedError('Cannot set nextPageKey on a $runtimeType');

  @override
  Object? get error => _controller.error;

  @override
  set error(Object? error) =>
      throw UnsupportedError('Cannot set error on a $runtimeType');

  final List<VoidCallback> _listeners = [];

  @override
  void addListener(VoidCallback listener) {
    if (_listeners.contains(listener)) return;
    _listeners.add(listener);
    _controller.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) return;
    _listeners.remove(listener);
    _controller.removeListener(listener);
  }

  @override
  void addPageRequestListener(PageRequestListener<KeyType> listener) =>
      throw UnsupportedError(
          'Cannot add page request listener on a $runtimeType');

  @override
  void notifyPageRequestListeners(KeyType pageKey) => _controller.getNextPage();

  @override
  void removePageRequestListener(PageRequestListener<KeyType> listener) =>
      throw UnsupportedError(
          'Cannot remove page request listener on a $runtimeType');

  final Map<PagingStatusListener, VoidCallback> _statusListeners = {};

  @override
  void addStatusListener(PagingStatusListener listener) {
    if (_statusListeners.containsKey(listener)) return;
    _statusListeners[listener] = () => listener(value.status);
    addListener(_statusListeners[listener]!);
  }

  @override
  void notifyStatusListeners(PagingStatus status) => notifyListeners();

  @override
  void removeStatusListener(PagingStatusListener listener) {
    if (!_statusListeners.containsKey(listener)) return;
    removeListener(_statusListeners[listener]!);
    _statusListeners.remove(listener);
  }

  @override
  void appendLastPage(List<ItemType> newItems) =>
      throw UnsupportedError('Cannot appendLastPage on a $runtimeType');

  @override
  void appendPage(List<ItemType> newItems, KeyType? nextPageKey) =>
      throw UnsupportedError('Cannot appendPage on a $runtimeType');

  @override
  KeyType get firstPageKey => _controller.firstPageKey;

  @override
  int? get invisibleItemsThreshold => null;

  @override
  void refresh() => _controller.refresh();

  @override
  void retryLastFailedRequest() => _controller.getNextPage();

  @override
  void dispose() {
    for (final listener in _statusListeners.values) {
      removeListener(listener);
    }
    _statusListeners.clear();
    for (final listener in _listeners) {
      _controller.removeListener(listener);
    }
    _listeners.clear();
  }

  @override
  bool get hasListeners => _controller.hasListeners;

  @override
  void notifyListeners() => _controller.notifyListeners();
}

class PagedChildBuilderRetryButton extends StatelessWidget {
  const PagedChildBuilderRetryButton(this.pagingController, {super.key});

  final PagingController? pagingController;

  @override
  Widget build(BuildContext context) {
    if (pagingController == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextButton(
        onPressed: pagingController!.retryLastFailedRequest,
        child: const Text('Try again'),
      ),
    );
  }
}

PagedChildBuilderDelegate<T> defaultPagedChildBuilderDelegate<T>({
  required ItemWidgetBuilder<T> itemBuilder,
  PagingController? pagingController,
  Widget? onEmpty,
  Widget? onError,
  Widget Function(BuildContext context, Widget child)? pageBuilder,
}) {
  pageBuilder ??= (context, child) => child;
  return PagedChildBuilderDelegate<T>(
    itemBuilder: itemBuilder,
    firstPageProgressIndicatorBuilder: (context) => pageBuilder!(
      context,
      const Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      ),
    ),
    newPageProgressIndicatorBuilder: (context) => pageBuilder!(
      context,
      const Material(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ),
    noItemsFoundIndicatorBuilder: (context) => pageBuilder!(
      context,
      IconMessage(
        icon: const Icon(Icons.clear),
        title: onEmpty ?? const Text('Nothing to see here'),
      ),
    ),
    firstPageErrorIndicatorBuilder: (context) => pageBuilder!(
      context,
      IconMessage(
        icon: const Icon(Icons.warning_amber_outlined),
        title: onError ?? const Text('Failed to load'),
        action: PagedChildBuilderRetryButton(pagingController),
      ),
    ),
    newPageErrorIndicatorBuilder: (context) => pageBuilder!(
      context,
      IconMessage(
        direction: Axis.horizontal,
        icon: const Icon(Icons.warning_amber_outlined),
        title: onError ?? const Text('Failed to load'),
        action: PagedChildBuilderRetryButton(pagingController),
      ),
    ),
  );
}

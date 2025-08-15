import 'dart:async';

import 'package:e1547/stream/stream.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// A cache that functions on pages of items. Each item is stored in another internal cache.
class PagedValueCache<K, I, V> extends ValueCache<K, List<V>> {
  PagedValueCache({
    required this.toId,
    super.size = 100,
    int? pageSize,
    super.maxAge,
  }) : items = ValueCache<I, V>(
         size: size != null ? size * (pageSize ?? 10) : null,
         maxAge: maxAge,
       );

  /// Maps items to ids.
  final I Function(V value) toId;

  /// The cache of items that backs this page cache.
  ///
  /// This is shared by all pages.
  final ValueCache<I, V> items;

  @override
  @protected
  ValueCacheEntry<List<V>> createEntry(List<V>? value) {
    return PagedValueCacheEntry<I, V>(value: value, items: items, toId: toId);
  }

  /// Invalidates a page cache entry.
  ///
  /// This makes the page entry immediately stale, but does not affect
  /// the individual items in the items cache.
  @override
  void invalidate(K key) => super.invalidate(key);

  @override
  void dispose() {
    items.dispose();
    super.dispose();
  }
}

class PagedValueCacheEntry<I, V> extends ValueCacheEntry<List<V>> {
  PagedValueCacheEntry({
    List<V>? value,
    required this.items,
    required this.toId,
  }) : super.raw() {
    this.value = value;
    _setupQueue();
  }

  /// The cache of items that backs this page cache.
  final ValueCache<I, V> items;

  /// Maps items to ids.
  final I Function(V value) toId;

  /// A stream of the page's items.
  ///
  /// This is necessary to keep all the page's items alive in the item cache.
  final BehaviorSubject<List<V>> _stream = BehaviorSubject();

  /// The subscription to the combined stream of the page's items.
  StreamSubscription<List<V>>? _subscription;

  @override
  List<V>? get value {
    _accessed = DateTime.now();
    return _stream.valueOrNull;
  }

  @override
  set value(List<V>? value) {
    if (value == null) return;
    _accessed = DateTime.now();
    _created = _accessed;
    _invalidated = false;
    List<I> ids = [];
    List<StreamSubscription<V>> keepAlives = [];
    for (final item in value) {
      final itemId = toId(item);
      // Freshly created items are immediately marked as orphaned,
      // if they have no listeners. We therefore add a no-op listener
      // to keep them alive until we actually subscribe to them.
      keepAlives.add(items.stream(itemId).listen((_) {}));
      items[itemId] = item;
      ids.add(itemId);
    }
    Stream<List<V>> source;
    if (ids.isNotEmpty) {
      source = CombineLatestStream.list<V>(ids.map(items.stream)).map(List.of);
    } else {
      // If there are no items, we need to emit an empty list.
      // Otherwise, the stream will never emit.
      source = Stream.value([]);
    }
    _subscription?.cancel();
    _subscription = source.listen(
      _stream.add,
      onError: _stream.addError,
      onDone: () => _subscription?.cancel(),
    );
    keepAlives.forEach((e) => e.cancel());
  }

  DateTime _created = DateTime.now();

  @override
  DateTime get created => _created;

  DateTime _accessed = DateTime.now();

  @override
  DateTime get accessed => _accessed;

  Duration? _maxAge;

  @override
  Duration? get maxAge => _maxAge;

  @override
  set maxAge(Duration? value) {
    _accessed = DateTime.now();
    _maxAge = value;
  }

  bool _invalidated = false;

  @override
  bool get stale =>
      _invalidated ||
      (_maxAge != null && DateTime.now().difference(_created) > _maxAge!);

  @override
  void invalidate() {
    _invalidated = true;
  }

  @override
  bool get hasListeners => _stream.hasListener;

  final BehaviorSubject<ValueCacheStatus> _statusStream =
      BehaviorSubject.seeded(ValueCacheStatus.idle);

  @override
  ValueCacheStatus get status => _statusStream.value;

  @override
  Stream<ValueCacheStatus> get statusStream => _statusStream.stream;

  final StreamController<(FutureOr<List<V>> Function()?, bool?)> _fetchQueue =
      StreamController();

  void _setupQueue() {
    _fetchQueue.stream
        .asyncMap((request) async {
          final (fetch, force) = request;
          if (fetch == null) return;

          final hasValue = value != null;
          if (hasValue && !stale && !(force ?? false)) return;

          _statusStream.add(
            hasValue ? ValueCacheStatus.refetching : ValueCacheStatus.fetching,
          );

          try {
            value = await fetch();
            _statusStream.add(ValueCacheStatus.idle);
          } on Object catch (e, st) {
            _statusStream.add(ValueCacheStatus.error);
            _stream.addError(e, st);
          }
        })
        .listen(null);
  }

  @override
  Stream<List<V>> stream({
    FutureOr<List<V>> Function()? fetch,
    Duration? maxAge,
    bool? force,
  }) {
    _accessed = DateTime.now();
    late BehaviorSubject<List<V>> controller;
    late StreamSubscription<List<V>> subscription;
    controller = BehaviorSubject<List<V>>(
      onListen: () async {
        subscription = _stream.listen(
          controller.add,
          onError: controller.addError,
          onDone: () {
            subscription.cancel();
            controller.close();
          },
        );
        _fetchQueue.add((fetch, force));
      },
    );
    return controller.stream;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _stream.close();
    _statusStream.close();
    _fetchQueue.close();
  }
}

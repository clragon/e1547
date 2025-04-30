import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:e1547/stream/stream.dart';
import 'package:flutter/foundation.dart';

/// An LRU and TTL Cache where entries with active listeners are kept indefinitely.
class ValueCache<K, V> extends MapBase<K, V> {
  ValueCache({
    this.size = 1000,
    this.maxAge,
  });

  /// The amount of children with no active listeners that remain in the cache.
  ///
  /// If null, the cache is unbounded.
  final int? size;

  /// The maximum amount of time a value is kept without being re-requested.
  ///
  /// If null, values are never stale.
  final Duration? maxAge;

  /// The internal cache.
  final Map<K, ValueCacheEntry<V>> _cache = {};

  /// Used to create a new cache entry.
  ///
  /// Can be overridden to use a custom entry type.
  @protected
  ValueCacheEntry<V> createEntry(V? value) => ValueCacheEntry(value);

  ValueCacheEntry<V> _create(V? value) {
    _trim();
    ValueCacheEntry<V> entry = createEntry(value);
    entry.maxAge = maxAge;
    return entry;
  }

  @override
  V? operator [](Object? key) => _cache[key]?.value;

  @override
  void operator []=(K key, V value) => _cache.update(
        key,
        (entry) => entry..value = value,
        ifAbsent: () => _create(value),
      );

  /// Returns a stream for the value corresponding to [key].
  /// If the value is updated, the new value will be emitted.
  ///
  /// Listening to this stream enables the value to be kept in memory.
  /// Once the stream listener is removed, the value may be removed by the LRU / TTL evicting strategy.
  ///
  /// Also see [ValueCacheEntry.stream].
  Stream<V> stream(
    K key, {
    FutureOr<V> Function()? fetch,
    Duration? maxAge,
  }) {
    _cache.putIfAbsent(key, () => _create(null));
    return _cache[key]!.stream(
      fetch: fetch,
      maxAge: maxAge ?? this.maxAge,
    );
  }

  /// Optimistically updates a value.
  /// If [callback] throws, the value is rolled back.
  /// [update] must therefore not modify the value, but return a copy.
  ///
  /// Will not add the value if it is not already present.
  Future<void> optimistic(
    K key,
    V Function(V value) update,
    FutureOr<void> Function() callback,
  ) async {
    V? old = this[key];
    try {
      if (old != null) {
        this[key] = update(old);
      }
      await callback();
    } on Exception {
      if (old != null) {
        this[key] = old;
      }
      rethrow;
    }
  }

  /// Removes entries with no listeners.
  ///
  /// Checks against both [size] and [maxAge].
  void _trim() {
    List<MapEntry<K, ValueCacheEntry<V>>> orphaned =
        _cache.entries.whereNot((e) => e.value.hasListeners).toList();
    orphaned.sortBy((e) => e.value);
    List<MapEntry<K, ValueCacheEntry<V>>> removing = [];
    int? size = this.size;
    if (size != null) {
      int taking = max(0, orphaned.length + 1 - size);
      removing.addAll(orphaned.take(taking));
      orphaned.removeWhere(removing.contains);
    }
    Duration? maxAge = this.maxAge;
    if (maxAge != null) {
      removing.addAll(orphaned.where((e) => e.value.stale));
      orphaned.removeWhere(removing.contains);
    }
    for (final entry in removing) {
      remove(entry.key);
    }
  }

  @override
  void clear() {
    for (final entry in _cache.entries) {
      entry.value.dispose();
    }
    _cache.clear();
  }

  @override
  Iterable<K> get keys => _cache.keys;

  @override
  V? remove(Object? key) {
    ValueCacheEntry<V>? entry = _cache.remove(key);
    V? value = entry?.value;
    entry?.dispose();
    return value;
  }

  /// Frees all resources associated with this cache.
  /// All streams will be closed and all values will be removed.
  void dispose() => clear();
}

/// A class for storing values in a [ValueCache].
///
/// Takes care of holding various metadata about the value.
/// This includes the time it was created, the last time it was accessed, and the maximum age.
abstract class ValueCacheEntry<V> implements Comparable<ValueCacheEntry<V>> {
  /// Creates a [SingleValueCacheEntry].
  factory ValueCacheEntry(V? value) = SingleValueCacheEntry<V>;

  /// Constructor for subclasses.
  ValueCacheEntry.raw();

  /// The value of this cache entry.
  ///
  /// Accessing or updating this value will update the last accessed time.
  /// If the value is stale according to [maxAge], this will return null.
  /// Updating the value will reset its created time.
  V? get value;
  set value(V? value);

  /// The time this value was created.
  /// This is reset when the value is updated.
  DateTime get created;

  /// The last time this value was accessed.
  DateTime get accessed;

  /// The maximum age of this value.
  /// If null, the value will not expire.
  Duration? get maxAge;
  set maxAge(Duration? maxAge);

  /// Whether this value is stale.
  ///
  /// If [maxAge] is null, this will always return false.
  /// A value is stale if it has been created more than [maxAge] ago.
  bool get stale;

  /// Whether this value has active listeners.
  bool get hasListeners;

  /// Returns a stream of this value.
  /// If the value is updated, the new value will be emitted.
  ///
  /// If [value] is null, [fetch] will be called to populate it, if provided.
  /// If [fetch] is called, [maxAge] will be used as the time to live for the value.
  Stream<V> stream({
    FutureOr<V> Function()? fetch,
    Duration? maxAge,
  });

  /// Frees all resources associated with this cache entry.
  /// All streams will be closed and the value will be removed.
  void dispose() {}

  @override
  int compareTo(ValueCacheEntry<V> other) {
    if (stale && !other.stale) {
      return -1;
    } else if (!stale && other.stale) {
      return 1;
    } else {
      return accessed.compareTo(other.accessed);
    }
  }
}

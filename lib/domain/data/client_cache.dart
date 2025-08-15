import 'package:e1547/stream/stream.dart';

extension type ClientCache._(Map<Type, ValueCache<dynamic, dynamic>> _caches)
    implements Map<Type, ValueCache<dynamic, dynamic>> {
  ClientCache([Map<Type, ValueCache<dynamic, dynamic>>? caches])
    : _caches = caches ?? {};

  ValueCache<K, V> single<K extends Object, V extends Object>() {
    final cache = _caches[V];
    if (cache is ValueCache<K, V>) {
      return cache;
    }
    throw ArgumentError(
      'No cache found for type $V or type mismatch. Expected ValueCache<$K, $V>, got ${cache.runtimeType}.',
    );
  }

  PagedValueCache<K, I, V>
  paged<K extends Object, I extends Object, V extends Object>() {
    final cache = _caches[V];
    if (cache is PagedValueCache<K, I, V>) {
      return cache;
    }
    throw ArgumentError(
      'No cache found for type $V or type mismatch. Expected PagedValueCache<$K, $I, $V>, got ${cache.runtimeType}.',
    );
  }

  void dispose() {
    for (final cache in _caches.values) {
      cache.dispose();
    }
    _caches.clear();
  }
}

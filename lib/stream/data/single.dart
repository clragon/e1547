import 'dart:async';

import 'package:e1547/stream/stream.dart';
import 'package:rxdart/rxdart.dart';

class SingleValueCacheEntry<V> extends ValueCacheEntry<V> {
  /// Holds a [ValueCache] value.
  SingleValueCacheEntry(V? value)
      : _value = value,
        super.raw();

  V? _value;

  @override
  V? get value {
    _accessed = DateTime.now();
    if (_maxAge != null && _accessed.difference(_created) > _maxAge!) {
      return null;
    }
    return _value;
  }

  @override
  set value(V? value) {
    if (value == null) return;
    _accessed = DateTime.now();
    _created = _accessed;
    if (_value == value) return;
    _value = value;
    for (final stream in _streams) {
      stream.add(value);
    }
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

  @override
  bool get stale =>
      _maxAge != null && DateTime.now().difference(_created) > _maxAge!;

  final List<StreamController<V>> _streams = [];

  @override
  bool get hasListeners => _streams.any((e) => e.hasListener);

  @override
  Stream<V> stream({
    FutureOr<V> Function()? fetch,
    Duration? maxAge,
  }) {
    _accessed = DateTime.now();
    late BehaviorSubject<V> controller;
    controller = BehaviorSubject<V>(
      onListen: () async {
        _streams.add(controller);
        if (fetch != null && !controller.hasValue) {
          value = await fetch();
          this.maxAge = maxAge;
        }
      },
      onCancel: () {
        _streams.remove(controller);
        controller.close();
      },
    );

    V? initial = value;
    if (initial != null) {
      controller.add(initial);
    }

    return controller.stream;
  }

  @override
  void dispose() {
    _value = null;
    for (final stream in _streams) {
      stream.close();
    }
    _streams.clear();
  }
}

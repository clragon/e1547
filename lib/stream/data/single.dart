import 'dart:async';

import 'package:e1547/stream/stream.dart';
import 'package:rxdart/rxdart.dart';

class SingleValueCacheEntry<V> extends ValueCacheEntry<V> {
  /// Holds a [ValueCache] value.
  SingleValueCacheEntry(V? value)
      : _value = value,
        super.raw() {
    _setupQueue();
  }

  V? _value;

  @override
  V? get value {
    _accessed = DateTime.now();
    return _value;
  }

  @override
  set value(V? value) {
    if (value == null) return;
    _accessed = DateTime.now();
    _created = _accessed;
    if (_value == value) return;
    _value = value;
    _statusStream.add(ValueCacheStatus.idle);
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

  final BehaviorSubject<ValueCacheStatus> _statusStream =
      BehaviorSubject.seeded(ValueCacheStatus.idle);

  ValueCacheStatus get status => _statusStream.value;

  Stream<ValueCacheStatus> get statusStream => _statusStream.stream;

  final StreamController<FutureOr<V> Function()?> _fetchQueue =
      StreamController();

  void _setupQueue() {
    _fetchQueue.stream.asyncMap((fetch) async {
      if (fetch == null) return;

      final hasValue = value != null;
      if (hasValue && !stale) return;

      _statusStream.add(
          hasValue ? ValueCacheStatus.refetching : ValueCacheStatus.fetching);

      try {
        value = await fetch();
        _statusStream.add(ValueCacheStatus.idle);
      } on Object catch (e, st) {
        _statusStream.add(ValueCacheStatus.error);
        for (final stream in _streams) {
          stream.addError(e, st);
        }
      }
    }).listen(null);
  }

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
        _fetchQueue.add(fetch);
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
    _statusStream.close();
    _fetchQueue.close();
  }
}

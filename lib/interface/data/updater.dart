import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

abstract class DataUpdater<T> extends ChangeNotifier {
  int progress = 0;

  @protected
  Duration? get stale => null;

  Future get finish => _updateCompleter.future;
  Completer _updateCompleter = Completer()..complete();
  final Mutex _updateLock = Mutex();

  bool get updating => !_updateCompleter.isCompleted;
  bool error = false;
  bool restarting = false;
  bool canceling = false;

  late List<Listenable> _refreshListeners = getRefreshListeners();

  DataUpdater() {
    _refreshListeners.forEach((e) => e.addListener(refresh));
  }

  @override
  void dispose() {
    _refreshListeners.forEach((e) => e.removeListener(refresh));
    super.dispose();
  }

  @mustCallSuper
  Future<void> cancel() async {
    if (!(_updateCompleter.isCompleted)) {
      canceling = true;
    }
    return finish;
  }

  @mustCallSuper
  @protected
  Future<void> fail() async {
    if (!_updateCompleter.isCompleted) {
      error = true;
    }
    return finish;
  }

  @mustCallSuper
  @protected
  void uncomplete() {
    if (_updateCompleter.isCompleted) {
      _updateCompleter = Completer();
    }
  }

  @mustCallSuper
  @protected
  void complete() {
    _updateLock.release();
    _updateCompleter.complete();
    notifyListeners();
  }

  @mustCallSuper
  void reset() {
    uncomplete();
    progress = 0;
    restarting = false;
    canceling = false;
    error = false;
    notifyListeners();
  }

  @mustCallSuper
  List<Listenable> getRefreshListeners() => [];

  @protected
  Future<T> read();

  @protected
  Future<void> write(T? data);

  @protected
  Future<T?> run(T data, bool force);

  @mustCallSuper
  bool step([int? progress]) {
    if (restarting || canceling || error) {
      return false;
    }
    this.progress = progress ?? this.progress + 1;
    notifyListeners();
    return true;
  }

  Future<void> _wrapper({bool force = false}) async {
    await _updateLock.acquire();
    T data = await read();
    T? result = await run(data, force);
    if (restarting) {
      _updateLock.release();
      return;
    }
    await write(result);
    complete();
  }

  @mustCallSuper
  Future<void> update({bool force = false}) async {
    if (_updateCompleter.isCompleted) {
      uncomplete();
      reset();
      _wrapper(force: force);
    }
    return finish;
  }

  @mustCallSuper
  Future<void> refresh({bool force = false}) async {
    if (!_updateCompleter.isCompleted) {
      restarting = true;
      await _updateLock.acquire();
      _updateLock.release();
    }
    reset();
    _wrapper(force: force);
    return finish;
  }
}

mixin HostableUpdater<T> on DataUpdater<T> {
  @override
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(client);
}

mixin EditableUpdater<T extends Iterable> on DataUpdater<T> {
  ValueNotifier<T> get source;
  late EqualityValueNotifier<T> target = EqualityValueNotifier(source);

  @override
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(target);
}

class EqualityValueNotifier<T extends Iterable> extends ValueNotifier<T> {
  final ValueNotifier<T> source;

  EqualityValueNotifier(this.source) : super(source.value) {
    source.addListener(updateValue);
  }

  void updateValue() {
    if (!UnorderedIterableEquality().equals(value, source.value)) {
      value = source.value;
    }
  }

  @override
  void dispose() {
    source.removeListener(updateValue);
    super.dispose();
  }
}

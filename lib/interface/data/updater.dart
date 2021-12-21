import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

abstract class DataUpdater<T> extends ChangeNotifier {
  final ValueNotifier<int> progress = ValueNotifier(0);
  final Mutex updateLock = Mutex();

  Duration? get stale => null;

  Future get finish => completer.future;
  Completer completer = Completer();

  bool error = false;
  bool restarting = false;
  bool canceling = false;

  DataUpdater() {
    getRefreshListeners().forEach((element) => element.addListener(refresh));
  }

  @override
  void dispose() {
    getRefreshListeners().forEach((element) => element.removeListener(refresh));
    super.dispose();
  }

  @mustCallSuper
  Future<void> refresh() async {
    if (completer.isCompleted) {
      update();
    } else {
      restarting = true;
    }
    return finish;
  }

  @mustCallSuper
  Future<void> cancel() async {
    if (!(completer.isCompleted)) {
      canceling = true;
    }
    return finish;
  }

  @mustCallSuper
  Future<void> fail() async {
    if (!completer.isCompleted) {
      error = true;
    }
    return finish;
  }

  @mustCallSuper
  void uncomplete() {
    if (completer.isCompleted) {
      completer = Completer();
    }
  }

  @mustCallSuper
  void complete() {
    updateLock.release();
    completer.complete();
    notifyListeners();
  }

  @mustCallSuper
  void reset() {
    uncomplete();
    progress.value = 0;
    restarting = false;
    canceling = false;
    error = false;
    notifyListeners();
  }

  @mustCallSuper
  List<ValueNotifier> getRefreshListeners() => [];

  Future<T> read();

  Future<void> write(T? data);

  Future<T?> run(T data, bool force);

  @mustCallSuper
  bool step([int? progress]) {
    if (restarting || canceling || error) {
      return false;
    }
    this.progress.value = progress ?? this.progress.value + 1;
    notifyListeners();
    return true;
  }

  Future<void> wrapper({bool force = false}) async {
    T data = await read();
    T? result = await run(data, force);
    if (restarting) {
      updateLock.release();
      update(force: force);
      return;
    }
    await write(result);
    complete();
  }

  Future<void> update({bool force = false}) async {
    uncomplete();
    if (updateLock.isLocked) {
      return finish;
    }
    await updateLock.acquire();
    reset();
    wrapper(force: force);
    return finish;
  }
}

mixin HostableUpdater<T> on DataUpdater<T> {
  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(settings.host);
}

mixin EditableUpdater<T extends Iterable> on DataUpdater<T> {
  ValueNotifier<T> get source;
  late EqualityValueNotifier<T> target = EqualityValueNotifier(source);

  @override
  List<ValueNotifier> getRefreshListeners() =>
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

import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

abstract class DataUpdater<T> extends ChangeNotifier with DataLock<T> {
  final Mutex _runLock = Mutex();

  Future<void> get finish => _runCompleter.future;

  Completer<void> _runCompleter = Completer()..complete();

  int _progress = 0;
  int get progress => _progress;

  bool get updating => !_runCompleter.isCompleted;
  bool restarting = false;
  bool canceling = false;

  Exception? error;

  late List<Listenable> _refreshListeners = getRefreshListeners();

  DataUpdater() {
    _refreshListeners.forEach((e) => e.addListener(restart));
  }

  @override
  void dispose() {
    _refreshListeners.forEach((e) => e.removeListener(restart));
    super.dispose();
  }

  void _fail(Exception exception) {
    error = exception;
    _runCompleter.completeError(exception);
    _runLock.release();
    notifyListeners();
  }

  void _complete() {
    _runLock.release();
    _runCompleter.complete();
    notifyListeners();
  }

  void _reset() {
    _progress = 0;
    restarting = false;
    canceling = false;
    error = null;
    notifyListeners();
  }

  @protected
  @mustCallSuper
  List<Listenable> getRefreshListeners() => [];

  @protected
  Future<void> run(bool force);

  @mustCallSuper
  bool step([int? progress]) {
    if (restarting || canceling) {
      return false;
    }
    _progress = progress ?? this.progress + 1;
    notifyListeners();
    return true;
  }

  Future<void> _wrapper({bool force = false}) async {
    await _runLock.acquire();
    try {
      await run(force);
      if (restarting) {
        _runLock.release();
        return;
      }
      _complete();
    } on UpdaterException catch (e) {
      _fail(e);
    }
  }

  @mustCallSuper
  Future<void> update({bool force = false}) async {
    if (_runCompleter.isCompleted) {
      _runCompleter = Completer();
      _reset();
      _wrapper(force: force);
    }
    return finish;
  }

  @mustCallSuper
  Future<void> restart({bool force = false}) async {
    if (_runCompleter.isCompleted) {
      _runCompleter = Completer();
    } else {
      restarting = true;
      await _runLock.acquire();
      _runLock.release();
    }
    _reset();
    _wrapper(force: force);
    return finish;
  }

  @mustCallSuper
  Future<void> cancel() async {
    if (!(_runCompleter.isCompleted)) {
      canceling = true;
    }
    return finish;
  }
}

class UpdaterException implements Exception {
  final String? message;

  UpdaterException({this.message});
}

typedef DataUpdate<T> = FutureOr<T> Function(T data);

abstract class DataLock<T> {
  @protected
  final Mutex resourceLock = Mutex();

  @protected
  Future<T> read();

  @protected
  Future<void> write(T value);

  @protected
  Future<void> withData(DataUpdate<T> updater) async {
    await resourceLock.acquire();
    T updated = await updater(await read());
    await write(updated);
    resourceLock.release();
  }
}

mixin HostableUpdater<T> on DataUpdater<T> {
  @override
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(client);
}

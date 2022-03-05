import 'dart:async';

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
    _updateLock.release();
    _updateCompleter.completeError(exception);
    notifyListeners();
  }

  void _uncomplete() {
    if (_updateCompleter.isCompleted) {
      _updateCompleter = Completer();
    }
  }

  void _complete() {
    _updateLock.release();
    _updateCompleter.complete();
    notifyListeners();
  }

  void _reset() {
    _uncomplete();
    progress = 0;
    restarting = false;
    canceling = false;
    error = null;
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
    if (restarting || canceling) {
      return false;
    }
    this.progress = progress ?? this.progress + 1;
    notifyListeners();
    return true;
  }

  Future<void> _wrapper({bool force = false}) async {
    await _updateLock.acquire();
    T data = await read();
    T? result;
    try {
      result = await run(data, force);
      if (restarting) {
        _updateLock.release();
        return;
      }
      await write(result);
      _complete();
    } on Exception catch (e) {
      if (e is UpdaterException) {
        _fail(e);
      } else {
        rethrow;
      }
    }
  }

  @mustCallSuper
  Future<void> update({bool force = false}) async {
    if (_updateCompleter.isCompleted) {
      _uncomplete();
      _reset();
      _wrapper(force: force);
    }
    return finish;
  }

  @mustCallSuper
  Future<void> restart({bool force = false}) async {
    if (!_updateCompleter.isCompleted) {
      restarting = true;
      await _updateLock.acquire();
      _updateLock.release();
    }
    _reset();
    _wrapper(force: force);
    return finish;
  }

  @mustCallSuper
  Future<void> cancel() async {
    if (!(_updateCompleter.isCompleted)) {
      canceling = true;
    }
    return finish;
  }
}

class UpdaterException implements Exception {
  final String? message;

  UpdaterException({this.message});
}

mixin HostableUpdater<T> on DataUpdater<T> {
  @override
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(client);
}

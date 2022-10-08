import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

abstract class DataUpdater extends ChangeNotifier {
  DataUpdater() {
    _refreshListeners.forEach((e) => e.addListener(restart));
  }

  final Mutex _runLock = Mutex();
  Completer<void> _runCompleter = Completer()..complete();

  bool get updating => !_runCompleter.isCompleted;

  Future<void> get finish => _runCompleter.future;

  bool _canceling = false;
  int _progress = 0;

  int get progress => _progress;
  Exception? _error;

  Exception? get error => _error;

  late final List<Listenable> _refreshListeners = getRefreshListeners();

  @protected
  @mustCallSuper
  List<Listenable> getRefreshListeners() => [];

  @override
  void dispose() {
    _refreshListeners.forEach((e) => e.removeListener(restart));
    super.dispose();
  }

  void _fail(Exception exception) {
    _error = exception;
    _runCompleter.completeError(exception);
    _runLock.release();
    notifyListeners();
  }

  void _complete() {
    _runCompleter.complete();
    _runLock.release();
    notifyListeners();
  }

  void _reset() {
    _progress = 0;
    _canceling = false;
    _error = null;
    _runCompleter = Completer();
    notifyListeners();
  }

  @protected
  Future<void> run(bool force);

  @mustCallSuper
  bool step() {
    if (_canceling) {
      return false;
    }
    _progress++;
    notifyListeners();
    return true;
  }

  Future<void> _wrapper({bool? force}) async {
    await _runLock.acquire();
    if (_runCompleter.isCompleted) {
      _reset();
    }
    try {
      await run(force ?? false);
      if (_canceling) {
        _runLock.release();
      } else {
        _complete();
      }
    } on UpdaterException catch (e) {
      _fail(e);
    }
  }

  @mustCallSuper
  Future<void> update({bool? force}) async {
    if (_runCompleter.isCompleted) {
      _wrapper(force: force);
    }
    return finish;
  }

  @mustCallSuper
  Future<void> restart({bool? force}) async {
    if (!_runCompleter.isCompleted) {
      _canceling = true;
      await _runLock.protect(() async => {});
      _reset();
    }
    _wrapper(force: force);
    return finish;
  }

  @mustCallSuper
  Future<void> cancel() async {
    if (!_runCompleter.isCompleted) {
      _canceling = true;
      await _runLock.protect(() async => {});
      _complete();
    }
    return finish;
  }
}

class UpdaterException implements Exception {
  UpdaterException({this.message});

  final String? message;
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
  Future<void> protect(DataUpdate<T> updater) async => resourceLock.protect(
        () async {
          T updated = await updater(await read());
          await write(updated);
        },
      );
}

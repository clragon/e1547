import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

abstract class DataUpdater extends ChangeNotifier {
  DataUpdater() {
    _refreshListeners.forEach((e) => e.addListener(restart));
  }

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
    notifyListeners();
  }

  void _complete() {
    _runCompleter.complete();
    notifyListeners();
  }

  void _reset() {
    _progress = 0;
    _canceling = false;
    _error = null;
    _runCompleter = Completer();
    notifyListeners();
  }

  Future<void> _run({bool? force}) async {
    assert(
      _runCompleter.isCompleted,
      '$runtimeType: multiple updater runs called simultaneously!',
    );
    _reset();
    try {
      await run(force ?? false);
      _complete();
    } on UpdaterException catch (e) {
      _fail(e);
    }
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

  @mustCallSuper
  Future<void> update({bool? force}) async {
    if (_runCompleter.isCompleted) {
      await _run(force: force);
    }
    return finish;
  }

  @mustCallSuper
  Future<void> restart({bool? force}) async {
    await cancel();
    await _run(force: force);
    return finish;
  }

  @mustCallSuper
  Future<void> cancel() async {
    if (!_runCompleter.isCompleted) {
      _canceling = true;
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
  final Mutex _resourceLock = Mutex();

  /// Reads data.
  @protected
  FutureOr<T> read();

  /// Writes data.
  @protected
  Future<void> write(T value);

  /// Protects an operation on the data.
  @protected
  Future<void> protect(DataUpdate<T> updater) async => _resourceLock.protect(
        () async {
          T updated = await updater(await read());
          await write(updated);
        },
      );
}

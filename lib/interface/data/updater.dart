import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

abstract class DataUpdater extends ChangeNotifier {
  int progress = 0;

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
    _updateCompleter.completeError(exception);
    _updateLock.release();
    notifyListeners();
  }

  void _complete() {
    _updateLock.release();
    _updateCompleter.complete();
    notifyListeners();
  }

  void _reset() {
    progress = 0;
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
    this.progress = progress ?? this.progress + 1;
    notifyListeners();
    return true;
  }

  Future<void> _wrapper({bool force = false}) async {
    await _updateLock.acquire();
    try {
      await run(force);
      if (restarting) {
        _updateLock.release();
        return;
      }
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
      _updateCompleter = Completer();
      _reset();
      _wrapper(force: force);
    }
    return finish;
  }

  @mustCallSuper
  Future<void> restart({bool force = false}) async {
    if (_updateCompleter.isCompleted) {
      _updateCompleter = Completer();
    } else {
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

mixin HostableUpdater on DataUpdater {
  @override
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(client);
}

import 'dart:async';

import 'package:flutter/material.dart';

typedef ControllerAction = Future<void> Function();

class ControllerException implements Exception {
  final String message;

  ControllerException({required this.message});
}

class ActionController extends ChangeNotifier {
  ControllerAction? action;
  bool isLoading = false;
  bool isForgiven = false;
  ControllerException? error;
  bool get isError => error != null;
  Duration errorTimeout = Duration(seconds: 3);
  Timer? errorTimer;

  void forgive() {
    errorTimer?.cancel();
    errorTimer = Timer(
      errorTimeout,
      () {
        isForgiven = true;
        notifyListeners();
      },
    );
  }

  @mustCallSuper
  void reset() {
    isLoading = false;
    isForgiven = false;
    error = null;
    action = null;
    notifyListeners();
  }

  @mustCallSuper
  Future<void> execute(ControllerAction submit) async {
    error = null;
    isForgiven = false;
    isLoading = true;
    notifyListeners();
    try {
      await submit();
      onSucess();
    } on ControllerException catch (e) {
      error = e;
      forgive();
    }
    isLoading = false;
    notifyListeners();
  }

  void onSucess() {}

  @mustCallSuper
  void setAction(ControllerAction submit) {
    isLoading = false;
    error = null;
    action = () => execute(submit);
    notifyListeners();
  }
}

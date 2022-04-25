import 'dart:async';

import 'package:flutter/material.dart';

typedef ActionControllerCallback = FutureOr<void> Function();

class ActionControllerException implements Exception {
  final String message;

  const ActionControllerException({required this.message});
}

class ActionController extends ChangeNotifier {
  ActionControllerCallback? action;
  ActionControllerException? error;
  bool isLoading = false;
  bool isForgiven = false;
  bool get isError => error != null;
  Duration errorTimeout = Duration(seconds: 3);
  Timer? errorTimer;

  @mustCallSuper
  @protected
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
  @protected
  void reset() {
    isLoading = false;
    isForgiven = false;
    error = null;
    action = null;
    notifyListeners();
  }

  @mustCallSuper
  @protected
  Future<void> execute(ActionControllerCallback submit) async {
    error = null;
    isForgiven = false;
    isLoading = true;
    notifyListeners();
    try {
      await submit();
      onSucess();
    } on ActionControllerException catch (e) {
      error = e;
      forgive();
    }
    isLoading = false;
    notifyListeners();
  }

  @protected
  void onSucess() {}

  @mustCallSuper
  void setAction(ActionControllerCallback submit) {
    isLoading = false;
    error = null;
    action = () => execute(submit);
    notifyListeners();
  }
}

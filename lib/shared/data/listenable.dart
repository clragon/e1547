import 'dart:async';

import 'package:flutter/foundation.dart';

extension ConditionalListenables on Listenable {
  Future<void> listenFor(bool Function() condition) async {
    Completer<void> completer = Completer();
    void listener() {
      if (condition()) {
        removeListener(listener);
        completer.complete();
      }
    }

    addListener(listener);
    return completer.future;
  }
}

// ignore: one_member_abstracts
abstract mixin class Disposable {
  @mustCallSuper
  void dispose() {}

  static void tryDispose(Object? object) {
    try {
      (object as dynamic).dispose();
      // ignore: avoid_catching_errors
    } on NoSuchMethodError {
      // this object is not disposable
    }
  }
}

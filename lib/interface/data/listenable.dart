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
abstract interface class Disposable {
  @mustCallSuper
  void dispose();
}

import 'package:flutter/material.dart';

mixin ListenerCallbackMixin<T extends StatefulWidget> on State<T> {
  final Map<Listenable, VoidCallback> listeners = {};
  final Map<Listenable, VoidCallback> initListeners = {};

  @override
  void initState() {
    super.initState();
    for (MapEntry<Listenable, VoidCallback> entry in initListeners.entries) {
      entry.value();
      entry.key.addListener(entry.value);
    }
    for (MapEntry<Listenable, VoidCallback> entry in listeners.entries) {
      entry.key.addListener(entry.value);
    }
  }

  @override
  void dispose() {
    for (MapEntry<Listenable, VoidCallback> entry in initListeners.entries) {
      entry.key.removeListener(entry.value);
    }
    for (MapEntry<Listenable, VoidCallback> entry in listeners.entries) {
      entry.key.removeListener(entry.value);
    }
    super.dispose();
  }
}

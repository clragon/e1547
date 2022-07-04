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

abstract class ProxyValueNotifier<T, P extends Listenable>
    extends ChangeNotifier implements ValueNotifier<T> {
  final P? parent;

  late T _value;

  void _updateValue() {
    T? updated = fromParent();
    if (updated != null) {
      _value = updated;
      notifyListeners();
    }
  }

  @protected
  T? fromParent();
  @protected
  void toParent(T value);

  bool get orphan => parent == null || fromParent() == null;

  @override
  T get value => _value;

  @override
  set value(T value) {
    if (orphan) {
      _value = value;
      notifyListeners();
    }
    toParent(value);
  }

  ProxyValueNotifier({required P this.parent}) {
    parent!.addListener(_updateValue);
    _value = fromParent() as T;
  }

  ProxyValueNotifier.single(T value) : parent = null {
    _value = value;
  }

  @override
  void dispose() {
    parent?.removeListener(_updateValue);
    super.dispose();
  }
}

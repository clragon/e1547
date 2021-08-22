import 'package:flutter/material.dart';

mixin LinkingMixin<T extends StatefulWidget> on State<T> {
  final Map<ChangeNotifier, VoidCallback> links = {};
  final Map<ChangeNotifier, VoidCallback> initLinks = {};

  @override
  void initState() {
    super.initState();
    for (MapEntry<ChangeNotifier, VoidCallback> entry in initLinks.entries) {
      entry.value();
      entry.key.addListener(entry.value);
    }
    for (MapEntry<ChangeNotifier, VoidCallback> entry in links.entries) {
      entry.key.addListener(entry.value);
    }
  }

  @override
  void dispose() {
    for (MapEntry<ChangeNotifier, VoidCallback> entry in initLinks.entries) {
      entry.key.removeListener(entry.value);
    }
    super.dispose();
  }
}

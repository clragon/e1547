import 'package:flutter/material.dart';

mixin LinkingMixin<T extends StatefulWidget> on State<T> {
  final Map<ChangeNotifier, VoidCallback> links = {};

  @override
  void initState() {
    for (MapEntry<ChangeNotifier, VoidCallback> entry in links.entries) {
      entry.value();
      entry.key.addListener(entry.value);
    }
    super.initState();
  }

  @override
  void dispose() {
    for (MapEntry<ChangeNotifier, VoidCallback> entry in links.entries) {
      entry.key.removeListener(entry.value);
    }
    super.dispose();
  }
}

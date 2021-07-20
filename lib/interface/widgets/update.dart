import 'package:flutter/material.dart';

mixin UpdateMixin<T extends StatefulWidget> on State<T> {
  void update() {
    if (mounted) {
      setState(onUpdate);
    }
  }

  void onUpdate() {}
}

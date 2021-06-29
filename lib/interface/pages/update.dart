import 'package:flutter/material.dart';

mixin UpdateMixin<T extends StatefulWidget> on State<T> {
  void update() {
    if (this.mounted) {
      setState(onUpdate);
    }
  }

  void onUpdate() {}
}

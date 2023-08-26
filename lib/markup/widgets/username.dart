import 'package:flutter/material.dart';
import 'package:username_generator/username_generator.dart';

class UsernameGeneratorData extends InheritedWidget {
  const UsernameGeneratorData({required this.generator, required super.child});

  final UsernameGenerator generator;

  static UsernameGenerator? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<UsernameGeneratorData>()
        ?.generator;
  }

  @override
  bool updateShouldNotify(covariant UsernameGeneratorData oldWidget) =>
      oldWidget.generator != generator;
}

import 'package:flutter/cupertino.dart';
import 'package:username_generator/username_generator.dart';

class UsernameGeneratorData extends InheritedWidget {
  final UsernameGenerator generator;

  UsernameGeneratorData({required this.generator, required Widget child})
      : super(child: child);

  static UsernameGenerator? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<UsernameGeneratorData>()
        ?.generator;
  }

  @override
  bool updateShouldNotify(covariant UsernameGeneratorData oldWidget) =>
      oldWidget.generator != generator;
}

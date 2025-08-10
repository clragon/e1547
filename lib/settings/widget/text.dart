import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PrivateTextFields extends StatelessWidget {
  const PrivateTextFields({super.key, required this.child});

  final Widget child;

  /// Returns whether the text fields should be incognito.
  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_PrivateTextFieldProvider>()
          ?.notifier
          ?.value ??
      false;

  @override
  Widget build(BuildContext context) => _PrivateTextFieldProvider(
    notifier: context.watch<Settings>().incognitoKeyboard,
    child: child,
  );
}

class _PrivateTextFieldProvider extends InheritedNotifier<ValueNotifier<bool>> {
  const _PrivateTextFieldProvider({
    required super.notifier,
    required super.child,
  });
}

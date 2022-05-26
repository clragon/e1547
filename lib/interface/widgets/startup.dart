import 'package:flutter/material.dart';

typedef StartupCallback = void Function(BuildContext context);

class StartupActions extends StatefulWidget {
  final List<StartupCallback> actions;
  final Widget child;

  const StartupActions({required this.child, required this.actions});

  @override
  State<StartupActions> createState() => _StartupActionsState();
}

class _StartupActionsState extends State<StartupActions> {
  @override
  void initState() {
    super.initState();
    for (final element in widget.actions) {
      element(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

import 'package:e1547/follow.dart';
import 'package:flutter/material.dart';

import 'navigation.dart';

final List<Function(BuildContext context)> actions = [
  initAvatar,
  (_) => followUpdater.update(),
];

class StartupActions extends StatefulWidget {
  final Widget child;

  const StartupActions({required this.child});

  @override
  _StartupActionsState createState() => _StartupActionsState();
}

class _StartupActionsState extends State<StartupActions> {
  @override
  void initState() {
    super.initState();
    actions.forEach((element) => element(context));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

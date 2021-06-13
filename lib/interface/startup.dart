import 'package:flutter/material.dart';

import 'navigation.dart';

final List<Function(BuildContext context)> actions = [
  initAvatar,
];

class StartupActions extends StatefulWidget {
  final Widget child;

  const StartupActions({@required this.child});

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

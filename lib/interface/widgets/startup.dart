import 'package:e1547/follow/follow.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

typedef StartupCallback = void Function(BuildContext context);

final List<StartupCallback> actions = [
  initAvatar,
  (_) => followController.update(),
  (_) => initializeDateFormatting(),
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
    for (final element in actions) {
      element(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

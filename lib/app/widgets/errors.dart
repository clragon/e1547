import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:talker/talker.dart';

class ErrorNotifier extends StatelessWidget {
  const ErrorNotifier({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Talker talker = context.read<Talker>();
    return LoggerErrorNotifier(
      onOpenLogs: () =>
          context.read<NavigationController>().navigatorKey.currentState!.push(
                MaterialPageRoute(
                  builder: (context) => LoggerPage(
                    talker: talker,
                  ),
                ),
              ),
      talker: talker,
      child: child,
    );
  }
}

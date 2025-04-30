import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';

class ErrorNotifier extends StatelessWidget {
  const ErrorNotifier({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    Logs? logs = context.watch<Logs?>();
    if (logs == null) return child;
    return LoggerErrorNotifier(
      logs: logs,
      onOpenLogs: () => navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => const LogsPage(),
        ),
      ),
      child: child,
    );
  }
}

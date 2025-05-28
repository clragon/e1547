import 'package:e1547/logs/logs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class LoggerErrorNotifier extends StatelessWidget {
  const LoggerErrorNotifier({
    super.key,
    required this.child,
    required this.logs,
    this.onOpenLogs,
  });

  final Widget child;
  final Logs logs;
  final VoidCallback? onOpenLogs;

  void onMessage(BuildContext context, List<LogRecord> event) {
    if (kReleaseMode) return;
    ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    if (event.isEmpty) return;
    LogRecord item = event.last;
    if (item.level == Level.SHOUT) {
      Color background = item.level.color;
      try {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Builder(
              builder: (context) {
                TextStyle style = Theme.of(context).textTheme.bodyMedium!;
                Color textColor =
                    style.color ?? Theme.of(context).colorScheme.onSurface;
                double textLuminance = textColor.computeLuminance();
                double colorDifference =
                    background.computeLuminance() - textLuminance;
                if (colorDifference.abs() < 0.2) {
                  if (textLuminance > 0.5) {
                    textColor = ThemeData(
                      brightness: Brightness.light,
                    ).textTheme.titleMedium!.color!;
                  } else {
                    textColor = ThemeData(
                      brightness: Brightness.dark,
                    ).textTheme.titleMedium!.color!;
                  }
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A critical error has occured!',
                      style: style.copyWith(color: textColor),
                    ),
                    Text(
                      item.message,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: style.copyWith(color: textColor),
                    ),
                  ],
                );
              },
            ),
            backgroundColor: background,
            behavior: SnackBarBehavior.floating,
            action: onOpenLogs != null
                ? SnackBarAction(label: 'LOGS', onPressed: onOpenLogs!)
                : null,
          ),
        );
      }
      // this is necessary, as there is no way to check whether a [Scaffold] is attached to a [ScaffoldMessenger].
      // If we do not check and the application has an error on boot, it will get stuck in an endless error loop.
      // ignore: avoid_catching_errors
      on Error catch (e) {
        if (!e.toString().contains(
          'ScaffoldMessenger.showSnackBar was called, but there are currently no descendant Scaffolds to present to',
        )) {
          rethrow;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => SubStream<List<LogRecord>>(
    create: () => logs.stream(),
    listener: (e) => onMessage(context, e),
    keys: [logs],
    builder: (context, value) => child,
  );
}

import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:intl/intl.dart';

class LoggerPage extends StatefulWidget {
  const LoggerPage({super.key, required this.logs});

  final Logs logs;

  @override
  State<LoggerPage> createState() => _LoggerPageState();
}

class _LoggerPageState extends State<LoggerPage> {
  Future<void> export() async {
    await Share.shareFile(
      context,
      widget.logs.records.map((e) => e.toString()).join('\n'),
      name: '${DateTime.now().toIso8601String()}.log',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubStream<List<LogRecord>>(
      create: () => widget.logs.stream(),
      builder: (context, snapshot) {
        List<LogRecord>? logs = snapshot.data?.reversed.toList();
        return Scaffold(
          appBar: const DefaultAppBar(title: Text('Logs')),
          body: Builder(builder: (context) {
            if (logs == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (logs.isEmpty) {
              return const Center(
                child: IconMessage(
                  title: Text('No log items!'),
                  icon: Icon(Icons.close),
                ),
              );
            }
            return LimitedWidthLayout.builder(
              builder: (context) => ListView.builder(
                reverse: true,
                padding: LimitedWidthLayout.of(context)
                    .padding
                    .add(defaultActionListPadding),
                itemCount: logs.length,
                itemBuilder: (context, index) => LoggerCard(
                  item: logs[index],
                ),
              ),
            );
          }),
          floatingActionButton: (logs?.isNotEmpty ?? false)
              ? FloatingActionButton(
                  onPressed: export,
                  child: const Icon(Icons.file_download),
                )
              : null,
        );
      },
    );
  }
}

class LoggerCard extends StatefulWidget {
  const LoggerCard({
    super.key,
    required this.item,
    this.expanded = false,
  });

  final LogRecord item;
  final bool expanded;

  @override
  State<LoggerCard> createState() => _LoggerCardState();
}

class _LoggerCardState extends State<LoggerCard> {
  LogRecord get item => widget.item;

  late ExpandableController controller =
      ExpandableController(initialExpanded: widget.expanded);

  @override
  void didUpdateWidget(covariant LoggerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expanded != widget.expanded) {
      controller.expanded = widget.expanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = item.body.ellipse(100).split('\n').first;
    String content = item.body.ellipse(500).split('\n').take(10).join('\n');
    return ExpandableNotifier(
      key: ValueKey(item),
      controller: controller,
      child: ScrollOnExpand(
        child: ExpandableTheme(
          data: ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            iconColor: item.level.color,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: item.level.color,
                    ),
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.passthrough,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(4).copyWith(bottom: 0),
                      padding: const EdgeInsets.all(10).copyWith(top: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: item.level.color),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ExpandablePanel(
                                  collapsed: Text(title),
                                  expanded: Text(content),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: -8,
                      child: Container(
                        color: Theme.of(context).cardColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 10),
                        child: Text(item.title),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: -10,
                      child: Material(
                        color: Theme.of(context).cardColor,
                        child: Row(
                          children: [
                            if (title != content)
                              Builder(
                                builder: (context) => InkWell(
                                  onTap:
                                      ExpandableController.of(context)?.toggle,
                                  child: ExpandableIcon(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoggerErrorNotifier extends StatefulWidget {
  const LoggerErrorNotifier({
    super.key,
    required this.child,
    required this.logs,
    this.onOpenLogs,
  });

  final Widget child;
  final Logs logs;
  final VoidCallback? onOpenLogs;

  @override
  State<LoggerErrorNotifier> createState() => _LoggerErrorNotifierState();
}

class _LoggerErrorNotifierState extends State<LoggerErrorNotifier> {
  late StreamSubscription<List<LogRecord>> subscription;

  @override
  void initState() {
    super.initState();
    subscription = widget.logs.stream().listen(onMessage);
  }

  @override
  void didUpdateWidget(covariant LoggerErrorNotifier oldWidget) {
    if (oldWidget.logs != widget.logs) {
      subscription.cancel();
      subscription = widget.logs.stream().listen(onMessage);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void onMessage(List<LogRecord> event) {
    if (kReleaseMode) return;
    ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    if (event.isEmpty) return;
    LogRecord item = event.first;
    if (item.level.priority == logLevelCritical.priority) {
      Color background = item.level.color;
      try {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Builder(
              builder: (context) {
                TextStyle style = Theme.of(context).textTheme.bodyMedium!;
                Color textColor = style.color!;
                double textLuminance = textColor.computeLuminance();
                double colorDifference =
                    background.computeLuminance() - textLuminance;
                if (colorDifference.abs() < 0.2) {
                  if (textLuminance > 0.5) {
                    textColor = ThemeData(brightness: Brightness.light)
                        .textTheme
                        .titleMedium!
                        .color!;
                  } else {
                    textColor = ThemeData(brightness: Brightness.dark)
                        .textTheme
                        .titleMedium!
                        .color!;
                  }
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A critical error has occured!',
                      style: style.copyWith(
                        color: textColor,
                      ),
                    ),
                    Text(
                      item.message,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: style.copyWith(
                        color: textColor,
                      ),
                    ),
                  ],
                );
              },
            ),
            backgroundColor: background,
            behavior: SnackBarBehavior.floating,
            action: widget.onOpenLogs != null
                ? SnackBarAction(
                    label: 'LOGS',
                    onPressed: widget.onOpenLogs!,
                  )
                : null,
          ),
        );
      }
      // this is necessary, as there is no way to check whether a [Scaffold] is attached to a [ScaffoldMessenger].
      // If we do not check and the application has an error on boot, it will get stuck in an endless error loop.
      // ignore: avoid_catching_errors
      on Error catch (e) {
        if (!e.toString().contains(
            'ScaffoldMessenger.showSnackBar was called, but there are currently no descendant Scaffolds to present to')) {
          rethrow;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

extension LogRecordMessages on LogRecord {
  String get title {
    return '$level | ${DateFormat('HH:mm:ss.SSS').format(time)}';
  }

  String get body {
    String result = '$loggerName: $message';
    if (error != null) {
      result += '\n\n$error';
    }
    if (error != null && stackTrace != null) {
      result += '\n\nstacktrace:\n$stackTrace';
    }
    return result.trim();
  }

  String toFullString() => '$title\n\n$body';
}

extension LogLevelColor on LogLevel? {
  Color get color {
    switch (this) {
      case LogLevel.error:
        return Colors.red[400]!;
      case LogLevel.warning:
        return Colors.orange[800]!;
      case LogLevel.info:
        return Colors.green[400]!;
      case LogLevel.debug:
      default:
        return Colors.blue[400]!;
    }
  }
}

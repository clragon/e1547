import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key, required this.logs});

  final Logs logs;

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<int> levels = [
    LogLevel.debug.priority,
    LogLevel.info.priority,
    LogLevel.warning.priority,
    LogLevel.error.priority,
    logLevelCritical.priority,
  ];

  @override
  Widget build(BuildContext context) {
    return SubStream<List<LogRecord>>(
      create: () => widget.logs.stream(
        filter: (level, type) => levels.contains(level.priority),
      ),
      keys: [levels],
      builder: (context, snapshot) {
        List<LogRecord>? logs = snapshot.data?.reversed.toList();
        return SelectionLayout<LogRecord>(
          items: logs,
          child: Expandables(
            child: Scaffold(
              appBar: const LogSelectionAppBar(
                child: DefaultAppBar(
                  title: Text('Logs'),
                  actions: [ContextDrawerButton()],
                ),
              ),
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
                    itemBuilder: (context, index) =>
                        SelectionItemOverlay<LogRecord>(
                      item: logs[index],
                      padding: const EdgeInsets.all(4),
                      child: LogRecordCard(
                        item: logs[index],
                      ),
                    ),
                  ),
                );
              }),
              floatingActionButton: (logs?.isNotEmpty ?? false)
                  ? FloatingActionButton(
                      onPressed: () => Share.shareAsFile(
                        context,
                        logs!.map((e) => e.toFullString()).join('\n'),
                        name: '${DateTime.now().toIso8601String()}.log',
                      ),
                      child: const Icon(Icons.file_download),
                    )
                  : null,
              endDrawer: LogRecordDrawer(
                levels: levels,
                onChanged: (value) => setState(() => levels = value),
              ),
            ),
          ),
        );
      },
    );
  }
}

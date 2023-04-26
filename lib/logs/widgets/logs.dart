import 'dart:async';
import 'dart:io';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({
    super.key,
    required this.load,
    this.title,
    this.actions,
  });

  final Stream<List<LogString>> Function(List<int> levels) load;
  final Widget? title;
  final List<Widget>? actions;

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<int> levels = logLevels.map((e) => e.priority).toList();

  @override
  Widget build(BuildContext context) {
    return SubStream<List<LogString>>(
      create: () => widget.load(levels),
      keys: [levels],
      builder: (context, snapshot) {
        List<LogString>? logs = snapshot.data;
        return SelectionLayout<LogString>(
          items: logs,
          child: Expandables(
            child: Scaffold(
              appBar: LogSelectionAppBar(
                child: DefaultAppBar(
                  title: widget.title ?? const Text('Logs'),
                  actions: [
                    if (widget.actions != null) ...widget.actions!,
                    const ContextDrawerButton(),
                  ],
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
                        SelectionItemOverlay<LogString>(
                      item: logs[index],
                      padding: const EdgeInsets.all(4),
                      child: LogStringCard(
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
                        logs!.map((e) => e.toString()).join('\n'),
                        name: '${logFileDateFormat.format(DateTime.now())}.log',
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

class LogFilePage extends StatelessWidget {
  const LogFilePage({super.key, required this.path});

  final String path;

  Future<List<LogString>> _read(File file, List<int> levels) async =>
      LogString.parse(await file.readAsString())
          .where((e) => levels.contains(e.level.priority))
          .toList()
          .reversed
          .toList();

  @override
  Widget build(BuildContext context) {
    return LogsPage(
      title: Text('Logs - ${getLogFileName(path)}'),
      load: (levels) {
        File file = File(path);
        late StreamController<List<LogString>> controller;
        controller = StreamController(
            onListen: () async {
              controller.add(await _read(file, levels));
              controller.addStream(
                file
                    .watch(events: FileSystemEvent.modify)
                    .asyncMap((_) async => _read(file, levels)),
              );
            },
            onCancel: () => controller.close());
        return controller.stream;
      },
    );
  }
}

class LogRecordsPage extends StatelessWidget {
  const LogRecordsPage({super.key, required this.logs});

  final Logs logs;

  @override
  Widget build(BuildContext context) {
    return LogsPage(
      load: (levels) => logs
          .stream(filter: (level, type) => levels.contains(level.priority))
          .map((e) => e.reversed.map((e) => LogString.fromRecord(e)).toList()),
      actions: [
        IconButton(
          icon: const Icon(Icons.folder),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const LogFileDialog(),
          ),
        ),
      ],
    );
  }
}

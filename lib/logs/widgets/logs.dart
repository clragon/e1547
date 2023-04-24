import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key, required this.logs});

  final Logs logs;

  @override
  Widget build(BuildContext context) {
    return SubStream<List<LogRecord>>(
      create: () => logs.stream(),
      builder: (context, snapshot) {
        List<LogRecord>? logs = snapshot.data?.reversed.toList();
        return Expandables(
          child: Scaffold(
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
                  itemBuilder: (context, index) => LogRecordCard(
                    item: logs[index],
                  ),
                ),
              );
            }),
            floatingActionButton: (logs?.isNotEmpty ?? false)
                ? FloatingActionButton(
                    onPressed: () => Share.shareFile(
                      context,
                      logs!.map((e) => e.toFullString()).join('\n'),
                      name: '${DateTime.now().toIso8601String()}.log',
                    ),
                    child: const Icon(Icons.file_download),
                  )
                : null,
          ),
        );
      },
    );
  }
}
